//------------------------------------------------------------------------------
//
//  DD_VOXEL: DelphiDoom Voxel Editor
//  Copyright (C) 2013-2019 by Jim Valavanis
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, inc., 59 Temple Place - Suite 330, Boston, MA
//  02111-1307, USA.
//
// DESCRIPTION:
//  Voxel Manager RTL object
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit psv_VXVoxels;

interface

uses
  Classes, uPSCompiler, uPSRuntime;

type
  TPixelArray = array[0..$FFFF] of LongWord;
  PPixelArray = ^TPixelArray;

  TVXVoxel = class(TObject)
  private
    tmpfilename: string;
    originalfilename: string;
    fxsize: integer;
    fysize: integer;
    fzsize: integer;
    Ax, Axy: array[byte] of integer;
    fscaledxsize: integer;
    fscaledysize: integer;
    fscaledzsize: integer;
    fbuffer: PPixelArray;
    fdormant: boolean;
  protected
    procedure SetDormant(const value: boolean); virtual;
    function DoLoadKVX(const vname: string): boolean; virtual;
    function DoLoadVOX(const vname: string): boolean; virtual;
    function DoLoadDDVOX(const vname: string): boolean; virtual;
    function DoLoadDDMESH(const vname: string): boolean; virtual;
    function DoLoadVoxel(const vname: string): boolean; virtual;
    procedure CalcOffsets;
    function pixeloffs(const x, y, z: byte): integer;
  public
    constructor Create(const afilename: string); virtual;
    destructor Destroy; override;
    function Pixels(const x, y, z: integer): LongWord;
    procedure ScaleTo(x, y, z: integer);
    property xSize: integer read fxsize;
    property ySize: integer read fysize;
    property zSize: integer read fzsize;
    property scaledxSize: integer read fscaledxsize;
    property scaledySize: integer read fscaledysize;
    property scaledzSize: integer read fscaledzsize;
    property dormant: boolean read fdormant write SetDormant;
  end;

  TVXVoxels = class(TObject)
  private
    fvoxels: TStringList;
    fcache: TStringList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear;
    function RTLGetVoxel(vname: string): LongWord;
  end;

procedure SIRegister_VXVoxels(CL: TPSPascalCompiler);

procedure RIRegister_VXVoxels(CL: TPSRuntimeClassImporter);

procedure RIRegisterRTL_VXVoxels(Exec: TPSExec);

procedure VXT_ResetVoxels;

implementation

uses
  SysUtils, Graphics, psv_voxel, vxe_kvx, vxe_script, vxe_mesh, vxe_tmp,
  psv_script_functions, psv_temp;

// -----------------------------------------------------------------------------
// TVXVoxel
// -----------------------------------------------------------------------------
constructor TVXVoxel.Create(const afilename: string);
begin
  tmpfilename := '';
  fxsize := 0;
  fysize := 0;
  fzsize := 0;
  CalcOffsets;
  fbuffer := nil;
  fdormant := False;
  DoLoadVoxel(afilename);
  fscaledxsize := fxsize;
  fscaledysize := fysize;
  fscaledzsize := fzsize;
  originalfilename := afilename;
  Inherited Create;
end;

destructor TVXVoxel.Destroy;
begin
  if tmpfilename <> '' then
    if FileExists(tmpfilename) then
      DeleteFile(tmpfilename);
  ReallocMem(fbuffer, 0);
  Inherited;
end;

function TVXVoxel.DoLoadKVX(const vname: string): boolean;
var
  strm: TFileStream;
  pal: array[0..255] of LongWord;
  i: integer;
  r, g, b: byte;
  numbytes: integer;
  xsiz, ysiz, zsiz, xpivot, ypivot, zpivot: integer;
	xoffset: PIntegerArray;
	xyoffset: PSmallIntPArray;
  offs: integer;
  voxdatasize: integer;
  voxdata: PByteArray;
  size: integer;
  xx, yy, zz: integer;
  x1, y1, z1: integer;
  endptr: PByte;
  slab: kvxslab_p;
  kvxbuffer: kvxbuffer_p;
  maxpal: integer;
  cc: integer;
  palfactor: double;
