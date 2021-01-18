//------------------------------------------------------------------------------
//
//  DD_VOXEL: DelphiDoom Voxel Editor
//  Copyright (C) 2013-2021 by Jim Valavanis
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
//  Export voxel to
//    -Doom Engine sprite
//    -slab6 VOX
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit vxe_export;

interface

uses
  Windows, Graphics,
  voxels;

function VXE_ExportGetFront(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer): TBitmap;

function VXE_ExportGetBack(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer): TBitmap;

function VXE_ExportGetLeft(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer): TBitmap;

function VXE_ExportGetRight(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer): TBitmap;

procedure VXE_ExportVoxelToSprite1(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string);

procedure VXE_ExportVoxelToSprite8(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string);

procedure VXE_ExportVoxelToSprite16(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string);

procedure VXE_ExportVoxelToSprite32(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string);

procedure VXE_RotateVoxelBuffer(const voxelbuffer: voxelbuffer_p;
  const fvoxelsize: Integer; const theta: double; const tmpbuffer: voxelbuffer_p);

procedure VXE_RotateVoxelBufferHQ(const voxelbuffer: voxelbuffer_p;
  const fvoxelsize: Integer; const theta: double; const tmpbuffer: voxelbuffer_p);

function VXE_ExportGetFrontPerspective(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const ebuffer: voxelbuffer_p; const adist: integer = 1024; const aheight: integer = 41): TBitmap;

procedure VXE_GetPerspectiveOffsets(const adist, aheight: integer;
  var offsl, offst: integer);

procedure VXE_ExportVoxelToSpritePerspective1(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string; const adist: integer = 1024; const aheight: integer = 41);

procedure VXE_ExportVoxelToSpritePerspective(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string; const rotations: integer; const adist: integer = 1024; const aheight: integer = 41);

procedure VXE_ExportVoxelToSlab6VOX(const voxelbuffer: voxelbuffer_p; const voxelsize: Integer;
  const fname: string);

implementation

uses
  Classes, SysUtils, vxe_zipfile, vxe_multithreading, pngimage,
  vxe_utils, vxe_wadwriter, vxe_palette, vxe_quantize, progressfrm;

function VXE_ExportGetFront(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer): TBitmap;
var
  x, y, z: integer;
  c: voxelitem_t;
begin
  result := TBitmap.Create;
  result.Width := fvoxelsize;
  result.Height := fvoxelsize;
  result.PixelFormat := pf24bit;

  for x := 0 to fvoxelsize - 1 do
    for y := 0 to fvoxelsize - 1 do
    begin
      c := 0;
      for z := 0 to fvoxelsize - 1 do
        if voxelbuffer[x, y, z] <> 0 then
        begin
          c := voxelbuffer[x, y, z];
          Break;
        end;
      result.Canvas.Pixels[x, y] := c;
    end;

end;

function VXE_ExportGetBack(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer): TBitmap;
var
  x, y, z: integer;
  c: voxelitem_t;
begin
  result := TBitmap.Create;
  result.Width := fvoxelsize;
  result.Height := fvoxelsize;
  result.PixelFormat := pf24bit;

  for x := 0 to fvoxelsize - 1 do
    for y := 0 to fvoxelsize - 1 do
    begin
      c := 0;
      for z := fvoxelsize - 1 downto 0 do
        if voxelbuffer[x, y, z] <> 0 then
        begin
          c := voxelbuffer[x, y, z];
          Break;
        end;
      result.Canvas.Pixels[fvoxelsize - 1 - x, y] := c;
    end;

end;

function VXE_ExportGetLeft(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer): TBitmap;
var
  x, y, z: integer;
  c: voxelitem_t;
begin
  result := TBitmap.Create;
  result.Width := fvoxelsize;
  result.Height := fvoxelsize;
  result.PixelFormat := pf24bit;

  for z := 0 to fvoxelsize - 1 do
    for y := 0 to fvoxelsize - 1 do
    begin
      c := 0;
      for x := 0 to fvoxelsize - 1 do
        if voxelbuffer[x, y, z] <> 0 then
        begin
          c := voxelbuffer[x, y, z];
          Break;
        end;
      result.Canvas.Pixels[fvoxelsize - 1 - z, y] := c;
    end;

end;

function VXE_ExportGetRight(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer): TBitmap;
var
  x, y, z: integer;
  c: voxelitem_t;
begin
  result := TBitmap.Create;
  result.Width := fvoxelsize;
  result.Height := fvoxelsize;
  result.PixelFormat := pf24bit;

  for z := 0 to fvoxelsize - 1 do
    for y := 0 to fvoxelsize - 1 do
    begin
      c := 0;
      for x := fvoxelsize - 1 downto 0 do
        if voxelbuffer[x, y, z] <> 0 then
        begin
          c := voxelbuffer[x, y, z];
          Break;
        end;
      result.Canvas.Pixels[z, y] := c;
    end;

end;

procedure VXE_RotateVoxelBuffer(const voxelbuffer: voxelbuffer_p;
  const fvoxelsize: Integer; const theta: double; const tmpbuffer: voxelbuffer_p);
var
  x, y, z: integer;
  sinval, cosval: double;
  newx, newz: integer;
  c: voxelitem_t;
  halfsize: double;
begin
  sinval := sin(theta);
  cosval := cos(theta);
  MT_ZeroMemory(tmpbuffer, SizeOf(voxelbuffer_t));

  halfsize := fvoxelsize / 2;
  for y := 0 to fvoxelsize - 1 do
    for x := 0 to fvoxelsize - 1 do
      for z := 0 to fvoxelsize - 1 do
      begin
        newx := round(halfsize + (x - halfsize) * cosval - (z - halfsize) * sinval);
        newz := round(halfsize + (x - halfsize) * sinval + (z - halfsize) * cosval);
        if (newx >= 0) and (newx < fvoxelsize) and (newz >= 0) and (newz < fvoxelsize) then
        begin
          c := voxelbuffer[newx, y, newz];
          if c <> 0 then
            tmpbuffer[x, y, z] := c;
        end;
      end;
end;

type
  hqbuffer_t = array[0..3 * MAXVOXELSIZE - 1, 0..3 * MAXVOXELSIZE - 1] of record
    color: voxelitem_t;
    size: integer;
  end;
  hqbuffer_p = ^hqbuffer_t;

type
  rotateinfohq1_t = record
    voxelbuffer: voxelbuffer_p;
    fvoxelsize: Integer;
    buf2: hqbuffer_p;
    y, start, stop: Integer;
  end;
  rotateinfohq1_p = ^rotateinfohq1_t;

function _rotate_voxel_hq1_thr(p: pointer): integer; stdcall;
var
  c: LongWord;
  x, z: Integer;
  x3, z3: Integer;
  buf2: hqbuffer_p;
  y, start, stop: Integer;
  fvoxelsize: Integer;
  voxelbuffer: voxelbuffer_p;
begin
  voxelbuffer := rotateinfohq1_p(p).voxelbuffer;
  fvoxelsize := rotateinfohq1_p(p).fvoxelsize;
  buf2 := rotateinfohq1_p(p).buf2;
  y := rotateinfohq1_p(p).y;
  start := rotateinfohq1_p(p).start;
  stop := rotateinfohq1_p(p).stop;

  x3 := 0;
  for x := 0 to fvoxelsize - 1 do
  begin
    for z := start to stop do
    begin
      c := voxelbuffer[x, y, z];
      if c <> 0 then
      begin
        z3 := z * 3;
        buf2[x3    , z3    ].color := c;
        buf2[x3 + 1, z3    ].color := c;
        buf2[x3 + 2, z3    ].color := c;
        buf2[x3    , z3 + 1].color := c;
        buf2[x3 + 1, z3 + 1].color := c;
        buf2[x3 + 2, z3 + 1].color := c;
        buf2[x3    , z3 + 2].color := c;
        buf2[x3 + 1, z3 + 2].color := c;
        buf2[x3 + 2, z3 + 2].color := c;
      end;
    end;
    x3 := x3 + 3;
  end;
  Result := 0;
end;

procedure VXE_RotateVoxelBufferHQ(const voxelbuffer: voxelbuffer_p;
  const fvoxelsize: Integer; const theta: double; const tmpbuffer: voxelbuffer_p);
var
  x, y, z: integer;
  x3, z3: integer;
  sinval, cosval: double;
  newx, newz: integer;
  c: voxelitem_t;
  buf: hqbuffer_p;
  buf2: hqbuffer_p;
  num: LongWord;
  r, g, b: LongWord;
  bigvoxelmid: double;
  i, j: integer;
  parms1: array[0..3] of rotateinfohq1_t;
begin
  sinval := sin(theta);
  cosval := cos(theta);
  MT_ZeroMemory(tmpbuffer, SizeOf(voxelbuffer_t));
  GetMem(buf, SizeOf(hqbuffer_t));
  GetMem(buf2, SizeOf(hqbuffer_t));

  bigvoxelmid := 3 * fvoxelsize / 2;

  for i := 0 to 3 do
  begin
    parms1[i].voxelbuffer := voxelbuffer;
    parms1[i].fvoxelsize := fvoxelsize;
    parms1[i].buf2 := buf2;
  end;
  parms1[0].start := 0;
  parms1[0].stop := fvoxelsize div 4;
  parms1[1].start := parms1[0].stop + 1;
  parms1[1].stop := fvoxelsize div 2;
  parms1[2].start := parms1[1].stop + 1;
  parms1[2].stop := (fvoxelsize * 3) div 4;
  parms1[3].start := parms1[2].stop + 1;
  parms1[3].stop := fvoxelsize - 1;

  for y := 0 to fvoxelsize - 1 do
  begin
    for i := 0 to 3 do
      parms1[i].y := y;

    MT_ZeroMemory(buf, SizeOf(hqbuffer_t));
    MT_ZeroMemory(buf2, SizeOf(hqbuffer_t));

    MT_Execute(
      @_rotate_voxel_hq1_thr, @parms1[0],
      @_rotate_voxel_hq1_thr, @parms1[1],
      @_rotate_voxel_hq1_thr, @parms1[2],
      @_rotate_voxel_hq1_thr, @parms1[3]
    );

    for x := 0 to 3 * fvoxelsize - 1 do
      for z := 0 to 3 * fvoxelsize - 1 do
      begin
        newx := round(bigvoxelmid + (x - bigvoxelmid) * cosval - (z - bigvoxelmid) * sinval);
        newz := round(bigvoxelmid + (x - bigvoxelmid) * sinval + (z - bigvoxelmid) * cosval);
        if (newx >= 0) and (newx < 3 * fvoxelsize) and (newz >= 0) and (newz < 3 * fvoxelsize) then
        begin
          c := buf2[newx, newz].color;
          if c <> 0 then
          begin
            buf[x, z].color := buf[x, z].color + c;
            buf[x, z].size := buf[x, z].size + 1;
          end;
        end;
      end;

    for x := 0 to fvoxelsize - 1 do
    begin
      x3 := x * 3;
      for z := 0 to fvoxelsize - 1 do
      begin
        z3 := z * 3;
        num := 0;
        r := 0;
        g := 0;
        b := 0;

        for i := 0 to 2 do
          for j := 0 to 2 do
          begin
            c := buf[x3 + i, z3 + j].color;
            if c <> 0 then
            begin
              if (i = 1) and (j = 1) then // Center has double weight value
              begin
                inc(num, 2 * buf[x3 + i, z3 + j].size);
                r := r + 2 * GetRValue(c);
                g := g + 2 * GetGValue(c);
                b := b + 2 * GetBValue(c);
              end
              else
              begin
                inc(num, buf[x3 + i, z3 + j].size);
                r := r + GetRValue(c);
                g := g + GetGValue(c);
                b := b + GetBValue(c);
              end;
            end;
          end;

        if num > 3 then
        begin
          r := r div num;
          if r > 255 then
            r := 255;
          g := g div num;
          if g > 255 then
            g := 255;
          b := b div num;
          if b > 255 then
            b := 255;
          if (r <> 0) or (g <> 0) or (b <> 0) then
            tmpbuffer[x, y, z] := RGB(r, g, b);
        end;
      end;
    end;

  end;

  FreeMem(buf, SizeOf(hqbuffer_t));
  FreeMem(buf2, SizeOf(hqbuffer_t));
end;

procedure SaveBmpAsPng(const b: TBitmap; const fname: string;
  const offsl: integer = MAXINT; const offst: integer = MAXINT);
var
  p: TPNGObject;
begin
  p := TPNGObject.Create;
  try
    p.TransparentColor := RGB(0, 0, 0);
    p.Assign(b);
    if offsl <> MAXINT then
      if offst <> MAXINT then
        p.AddgrAb(offsl, offst);
    p.SaveToFile(fname);
  finally
    p.Free;
  end;
end;