begin
  if not FileExists(vname) then
  begin
    Result := False;
    Exit;
  end;

  strm := TFileStream.Create(vname, fmOpenRead or fmShareDenyWrite);

  strm.Seek(strm.size - 768, soFromBeginning);
  maxpal := 0;
  for i := 0 to 255 do
  begin
    strm.Read(b, SizeOf(Byte));
    if b > maxpal then
      maxpal := b;
    strm.Read(g, SizeOf(Byte));
    if g > maxpal then
      maxpal := g;
    strm.Read(r, SizeOf(Byte));
    if r > maxpal then
      maxpal := r;
    pal[i] := r shl 16 + g shl 8 + b;
    if pal[i] = 0 then
      pal[i] := $01;
  end;
  if (maxpal < 255) and (maxpal > 0) then
  begin
    palfactor := 255 / maxpal;
    if palfactor > 4.0 then
      palfactor := 4.0;
    for i := 0 to 255 do
    begin
      r := pal[i] shr 16;
      g := pal[i] shr 8;
      b := pal[i];
      cc := round(palfactor * r);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      r := cc;
      cc := round(palfactor * g);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      g := cc;
      cc := round(palfactor * b);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      b := cc;
      pal[i] := r shl 16 + g shl 8 + b;
    end;
  end;

  strm.Seek(0, soFromBeginning);
  strm.Read(numbytes, SizeOf(Integer));
  strm.Read(xsiz, SizeOf(Integer));
  strm.Read(ysiz, SizeOf(Integer));
  strm.Read(zsiz, SizeOf(Integer));

  size := 1;

  while xsiz > size do
    size := size * 2;
  while ysiz > size do
    size := size * 2;
  while zsiz > size do
    size := size * 2;

  if size < 256 then
    size := size * 2;

  fxsize := size;
  fysize := size;
  fzsize := size;
  CalcOffsets;
  ReallocMem(fbuffer, fxsize * fysize * fzsize * SizeOf(LongWord));
  FillChar(fbuffer^, fxsize * fysize * fzsize * SizeOf(LongWord), #0);

  strm.Read(xpivot, SizeOf(Integer));
  strm.Read(ypivot, SizeOf(Integer));
  strm.Read(zpivot, SizeOf(Integer));

  GetMem(xoffset, (xsiz + 1) * SizeOf(Integer));
  GetMem(xyoffset, xsiz * SizeOf(PSmallIntArray));
  for i := 0 to xsiz - 1 do
    GetMem(xyoffset[i], (ysiz + 1) * SizeOf(SmallInt));

  strm.Read(xoffset^, (xsiz + 1) * SizeOf(Integer));

  for i := 0 to xsiz - 1 do
    strm.Read(xyoffset[i]^, (ysiz + 1) * SizeOf(SmallInt));

  offs := xoffset[0];

  voxdatasize := numbytes - 24 - (xsiz + 1) * 4 - xsiz * (ysiz + 1) * 2;
  GetMem(voxdata, voxdatasize);
  strm.Read(voxdata^, voxdatasize);
  strm.Free;

  GetMem(kvxbuffer, SizeOf(kvxbuffer_t));
  for xx := 0 to xsiz - 1 do
    for yy := 0 to ysiz - 1 do
       for zz := 0 to zsiz - 1 do
         kvxbuffer[xx, yy, zz] := $FFFF;

  for xx := 0 to xsiz - 1 do
  begin
    for yy := 0 to ysiz - 1 do
    begin
      endptr := @voxdata[xoffset[xx] + xyoffset[xx][yy + 1] - offs];
      slab := @voxdata[xoffset[xx] + xyoffset[xx][yy] - offs];
      while Integer(slab) < integer(endptr) do
      begin
        for zz := slab.ztop to slab.zleng + slab.ztop - 1 do
          kvxbuffer[xx, yy, zz] := slab.col[zz - slab.ztop];
        slab := kvxslab_p(integer(slab) + slab.zleng + 3);
      end;
    end;
  end;

  x1 := size div 2 - xpivot div 256;
  y1 := size div 2 - ypivot div 256;
  z1 := size - zpivot div 256;
  if x1 < 0 then
    x1 := 0;
  if y1 < 0 then
    y1 := 0;
  if z1 < 0 then
    z1 := 0;
  while x1 + xsiz > size do
    dec(x1);
  while y1 + ysiz > size do
    dec(y1);
  while z1 + zsiz > size do
    dec(z1);
  for xx := x1 to x1 + xsiz - 1 do
    for yy := y1 to y1 + ysiz - 1 do
      for zz := z1 to z1 + zsiz - 1 do
        if kvxbuffer[xx - x1, yy - y1, zz - z1] <> $FFFF then
          fbuffer[pixeloffs(xx, zz, size - yy - 1)] := pal[kvxbuffer[xx - x1, yy - y1, zz - z1]];

  FreeMem(xoffset, (xsiz + 1) * SizeOf(Integer));
  for i := 0 to xsiz - 1 do
    FreeMem(xyoffset[i], (ysiz + 1) * SizeOf(SmallInt));
  FreeMem(xyoffset, xsiz * SizeOf(PSmallIntArray));
  FreeMem(voxdata, voxdatasize);
  FreeMem(kvxbuffer, SizeOf(kvxbuffer_t));
  Result := True;
end;

function TVXVoxel.DoLoadVOX(const vname: string): boolean;
var
  strm: TFileStream;
  pal: array[0..255] of LongWord;
  i: integer;
  r, g, b: byte;
  xsiz, ysiz, zsiz: integer;
  voxdatasize: integer;
  voxdata: PByteArray;
  size: integer;
  xx, yy, zz: integer;
  x1, y1, z1: integer;
  s: string;
  maxpal: integer;
  cc: integer;
  palfactor: double;
begin
  if not FileExists(vname) then
  begin
    Result := False;
    Exit;
  end;

  strm := TFileStream.Create(vname, fmOpenRead or fmShareDenyWrite);

  strm.Seek(strm.size - 768, soFromBeginning);
  maxpal := 0;
  for i := 0 to 255 do
  begin
    strm.Read(b, SizeOf(Byte));
    if b > maxpal then
      maxpal := b;
    strm.Read(g, SizeOf(Byte));
    if g > maxpal then
      maxpal := g;
    strm.Read(r, SizeOf(Byte));
    if r > maxpal then
      maxpal := r;
    pal[i] := r shl 16 + g shl 8 + b;
    if pal[i] = 0 then
      pal[i] := $01;
  end;
  if (maxpal < 255) and (maxpal > 0) then
  begin
    palfactor := 255 / maxpal;
    if palfactor > 4.0 then
      palfactor := 4.0;
    for i := 0 to 255 do
    begin
      r := pal[i] shr 16;
      g := pal[i] shr 8;
      b := pal[i];
      cc := round(palfactor * r);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      r := cc;
      cc := round(palfactor * g);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      g := cc;
      cc := round(palfactor * b);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      b := cc;
      pal[i] := r shl 16 + g shl 8 + b;
    end;
  end;

  strm.Seek(0, soFromBeginning);
  strm.Read(xsiz, SizeOf(Integer));
  strm.Read(ysiz, SizeOf(Integer));
  strm.Read(zsiz, SizeOf(Integer));

  if (xsiz < 0) or (xsiz > 256) or
     (ysiz < 0) or (ysiz > 256) or
     (zsiz < 0) or (zsiz > 256) then
  begin
    Result := False;
    strm.Free;
    Exit;
  end;

  size := xsiz;
  if size < ysiz then
    size := ysiz;
  if size < zsiz then
    size := zsiz;

  fxsize := size;
  fysize := size;
  fzsize := size;
  CalcOffsets;
  ReallocMem(fbuffer, fxsize * fysize * fzsize * SizeOf(LongWord));
  FillChar(fbuffer^, fxsize * fysize * fzsize * SizeOf(LongWord), #0);

  voxdatasize := xsiz * ysiz * zsiz;
  GetMem(voxdata, voxdatasize);
  strm.Read(voxdata^, voxdatasize);
  strm.Free;

  x1 := (size - xsiz) div 2;
  y1 := (size - ysiz) div 2;
  z1 := (size - zsiz) div 2;
  i := 0;
  for xx := x1 to x1 + xsiz - 1 do
    for yy := y1 to y1 + ysiz - 1 do
      for zz := z1 to z1 + zsiz - 1 do
      begin
        if voxdata[i] <> 255 then
          fbuffer[pixeloffs(xx, zz, size - yy - 1)] := pal[voxdata[i]];
        inc(i);
      end;

  FreeMem(voxdata, voxdatasize);
  Result := True;
end;

function TVXVoxel.DoLoadDDVOX(const vname: string): boolean;
var
  buf: TStringList;
  sc: TScriptEngine;
  xx, yy, zz: integer;
begin
  if not FileExists(vname) then
  begin
    Result := False;
    Exit;
  end;

  buf := TStringList.Create;
  try
    buf.LoadFromFile(vname);
    sc := TScriptEngine.Create(buf.Text);
    sc.MustGetInteger;
    fxsize := sc._Integer;
    fysize := fxsize;
    fzsize := fysize;
    CalcOffsets;
    ReallocMem(fbuffer, fxsize * fysize * fzsize * SizeOf(LongWord));
    FillChar(fbuffer^, fxsize * fysize * fzsize * SizeOf(LongWord), #0);
    xx := 0;
    yy := 0;
    zz := 0;
    while sc.GetString do
    begin
      if sc.MatchString('skip') then
      begin
        sc.MustGetInteger;
        inc(zz, sc._Integer);
      end
      else
      begin
        sc.UnGet;
        sc.MustGetInteger;
        fbuffer[pixeloffs(xx, yy, zz)] := sc._Integer;
        Inc(zz);
      end;
      if zz = fzsize then
      begin
        zz := 0;
        Inc(yy);
        if yy = fysize then
        begin
          yy := 0;
          Inc(xx);
          if xx = fxsize then
            Break;
        end;
      end;
    end;
    sc.Free;
  finally
    buf.Free;
  end;
  Result := True;
end;

function TVXVoxel.DoLoadDDMESH(const vname: string): boolean;
var
  strm: TFileStream;
  i: integer;
  xb, yb, zb: byte;
  HDR: LongWord;
  version: integer;
  size: integer;
  quads: integer;
  fnumvoxels: Integer;
  c: LongWord;
begin
  if not FileExists(vname) then
  begin
    Result := False;
    Exit;
  end;

  strm := TFileStream.Create(vname, fmOpenRead or fmShareDenyWrite);

  strm.Read(HDR, SizeOf(LongWord));
  if HDR <> Ord('D') + Ord('D') shl 8 + Ord('M') shl 16 + Ord('S') shl 24 then
  begin
    Result := False;
    strm.Free;
    Exit;
  end;

  strm.Read(version, SizeOf(integer));
  if version <> 1 then
  begin
    Result := False;
    strm.Free;
    Exit;
  end;

  strm.Read(size, SizeOf(integer));
  fxsize := size;
  fysize := size;
  fzsize := size;
  CalcOffsets;
  ReallocMem(fbuffer, fxsize * fysize * fzsize * SizeOf(LongWord));
  FillChar(fbuffer^, fxsize * fysize * fzsize * SizeOf(LongWord), #0);

  strm.Read(quads, SizeOf(integer));

  strm.Position := 16 + quads * (4 * SizeOf(voxelvertex_t) + SizeOf(LongWord));

  strm.Read(fnumvoxels, SizeOf(integer));

  for i := 0 to fnumvoxels - 1 do
  begin
    strm.Read(xb, SizeOf(byte));
    strm.Read(yb, SizeOf(byte));
    strm.Read(zb, SizeOf(byte));
    strm.Read(c, SizeOf(LongWord));
    fbuffer[pixeloffs(xb, yb, zb)] := c;
  end;

  strm.Free;

  Result := True;
end;

resourcestring
  rsExtKVX = '.kvx';
  rsExtVOX = '.vox';
  rsExtDDVOX = '.ddvox';
  rsExtDDMESH = '.ddmesh';
  rsExtTmpVox = '.tmpvox';

function TVXVoxel.DoLoadVoxel(const vname: string): boolean;
var
  fs: TFileStream;
  fname: string;
  ext: string;
begin
  fname := VXT_FindFile(vname);
  if not FileExists(fname) then
  begin
    fxsize := 0;
    fysize := 0;
    fzsize := 0;
    CalcOffsets;
    printf('VXT_FindFile(): Can not find file "' + fname + '"'#13#10);
    ReallocMem(fbuffer, 0);
    Result := False;
    Exit;
  end;

  ext := UpperCase(ExtractFileExt(fname));
  if ext = UpperCase(rsExtKVX) then
    Result := DoLoadKVX(fname)
  else if ext = UpperCase(rsExtVOX) then
    Result := DoLoadVOX(fname)
  else if ext = UpperCase(rsExtDDVOX) then
    Result := DoLoadDDVOX(fname)
  else if ext = UpperCase(rsExtDDMESH) then
    Result := DoLoadDDMESH(fname)
  else if ext = UpperCase(rsExtTmpVox) then
  begin
    fs := TFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);
    try
      fs.Read(fxsize, SizeOf(fxsize));
      fs.Read(fysize, SizeOf(fysize));
      fs.Read(fzsize, SizeOf(fzsize));
      ReallocMem(fbuffer, fxsize * fysize * fzsize * SizeOf(LongWord));
      fs.Read(fbuffer^, fxsize * fysize * fzsize * SizeOf(LongWord));
    finally
      fs.Free;
    end;
    Result := True;
  end
  else
  begin
    fxsize := 0;
    fysize := 0;
    fzsize := 0;
    CalcOffsets;
    printf('TVXVoxel.DoLoadVoxel(): Unknown voxel format "' + ext + '"'#13#10);
    ReallocMem(fbuffer, 0);
    Result := False;
  end;
end;

var
  tmpid: integer = 0;

procedure TVXVoxel.SetDormant(const value: boolean);
var
  fs: TFileStream;
begin
  if value = fdormant then
    Exit;

  if value then
  begin
    if tmpfilename <> '' then
    begin
      if DoLoadVoxel(tmpfilename) then
        fdormant := False
      else if DoLoadVoxel(originalfilename) then
        fdormant := False;
    end;
  end
  else
  begin
    if tmpfilename = '' then
    begin
      inc(tmpid);
      tmpfilename := I_NewTempFile('VXVoxel_' + IntToStr(tmpid) + rsExtTmpVox);
      fs := TFileStream.Create(tmpfilename, fmCreate or fmShareDenyNone);
      try
        fs.Write(fxsize, SizeOf(fxsize));
        fs.Write(fysize, SizeOf(fysize));
        fs.Write(fzsize, SizeOf(fzsize));
        fs.Write(fbuffer^, fxsize * fysize * fzsize * SizeOf(LongWord));
      finally
        fs.Free;
      end;
    end;
    ReallocMem(fbuffer, 0);
    fdormant := True;
  end;
end;

procedure TVXVoxel.ScaleTo(x, y, z: integer);
begin
  fscaledxsize := x;
  fscaledysize := y;
  fscaledzsize := z;
end;

procedure TVXVoxel.CalcOffsets;
var
  i: integer;
  fxy: integer;
begin
  fxy := fxsize * fysize;
  for i := 0 to 255 do
  begin
    Ax[i] := fxsize * i;
    Axy[i] := fxy * i;
  end;
end;

function TVXVoxel.pixeloffs(const x, y, z: byte): integer;
begin
  Result := x + Ax[y] + Axy[z];
end;

function TVXVoxel.Pixels(const x, y, z: integer): LongWord;
var
  ax, ay, az: integer;
begin
  SetDormant(False);
  if (fxsize = 0) or (fysize = 0) or (fzsize = 0) or (fbuffer = nil) or (fscaledxsize = 0) or (fscaledysize = 0) or (fscaledzsize = 0) then
  begin
    Result := 0;
    Exit;
  end;

  if (fscaledxsize = fxsize) and (fscaledysize = fysize) and (fscaledzsize = fzsize) then
  begin
    ax := x mod fxsize;
    if ax < 0 then
      ax := -ax;
    ay := y mod fysize;
    if ay < 0 then
      ay := -ay;
    az := z mod fzsize;
    if az < 0 then
      az := -az;
    Result := fbuffer[pixeloffs(ax, ay, az)];
  end
  else
  begin
    ax := Trunc(x * fxsize / fscaledxsize) mod fxsize;
    if ax < 0 then
      ax := -ax;
    ay := Trunc(y * fysize / fscaledysize) mod fysize;
    if ay < 0 then
      ay := -ay;
    az := Trunc(z * fzsize / fscaledzsize) mod fzsize;
    if az < 0 then
      az := -az;
    Result := fbuffer[pixeloffs(ax, ay, az)];
  end;
end;

// -----------------------------------------------------------------------------
// TVXVoxels
// -----------------------------------------------------------------------------
constructor TVXVoxels.Create;
begin
  fvoxels := TStringList.Create;
  fcache := TStringList.Create;
  Inherited;
end;

destructor TVXVoxels.Destroy;
var
  i: integer;
begin
  for i := 0 to fvoxels.Count - 1 do
    (fvoxels.Objects[i] as TVXVoxel).Free;
  fvoxels.Free;
  fcache.Free;
  Inherited;
end;

procedure TVXVoxels.Clear;
var
  i: integer;
begin
  for i := 0 to fvoxels.Count - 1 do
    (fvoxels.Objects[i] as TVXVoxel).Free;
  fvoxels.Clear;
  fcache.Clear;
end;

const
  MAXCACHEVOXELS = 3;

function TVXVoxels.RTLGetVoxel(vname: string): LongWord;
var
  su: string;
  idx: Integer;
  vox: TVXVoxel;
begin
  su := UpperCase(vname);

  idx := fcache.IndexOf(su);
  if idx >= 0 then
  begin
    vox := (fcache.Objects[idx] as TVXVoxel);
    vox.Dormant := False;
    Result := LongWord(vox);
    Exit;
  end;

  idx := fvoxels.IndexOf(su);
  if idx < 0 then
    idx := fvoxels.AddObject(su, TVXVoxel.Create(vname));
  vox := fvoxels.Objects[idx] as TVXVoxel;

  vox.Dormant := False;

  idx := fcache.IndexOf(su);
  if idx < 0 then
  begin
    fcache.AddObject(su, vox);
    while fcache.Count > MAXCACHEVOXELS do
    begin
      (fcache.Objects[0] as TVXVoxel).Dormant := True;
      fcache.Delete(0);
    end;
    // Unneeded
    idx := fcache.IndexOf(su);
    if idx < 0 then
    begin
      fcache.AddObject(su, vox);
      vox.Dormant := False;
    end;
  end;

  Result := LongWord(vox);
end;

//------------------------------------------------------------------------------

procedure SIRegister_VXVoxels(CL: TPSPascalCompiler);
begin
  with CL.AddClassN(CL.FindClass('!TOBJECT'), '!TVXVoxel') do
  begin
    RegisterProperty('xSize', 'integer', iptR);
    RegisterProperty('ySize', 'integer', iptR);
    RegisterProperty('zSize', 'integer', iptR);
    RegisterProperty('Pixels', 'longword integer integer integer', iptR);
    RegisterMethod('procedure ScaleTo(x, y, z: integer);');
    SetDefaultPropery('Pixels');
  end;

  with CL.AddClassN(CL.FindClass('!TOBJECT'), '!TVXVoxels') do
  begin
    RegisterMethod('constructor Create');
    RegisterProperty('voxel', '!TVXVoxel string', iptR);
    SetDefaultPropery('voxel');
  end;
  AddImportedClassVariable(CL, 'Voxels', '!TVXVoxels');
end;

procedure TVXVoxelxSize_R(Self: TVXVoxel; var T: integer);
begin
// We intentionally pass the scaled size in script
  T := Self.scaledxSize;
end;

procedure TVXVoxelySize_R(Self: TVXVoxel; var T: integer);
begin
// We intentionally pass the scaled size in script
  T := Self.scaledySize;
end;

procedure TVXVoxelzSize_R(Self: TVXVoxel; var T: integer);
begin
// We intentionally pass the scaled size in script
  T := Self.scaledzSize;
end;

procedure TVXVoxelPixels_R(Self: TVXVoxel; var T: longword; const x, y, z: integer);
begin
  T := Self.Pixels(x, y, z);
end;

procedure TVXVoxelsVoxel_R(Self: TVXVoxels; var T: longword; const s: string);
begin
  T := Self.RTLGetVoxel(s);
end;

procedure RIRegister_VXVoxels(CL: TPSRuntimeClassImporter);
begin
  with CL.Add2(TVXVoxel, '!TVXVoxel') do
  begin
    RegisterPropertyHelper(@TVXVoxelxSize_R, nil, 'xSize');
    RegisterPropertyHelper(@TVXVoxelySize_R, nil, 'ySize');
    RegisterPropertyHelper(@TVXVoxelzSize_R, nil, 'zSize');
    RegisterPropertyHelper(@TVXVoxelPixels_R, nil, 'Pixels');
    RegisterMethod(@TVXVoxel.ScaleTo, 'ScaleTo');
  end;
  with CL.Add2(TVXVoxels, '!TVXVoxels') do
  begin
    RegisterConstructor(@TVXVoxels.Create, 'Create');
    RegisterPropertyHelper(@TVXVoxelsVoxel_R, nil, 'voxel');
  end;
end;

var
  RTL_VXVoxels: TVXVoxels;

procedure RIRegisterRTL_VXVoxels(Exec: TPSExec);
begin
  SetVariantToClass(Exec.GetVarNo(Exec.GetVar('Voxels')), RTL_VXVoxels);
end;

//------------------------------------------------------------------------------

procedure VXT_ResetVoxels;
begin
  RTL_VXVoxels.Clear;
end;

initialization
  RTL_VXVoxels := TVXVoxels.Create;

finalization
  RTL_VXVoxels.Free;

end.