type
  patch_t = packed record
    width: smallint; // bounding box size
    height: smallint;
    leftoffset: smallint; // pixels to the left of origin
    topoffset: smallint;  // pixels below the origin
  end;

  column_t = packed record
    topdelta: byte; // -1 is the last post in a column
    length: byte;   // length data bytes follows
  end;

procedure SaveBmpAsPatch(const b: TBitmap; const palarray: PByteArray; const fname: string;
  const offsl: integer = MAXINT; const offst: integer = MAXINT);
var
  m: TMemoryStream;
  fs: TFileStream;
  patch: patch_t;
  column: column_t;
  columnofs: TDNumberList;
  columndata: TDNumberList;
  x, y: integer;
  palette: TPaletteArray;
  c: LongWord;
  i: integer;

  procedure flashcolumnend;
  begin
    column.topdelta := 255;
    column.length := 0;
    m.Write(column, SizeOf(column));
  end;

  procedure flashcolumndata;
  var
    ii: integer;
    bb: byte;
  begin
    if columndata.Count > 0 then
    begin
      column.topdelta := y - columndata.Count;
      column.length := columndata.Count;
      m.Write(column, SizeOf(column));
      bb := 0;
      m.Write(bb, SizeOf(bb));
      for ii := 0 to columndata.Count - 1 do
      begin
        bb := columndata.Numbers[ii];
        m.Write(bb, SizeOf(bb));
      end;
      bb := 0;
      m.Write(bb, SizeOf(bb));
      columndata.Clear;
    end;
  end;

begin
  for i := 0 to 255 do
    palette[i] := RGB(palarray[3 * i], palarray[3 * i + 1], palarray[3 * i + 2]);

  m := TMemoryStream.Create;
  fs := TFileStream.Create(fname, fmCreate);
  columnofs := TDNumberList.Create;
  columndata := TDNumberList.Create;
  try
    patch.width := b.Width;
    patch.height := b.Height;
    if offsl = MAXINT then
      patch.leftoffset := b.Width div 2
    else
      patch.leftoffset := offsl;
    if offst = MAXINT then
      patch.topoffset := b.Height
    else
      patch.topoffset := offst;
    fs.Write(patch, SizeOf(patch_t));

    for x := 0 to b.Width - 1 do
    begin
      columnofs.Add(m.Position + SizeOf(patch_t) + b.Width * SizeOf(integer));
      columndata.Clear;
      for y := 0 to b.Height - 1 do
      begin
        c := b.Canvas.Pixels[x, y];
        if c = 0 then
        begin
          flashcolumndata;
          continue;
        end;
        columndata.Add(VXE_FindAproxColorIndex(@palette, c))
      end;
      flashcolumndata;
      flashcolumnend;
    end;

    for i := 0 to columnofs.Count - 1 do
    begin
      x := columnofs.Numbers[i];
      fs.Write(x, SizeOf(integer));
    end;

    m.Position := 0;
    fs.CopyFrom(m, m.Size);

  finally
    m.Free;
    columnofs.Free;
    columndata.Free;
    fs.Free;
  end;
end;

procedure AddFileToPK3(const pk3: TZipFile; const fname: string);
var
  idx: integer;
  sdata: string;
  f: TFileStream;
  i: integer;
begin
  if not FileExists(fname) then
    exit;

  idx := pk3.AddFile(fname);
  f := TFileStream.Create(fname, fmOpenRead);
  try
    SetLength(sdata, f.Size);
    for i := 1 to Length(sdata) do
      f.Read(sdata[i], 1);
    pk3.Data[idx] := sdata;
    pk3.DateTime[idx] := Now();
    SetLength(sdata, 0);
  finally
    f.Free;
  end;
end;

procedure VXE_ExportVoxelToSprite1(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string);
var
  b1: TBitmap;
  pk3: TZipFile;
  wad: TWadWriter;
  pal: PByteArray;
  h_start, h_end: string;
begin
  ProgressStart('Export Voxel to Sprite', 7);
  b1 := VXE_ExportGetFront(voxelbuffer, fvoxelsize);  ProgressStep;

  h_start := '';
  h_end := '';
  if UpperCase(sprformat) = 'PNG' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    SaveBmpAsPng(b1, patchprefix + '0.' + sprformat); ProgressStep;
  end
  else if UpperCase(sprformat) = 'LMP' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    pal := VXE_GetRowPalette(gamepalette);
    SaveBmpAsPatch(b1, pal, patchprefix + '0.' + sprformat); ProgressStep;
  end;

  b1.Free;

  if UpperCase(ftype) = 'PK3' then
  begin
    pk3 := TZipFile.Create;
    try
      AddFileToPK3(pk3, patchprefix + '0.' + sprformat); ProgressStep;
      BackupFile(pk3filename);
      pk3.SaveToFile(pk3filename); ProgressStep;
    finally
      pk3.Free;
    end;
  end
  else if UpperCase(ftype) = 'WAD' then
  begin
    wad := TWadWriter.Create;
    try
      if h_start <> '' then
        wad.AddSeparator(h_start);
      wad.AddFile(patchprefix + '0', patchprefix + '0.' + sprformat); ProgressStep;
      if h_end <> '' then
        wad.AddSeparator(h_end);
      BackupFile(pk3filename);
      wad.SaveToFile(pk3filename); ProgressStep;
    finally
      wad.Free;
    end;
  end;

  DeleteFile(patchprefix + '0.' + sprformat); ProgressStep;
  ProgressStop;
end;

procedure VXE_ExportVoxelToSprite8(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string);
var
  b1, b2, b3, b4, b5, b6, b7, b8: TBitmap;
  tmpbuffer: voxelbuffer_p;
  pk3: TZipFile;
  wad: TWadWriter;
  pal: PByteArray;
  h_start, h_end: string;
begin
  ProgressStart('Export Voxel to Sprite', 33);
  b1 := VXE_ExportGetFront(voxelbuffer, fvoxelsize);  ProgressStep;
  b3 := VXE_ExportGetRight(voxelbuffer, fvoxelsize);  ProgressStep;
  b5 := VXE_ExportGetBack(voxelbuffer, fvoxelsize);   ProgressStep;
  b7 := VXE_ExportGetLeft(voxelbuffer, fvoxelsize);   ProgressStep;

  tmpbuffer := vox_getbuffer;
  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, pi / 4, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, pi / 4, tmpbuffer);
  ProgressStep;
  b2 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b4 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b6 := VXE_ExportGetBack(tmpbuffer, fvoxelsize);  ProgressStep;
  b8 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize);  ProgressStep;
  vox_freebuffer(tmpbuffer);

  h_start := '';
  h_end := '';
  if UpperCase(sprformat) = 'PNG' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    SaveBmpAsPng(b1, patchprefix + '1.' + sprformat); ProgressStep;
    SaveBmpAsPng(b2, patchprefix + '2.' + sprformat); ProgressStep;
    SaveBmpAsPng(b3, patchprefix + '3.' + sprformat); ProgressStep;
    SaveBmpAsPng(b4, patchprefix + '4.' + sprformat); ProgressStep;
    SaveBmpAsPng(b5, patchprefix + '5.' + sprformat); ProgressStep;
    SaveBmpAsPng(b6, patchprefix + '6.' + sprformat); ProgressStep;
    SaveBmpAsPng(b7, patchprefix + '7.' + sprformat); ProgressStep;
    SaveBmpAsPng(b8, patchprefix + '8.' + sprformat); ProgressStep;
  end
  else if UpperCase(sprformat) = 'LMP' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    pal := VXE_GetRowPalette(gamepalette);
    SaveBmpAsPatch(b1, pal, patchprefix + '1.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b2, pal, patchprefix + '2.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b3, pal, patchprefix + '3.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b4, pal, patchprefix + '4.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b5, pal, patchprefix + '5.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b6, pal, patchprefix + '6.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b7, pal, patchprefix + '7.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b8, pal, patchprefix + '8.' + sprformat); ProgressStep;
  end;

  b1.Free;
  b2.Free;
  b3.Free;
  b4.Free;
  b5.Free;
  b6.Free;
  b7.Free;
  b8.Free;

  if UpperCase(ftype) = 'PK3' then
  begin
    pk3 := TZipFile.Create;
    try
      AddFileToPK3(pk3, patchprefix + '1.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '2.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '3.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '4.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '5.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '6.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '7.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '8.' + sprformat); ProgressStep;
      BackupFile(pk3filename);
      pk3.SaveToFile(pk3filename); ProgressStep;
    finally
      pk3.Free;
    end;
  end
  else if UpperCase(ftype) = 'WAD' then
  begin
    wad := TWadWriter.Create;
    try
      if h_start <> '' then
        wad.AddSeparator(h_start);
      wad.AddFile(patchprefix + '1', patchprefix + '1.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '2', patchprefix + '2.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '3', patchprefix + '3.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '4', patchprefix + '4.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '5', patchprefix + '5.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '6', patchprefix + '6.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '7', patchprefix + '7.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '8', patchprefix + '8.' + sprformat); ProgressStep;
      if h_end <> '' then
        wad.AddSeparator(h_end);
      BackupFile(pk3filename);
      wad.SaveToFile(pk3filename); ProgressStep;
    finally
      wad.Free;
    end;
  end;

  DeleteFile(patchprefix + '1.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '2.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '3.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '4.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '5.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '6.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '7.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '8.' + sprformat); ProgressStep;
  ProgressStop;
end;

procedure VXE_ExportVoxelToSprite16(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string);
var
  b01, b02, b03, b04, b05, b06, b07, b08: TBitmap;
  b09, b10, b11, b12, b13, b14, b15, b16: TBitmap;
  tmpbuffer: voxelbuffer_p;
  pk3: TZipFile;
  wad: TWadWriter;
  pal: PByteArray;
  h_start, h_end: string;
begin
  ProgressStart('Export Voxel to Sprite', 68);
  b01 := VXE_ExportGetFront(voxelbuffer, fvoxelsize); ProgressStep;
  b03 := VXE_ExportGetRight(voxelbuffer, fvoxelsize); ProgressStep;
  b05 := VXE_ExportGetBack(voxelbuffer, fvoxelsize); ProgressStep;
  b07 := VXE_ExportGetLeft(voxelbuffer, fvoxelsize); ProgressStep;

  tmpbuffer := vox_getbuffer;
  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, pi / 4, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, pi / 4, tmpbuffer);
  ProgressStep;
  b02 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b04 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b06 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b08 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, pi / 8, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, pi / 8, tmpbuffer);
  ProgressStep;
  b09 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b11 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b13 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b15 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, pi / 4 + pi / 8, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, pi / 4 + pi / 8, tmpbuffer);
   ProgressStep;
  b10 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b12 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b14 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b16 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  vox_freebuffer(tmpbuffer);

  h_start := '';
  h_end := '';
  if UpperCase(sprformat) = 'PNG' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    SaveBmpAsPng(b01, patchprefix + '1.' + sprformat); ProgressStep;
    SaveBmpAsPng(b02, patchprefix + '2.' + sprformat); ProgressStep;
    SaveBmpAsPng(b03, patchprefix + '3.' + sprformat); ProgressStep;
    SaveBmpAsPng(b04, patchprefix + '4.' + sprformat); ProgressStep;
    SaveBmpAsPng(b05, patchprefix + '5.' + sprformat); ProgressStep;
    SaveBmpAsPng(b06, patchprefix + '6.' + sprformat); ProgressStep;
    SaveBmpAsPng(b07, patchprefix + '7.' + sprformat); ProgressStep;
    SaveBmpAsPng(b08, patchprefix + '8.' + sprformat); ProgressStep;
    SaveBmpAsPng(b09, patchprefix + '9.' + sprformat); ProgressStep;
    SaveBmpAsPng(b10, patchprefix + 'A.' + sprformat); ProgressStep;
    SaveBmpAsPng(b11, patchprefix + 'B.' + sprformat); ProgressStep;
    SaveBmpAsPng(b12, patchprefix + 'C.' + sprformat); ProgressStep;
    SaveBmpAsPng(b13, patchprefix + 'D.' + sprformat); ProgressStep;
    SaveBmpAsPng(b14, patchprefix + 'E.' + sprformat); ProgressStep;
    SaveBmpAsPng(b15, patchprefix + 'F.' + sprformat); ProgressStep;
    SaveBmpAsPng(b16, patchprefix + 'G.' + sprformat); ProgressStep;
  end
  else if UpperCase(sprformat) = 'LMP' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    pal := VXE_GetRowPalette(gamepalette);
    SaveBmpAsPatch(b01, pal, patchprefix + '1.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b02, pal, patchprefix + '2.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b03, pal, patchprefix + '3.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b04, pal, patchprefix + '4.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b05, pal, patchprefix + '5.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b06, pal, patchprefix + '6.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b07, pal, patchprefix + '7.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b08, pal, patchprefix + '8.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b09, pal, patchprefix + '9.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b10, pal, patchprefix + 'A.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b11, pal, patchprefix + 'B.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b12, pal, patchprefix + 'C.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b13, pal, patchprefix + 'D.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b14, pal, patchprefix + 'E.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b15, pal, patchprefix + 'F.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b16, pal, patchprefix + 'G.' + sprformat); ProgressStep;
  end;

  b01.Free;
  b02.Free;
  b03.Free;
  b04.Free;
  b05.Free;
  b06.Free;
  b07.Free;
  b08.Free;
  b09.Free;
  b10.Free;
  b11.Free;
  b12.Free;
  b13.Free;
  b14.Free;
  b15.Free;
  b16.Free;

  if UpperCase(ftype) = 'PK3' then
  begin
    pk3 := TZipFile.Create;
    try
      AddFileToPK3(pk3, patchprefix + '1.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '2.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '3.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '4.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '5.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '6.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '7.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '8.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '9.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'A.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'B.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'C.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'D.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'E.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'F.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'G.' + sprformat); ProgressStep;
      BackupFile(pk3filename);
      pk3.SaveToFile(pk3filename); ProgressStep;
    finally
      pk3.Free;
    end;
  end
  else if UpperCase(ftype) = 'WAD' then
  begin
    wad := TWadWriter.Create;
    try
      if h_start <> '' then
        wad.AddSeparator(h_start);
      wad.AddFile(patchprefix + '1', patchprefix + '1.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '2', patchprefix + '2.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '3', patchprefix + '3.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '4', patchprefix + '4.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '5', patchprefix + '5.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '6', patchprefix + '6.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '7', patchprefix + '7.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '8', patchprefix + '8.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '9', patchprefix + '9.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'A', patchprefix + 'A.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'B', patchprefix + 'B.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'C', patchprefix + 'C.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'D', patchprefix + 'D.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'E', patchprefix + 'E.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'F', patchprefix + 'F.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'G', patchprefix + 'G.' + sprformat); ProgressStep;
      if h_end <> '' then
        wad.AddSeparator(h_end);
      BackupFile(pk3filename);
      wad.SaveToFile(pk3filename); ProgressStep;
    finally
      wad.Free;
    end;
  end;

  DeleteFile(patchprefix + '1.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '2.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '3.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '4.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '5.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '6.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '7.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '8.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '9.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'A.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'B.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'C.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'D.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'E.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'F.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'G.' + sprformat); ProgressStep;
  ProgressStop;
end;

procedure VXE_ExportVoxelToSprite32(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string);
var
  b01, b02, b03, b04, b05, b06, b07, b08: TBitmap;
  b09, b10, b11, b12, b13, b14, b15, b16: TBitmap;
  b17, b18, b19, b20, b21, b22, b23, b24: TBitmap;
  b25, b26, b27, b28, b29, b30, b31, b32: TBitmap;
  tmpbuffer: voxelbuffer_p;
  pk3: TZipFile;
  wad: TWadWriter;
  pal: PByteArray;
  h_start, h_end: string;
begin
  ProgressStart('Export Voxel to Sprite', 135);
  b01 := VXE_ExportGetFront(voxelbuffer, fvoxelsize); ProgressStep;
  b03 := VXE_ExportGetRight(voxelbuffer, fvoxelsize); ProgressStep;
  b05 := VXE_ExportGetBack(voxelbuffer, fvoxelsize); ProgressStep;
  b07 := VXE_ExportGetLeft(voxelbuffer, fvoxelsize); ProgressStep;

  tmpbuffer := vox_getbuffer;
  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, pi / 4, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, pi / 4, tmpbuffer);
  ProgressStep;
  b02 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b04 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b06 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b08 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, pi / 8, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, pi / 8, tmpbuffer);
  ProgressStep;
  b09 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b11 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b13 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b15 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, pi / 4 + pi / 8, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, pi / 4 + pi / 8, tmpbuffer);
  ProgressStep;
  b10 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b12 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b14 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b16 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, pi / 16, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, pi / 16, tmpbuffer);
  ProgressStep;
  b17 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b21 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b25 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b29 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, 3 * pi / 16, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, 3 * pi / 16, tmpbuffer);
  ProgressStep;
  b18 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b22 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b26 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b30 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, 5 * pi / 16, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, 5 * pi / 16, tmpbuffer);
  ProgressStep;
  b19 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b23 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b27 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b31 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  if hq then
    VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, 7 * pi / 16, tmpbuffer)
  else
    VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, 7 * pi / 16, tmpbuffer);
  ProgressStep;
  b20 := VXE_ExportGetFront(tmpbuffer, fvoxelsize); ProgressStep;
  b24 := VXE_ExportGetRight(tmpbuffer, fvoxelsize); ProgressStep;
  b28 := VXE_ExportGetBack(tmpbuffer, fvoxelsize); ProgressStep;
  b32 := VXE_ExportGetLeft(tmpbuffer, fvoxelsize); ProgressStep;

  vox_freebuffer(tmpbuffer);

  h_start := '';
  h_end := '';
  if UpperCase(sprformat) = 'PNG' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    SaveBmpAsPng(b01, patchprefix + '1.' + sprformat); ProgressStep;
    SaveBmpAsPng(b02, patchprefix + '2.' + sprformat); ProgressStep;
    SaveBmpAsPng(b03, patchprefix + '3.' + sprformat); ProgressStep;
    SaveBmpAsPng(b04, patchprefix + '4.' + sprformat); ProgressStep;
    SaveBmpAsPng(b05, patchprefix + '5.' + sprformat); ProgressStep;
    SaveBmpAsPng(b06, patchprefix + '6.' + sprformat); ProgressStep;
    SaveBmpAsPng(b07, patchprefix + '7.' + sprformat); ProgressStep;
    SaveBmpAsPng(b08, patchprefix + '8.' + sprformat); ProgressStep;
    SaveBmpAsPng(b09, patchprefix + '9.' + sprformat); ProgressStep;
    SaveBmpAsPng(b10, patchprefix + 'A.' + sprformat); ProgressStep;
    SaveBmpAsPng(b11, patchprefix + 'B.' + sprformat); ProgressStep;
    SaveBmpAsPng(b12, patchprefix + 'C.' + sprformat); ProgressStep;
    SaveBmpAsPng(b13, patchprefix + 'D.' + sprformat); ProgressStep;
    SaveBmpAsPng(b14, patchprefix + 'E.' + sprformat); ProgressStep;
    SaveBmpAsPng(b15, patchprefix + 'F.' + sprformat); ProgressStep;
    SaveBmpAsPng(b16, patchprefix + 'G.' + sprformat); ProgressStep;
    SaveBmpAsPng(b17, patchprefix + 'H.' + sprformat); ProgressStep;
    SaveBmpAsPng(b18, patchprefix + 'I.' + sprformat); ProgressStep;
    SaveBmpAsPng(b19, patchprefix + 'J.' + sprformat); ProgressStep;
    SaveBmpAsPng(b20, patchprefix + 'K.' + sprformat); ProgressStep;
    SaveBmpAsPng(b21, patchprefix + 'L.' + sprformat); ProgressStep;
    SaveBmpAsPng(b22, patchprefix + 'M.' + sprformat); ProgressStep;
    SaveBmpAsPng(b23, patchprefix + 'N.' + sprformat); ProgressStep;
    SaveBmpAsPng(b24, patchprefix + 'O.' + sprformat); ProgressStep;
    SaveBmpAsPng(b25, patchprefix + 'P.' + sprformat); ProgressStep;
    SaveBmpAsPng(b26, patchprefix + 'Q.' + sprformat); ProgressStep;
    SaveBmpAsPng(b27, patchprefix + 'R.' + sprformat); ProgressStep;
    SaveBmpAsPng(b28, patchprefix + 'S.' + sprformat); ProgressStep;
    SaveBmpAsPng(b29, patchprefix + 'T.' + sprformat); ProgressStep;
    SaveBmpAsPng(b30, patchprefix + 'U.' + sprformat); ProgressStep;
    SaveBmpAsPng(b31, patchprefix + 'V.' + sprformat); ProgressStep;
    SaveBmpAsPng(b32, patchprefix + 'W.' + sprformat); ProgressStep;
  end
  else if UpperCase(sprformat) = 'LMP' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    pal := VXE_GetRowPalette(gamepalette);
    SaveBmpAsPatch(b01, pal, patchprefix + '1.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b02, pal, patchprefix + '2.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b03, pal, patchprefix + '3.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b04, pal, patchprefix + '4.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b05, pal, patchprefix + '5.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b06, pal, patchprefix + '6.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b07, pal, patchprefix + '7.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b08, pal, patchprefix + '8.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b09, pal, patchprefix + '9.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b10, pal, patchprefix + 'A.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b11, pal, patchprefix + 'B.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b12, pal, patchprefix + 'C.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b13, pal, patchprefix + 'D.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b14, pal, patchprefix + 'E.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b15, pal, patchprefix + 'F.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b16, pal, patchprefix + 'G.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b17, pal, patchprefix + 'H.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b18, pal, patchprefix + 'I.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b19, pal, patchprefix + 'J.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b20, pal, patchprefix + 'K.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b21, pal, patchprefix + 'L.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b22, pal, patchprefix + 'M.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b23, pal, patchprefix + 'N.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b24, pal, patchprefix + 'O.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b25, pal, patchprefix + 'P.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b26, pal, patchprefix + 'Q.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b27, pal, patchprefix + 'R.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b28, pal, patchprefix + 'S.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b29, pal, patchprefix + 'T.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b30, pal, patchprefix + 'U.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b31, pal, patchprefix + 'V.' + sprformat); ProgressStep;
    SaveBmpAsPatch(b32, pal, patchprefix + 'W.' + sprformat); ProgressStep;
  end;

  b01.Free;
  b02.Free;
  b03.Free;
  b04.Free;
  b05.Free;
  b06.Free;
  b07.Free;
  b08.Free;
  b09.Free;
  b10.Free;
  b11.Free;
  b12.Free;
  b13.Free;
  b14.Free;
  b15.Free;
  b16.Free;
  b17.Free;
  b18.Free;
  b19.Free;
  b20.Free;
  b21.Free;
  b22.Free;
  b23.Free;
  b24.Free;
  b25.Free;
  b26.Free;
  b27.Free;
  b28.Free;
  b29.Free;
  b30.Free;
  b31.Free;
  b32.Free;

  if UpperCase(ftype) = 'PK3' then
  begin
    pk3 := TZipFile.Create;
    try
      AddFileToPK3(pk3, patchprefix + '1.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '2.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '3.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '4.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '5.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '6.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '7.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '8.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + '9.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'A.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'B.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'C.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'D.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'E.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'F.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'G.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'H.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'I.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'J.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'K.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'L.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'M.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'N.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'O.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'P.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'Q.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'R.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'S.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'T.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'U.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'V.' + sprformat); ProgressStep;
      AddFileToPK3(pk3, patchprefix + 'W.' + sprformat); ProgressStep;
      BackupFile(pk3filename);
      pk3.SaveToFile(pk3filename); ProgressStep;
    finally
      pk3.Free;
    end;
  end
  else if UpperCase(ftype) = 'WAD' then
  begin
    wad := TWadWriter.Create;
    try
      if h_start <> '' then
        wad.AddSeparator(h_start);
      wad.AddFile(patchprefix + '1', patchprefix + '1.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '2', patchprefix + '2.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '3', patchprefix + '3.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '4', patchprefix + '4.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '5', patchprefix + '5.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '6', patchprefix + '6.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '7', patchprefix + '7.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '8', patchprefix + '8.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + '9', patchprefix + '9.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'A', patchprefix + 'A.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'B', patchprefix + 'B.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'C', patchprefix + 'C.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'D', patchprefix + 'D.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'E', patchprefix + 'E.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'F', patchprefix + 'F.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'G', patchprefix + 'G.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'H', patchprefix + 'H.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'I', patchprefix + 'I.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'J', patchprefix + 'J.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'K', patchprefix + 'K.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'L', patchprefix + 'L.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'M', patchprefix + 'M.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'N', patchprefix + 'N.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'O', patchprefix + 'O.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'P', patchprefix + 'P.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'Q', patchprefix + 'Q.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'R', patchprefix + 'R.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'S', patchprefix + 'S.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'T', patchprefix + 'T.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'U', patchprefix + 'U.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'V', patchprefix + 'V.' + sprformat); ProgressStep;
      wad.AddFile(patchprefix + 'W', patchprefix + 'W.' + sprformat); ProgressStep;
      if h_end <> '' then
        wad.AddSeparator(h_end);
      BackupFile(pk3filename);
      wad.SaveToFile(pk3filename); ProgressStep;
    finally
      wad.Free;
    end;
  end;

  DeleteFile(patchprefix + '1.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '2.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '3.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '4.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '5.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '6.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '7.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '8.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + '9.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'A.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'B.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'C.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'D.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'E.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'F.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'G.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'H.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'I.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'J.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'K.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'L.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'M.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'N.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'O.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'P.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'Q.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'R.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'S.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'T.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'U.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'V.' + sprformat); ProgressStep;
  DeleteFile(patchprefix + 'W.' + sprformat); ProgressStep;
  ProgressStop;
end;

type
  zbufitem_t = record
    zbuffer: integer;
    color: voxelitem_t;
  end;
  zbuffer_t = array[0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1] of zbufitem_t;

var
  zbuffer: zbuffer_t;

function VXE_ExportGetFrontPerspective(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const ebuffer: voxelbuffer_p; const adist: integer = 1024; const aheight: integer = 41): TBitmap;
var
  x, y, z: integer;
  x1, y1: integer;
  v1: array[0..2] of integer;
  startx, starty, startz: integer;
  c: LongWord;

  procedure getvoxprojection(const xx: integer; const yy: integer; const zz: integer; var nx, ny: integer);
  var
    v2: array[0..2] of integer;
    slope: double;
  begin
    v2[0] := xx;
    v2[1] := yy;
    v2[2] := zz;

    slope := (v2[0] - v1[0]) / (v2[2] - v1[2]);
    nx := GetIntInRange(round(slope * adist) + v1[0], 0, MAXVOXELSIZE - 1);
    slope := (v2[1] - v1[1]) / (v2[2] - v1[2]);
    ny := GetIntInRange(round(slope * adist) + v1[1], 0, MAXVOXELSIZE - 1);
  end;

begin
  result := TBitmap.Create;
  result.Width := MAXVOXELSIZE;
  result.Height := MAXVOXELSIZE;
  result.PixelFormat := pf24bit;
  result.Canvas.Brush.Color := clBlack;
  result.Canvas.Brush.Style := bsSolid;
  result.Canvas.FillRect(Rect(0, 0, MAXVOXELSIZE, MAXVOXELSIZE));

  MT_ZeroMemory(ebuffer, SizeOf(voxelbuffer_t));

  startx := (MAXVOXELSIZE - fvoxelsize) div 2;
  starty := MAXVOXELSIZE - fvoxelsize;
  startz := (MAXVOXELSIZE - fvoxelsize) div 2;

  for x := 0 to fvoxelsize - 1 do
    for y := 0 to fvoxelsize - 1 do
    begin
      for z := 0 to fvoxelsize - 1 do
        ebuffer[startx + x, starty + y, startz + z] := voxelbuffer[x, y, z];
    end;

  for x := 0 to MAXVOXELSIZE - 1 do
    for y := 0 to MAXVOXELSIZE - 1 do
    begin
      zbuffer[x, y].zbuffer := MAXVOXELSIZE + 1;
      zbuffer[x, y].color := 0;
    end;

  v1[0] := MAXVOXELSIZE div 2;
  v1[1] := MAXVOXELSIZE - aheight;
  v1[2] := -adist;

  for x := 0 to MAXVOXELSIZE - 1 do
    for y := 0 to MAXVOXELSIZE - 1 do
    begin
      x1 := x;
      y1 := y;
      for z := 0 to MAXVOXELSIZE - 1 do
      begin
        if ebuffer[x, y, z] <> 0 then
        begin
          getvoxprojection(x, y, z, x1, y1);
          if zbuffer[x1, y1].zbuffer > z then
          begin
            zbuffer[x1, y1].color := ebuffer[x, y, z];
            zbuffer[x1, y1].zbuffer := z;
            //Break;
          end;
         end;
      end;
    end;

  for x := 0 to MAXVOXELSIZE - 1 do
    for y := 0 to MAXVOXELSIZE - 1 do
    begin
      c := zbuffer[x, y].color;
      if c <> 0 then
        result.Canvas.Pixels[x, y] := c;
    end;
end;

procedure VXE_GetPerspectiveOffsets(const adist, aheight: integer;
  var offsl, offst: integer);
begin
  offsl := MAXVOXELSIZE div 2;
  offst := Round(aheight / (adist + MAXVOXELSIZE / 2) * adist + MAXVOXELSIZE - aheight);
end;

procedure VXE_ExportVoxelToSpritePerspective1(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string; const adist: integer = 1024; const aheight: integer = 41);
var
  bs: TBitmap;
  pk3: TZipFile;
  wad: TWadWriter;
  pal: PByteArray;
  h_start, h_end: string;
  offsl, offst: integer;
  ebuffer: voxelbuffer_p;
begin
  ProgressStart('Export Voxel to Sprite', 5);
  ebuffer := vox_getbuffer;
  bs := VXE_ExportGetFrontPerspective(voxelbuffer, fvoxelsize, ebuffer, adist, aheight); ProgressStep;

  VXE_GetPerspectiveOffsets(adist, aheight, offsl, offst);
  h_start := '';
  h_end := '';
  if UpperCase(sprformat) = 'PNG' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    SaveBmpAsPng(bs, patchprefix + '0.' + sprformat, offsl, offst); ProgressStep;
  end
  else if UpperCase(sprformat) = 'LMP' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    pal := VXE_GetRowPalette(gamepalette);
    SaveBmpAsPatch(bs, pal, patchprefix + '0.' + sprformat, offsl, offst); ProgressStep;
  end;

  bs.Free;

  if UpperCase(ftype) = 'PK3' then
  begin
    pk3 := TZipFile.Create;
    try
      AddFileToPK3(pk3, patchprefix + '0.' + sprformat); ProgressStep;
      BackupFile(pk3filename);
      pk3.SaveToFile(pk3filename); ProgressStep;
    finally
      pk3.Free;
    end;
  end
  else if UpperCase(ftype) = 'WAD' then
  begin
    wad := TWadWriter.Create;
    try
      if h_start <> '' then
        wad.AddSeparator(h_start);
      wad.AddFile(patchprefix + '0', patchprefix + '0.' + sprformat); ProgressStep;
      if h_end <> '' then
        wad.AddSeparator(h_end);
      BackupFile(pk3filename);
      wad.SaveToFile(pk3filename); ProgressStep;
    finally
      wad.Free;
    end;
  end;

  DeleteFile(patchprefix + '0.' + sprformat); ProgressStep;
  vox_freebuffer(ebuffer);
  ProgressStop;
end;

// JVAL: Up to 32 sprite rotations
const
  translaterotations: array[1..3] of array [0..31] of integer = (
    ( 0,  1,  2,  3,  4,  5,  6,  7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    ( 0,  8,  1,  9,  2, 10,  3, 11,  4, 12,  5, 13,  6, 14,  7, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    ( 0, 16,  8, 17,  1, 18,  9, 19,  2, 20, 10, 21,  3, 22, 11, 23,  4, 24, 12, 25,  5, 26, 13, 27,  6, 28, 14, 29,  7, 30, 15, 31)
  );

const
  sframes: string = '123456789ABCDEFGHIJKLMNOPQRSTUVW';

procedure VXE_ExportVoxelToSpritePerspective(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  const pk3filename: string; const ftype: string; const hq: boolean; const sprformat: string; const patchprefix: string;
  const gamepalette: string; const rotations: integer; const adist: integer = 1024; const aheight: integer = 41);
var
  bs: array[0..31] of TBitmap;
  tmpbuffer: voxelbuffer_p;
  pk3: TZipFile;
  wad: TWadWriter;
  pal: PByteArray;
  h_start, h_end: string;
  i: integer;
  idx: integer;
  offsl, offst: integer;
  ebuffer: voxelbuffer_p;
begin
  case rotations of
     8: idx := 1;
    16: idx := 2;
    32: idx := 3;
  else
    exit;
  end;

  ProgressStart('Export Voxel to Sprite', 5 * rotations + 1);
  ebuffer := vox_getbuffer;
  bs[0] := VXE_ExportGetFrontPerspective(voxelbuffer, fvoxelsize, ebuffer, adist, aheight); ProgressStep;

  tmpbuffer := vox_getbuffer;
  for i := 1 to rotations - 1 do
  begin
    if hq then
      VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, 2 * pi / rotations * i, tmpbuffer)
    else
      VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, 2 * pi / rotations * i, tmpbuffer);
    ProgressStep;
    bs[translaterotations[idx, i]] := VXE_ExportGetFrontPerspective(tmpbuffer, fvoxelsize, ebuffer, adist, aheight);
    ProgressStep;
  end;
  vox_freebuffer(tmpbuffer);

  VXE_GetPerspectiveOffsets(adist, aheight, offsl, offst);
  h_start := '';
  h_end := '';
  if UpperCase(sprformat) = 'PNG' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    for i := 0 to rotations - 1 do
    begin
      SaveBmpAsPng(bs[translaterotations[idx, i]], patchprefix + sframes[translaterotations[idx, i] + 1] + '.' + sprformat, offsl, offst);
      ProgressStep;
    end;
  end
  else if UpperCase(sprformat) = 'LMP' then
  begin
    h_start := 'S_START';
    h_end := 'S_END';
    pal := VXE_GetRowPalette(gamepalette);
    for i := 0 to rotations - 1 do
    begin
      SaveBmpAsPatch(bs[translaterotations[idx, i]], pal, patchprefix + sframes[translaterotations[idx, i] + 1] + '.' + sprformat, offsl, offst);
      ProgressStep;
    end;
  end;

  for i := 0 to rotations - 1 do
    bs[i].Free;

  if UpperCase(ftype) = 'PK3' then
  begin
    pk3 := TZipFile.Create;
    try
      for i := 1 to rotations do
      begin
        AddFileToPK3(pk3, patchprefix + sframes[i] + '.' + sprformat);
        ProgressStep;
      end;
      BackupFile(pk3filename);
      pk3.SaveToFile(pk3filename); ProgressStep;
    finally
      pk3.Free;
    end;
  end
  else if UpperCase(ftype) = 'WAD' then
  begin
    wad := TWadWriter.Create;
    try
      if h_start <> '' then
        wad.AddSeparator(h_start);
      for i := 1 to rotations do
      begin
        wad.AddFile(patchprefix + sframes[i], patchprefix + sframes[i] + '.' + sprformat);
        ProgressStep;
      end;
      if h_end <> '' then
        wad.AddSeparator(h_end);
      BackupFile(pk3filename);
      wad.SaveToFile(pk3filename); ProgressStep;
    finally
      wad.Free;
    end;
  end;

  for i := 1 to rotations do
  begin
    DeleteFile(patchprefix + sframes[i] + '.' + sprformat);
    ProgressStep;
  end;
  vox_freebuffer(ebuffer);
  ProgressStop;
end;

procedure VXE_ExportVoxelToSlab6VOX(const voxelbuffer: voxelbuffer_p; const voxelsize: Integer;
  const fname: string);
var
  i: integer;
  fvoxelsize: Integer;
  x, y, z: integer;
  x1, x2, y1, y2, z1, z2: integer;
  voxdata: PByteArray;
  voxsize: integer;
  dpal: array[0..767] of byte;
  vpal: TPaletteArray;
  fs: TFileStream;
  c: LongWord;
begin
  if voxelsize >= 256 then
  begin
    x1 := 1; x2 := 255;
    y1 := 1; y2 := 255;
    z1 := 1; z2 := 255;
    fvoxelsize := 255
  end
  else
  begin
    x1 := 0; x2 := voxelsize - 1;
    y1 := 0; y2 := voxelsize - 1;
    z1 := 0; z2 := voxelsize - 1;
    fvoxelsize := voxelsize;
  end;
  voxsize := fvoxelsize * fvoxelsize * fvoxelsize;
  GetMem(voxdata, voxsize);

  for i := 0 to 255 do
    vpal[i] := 0;

  if vxe_getquantizevoxelpalette(voxelbuffer, voxelsize, vpal, 255) then
  begin
    for i := 0 to 255 do
    begin
      c := vpal[i];
      dpal[3 * i] := GetRValue(c);
      dpal[3 * i + 1] := GetGValue(c);
      dpal[3 * i + 2] := GetBValue(c);
    end;
  end
  else
  begin
    for i := 0 to 764 do
      dpal[i] := DoomPaletteRaw[i + 3];
    for i := 765 to 767 do
      dpal[i] := 0;
    for i := 0 to 254 do
      vpal[i] := RGB(dpal[3 * i], dpal[3 * i + 1], dpal[3 * i + 2]);
  end;

  fs := TFileStream.Create(fname, fmCreate);
  try
    for i := 0 to 2 do
      fs.Write(fvoxelsize, SizeOf(integer));
    i := 0;
    for x := x1 to x2 do
      for y := y1 to y2 do
        for z := z1 to z2 do
        begin
          c := voxelbuffer[x, z, fvoxelsize - 1 - y];
          if c = 0 then
            voxdata[i] := 255
          else
            voxdata[i] := VXE_FindAproxColorIndex(@vpal, c, 0, 254);
          inc(i);
        end;
    fs.Write(voxdata^, voxsize);
    fs.Write(dpal, 768);
  finally
    fs.Free;
  end;

  FreeMem(voxdata, voxsize);
end;

end.
