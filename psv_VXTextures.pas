//------------------------------------------------------------------------------
//
//  DD_VOXEL: DelphiDoom Voxel Editor
//  Copyright (C) 2013-2018 by Jim Valavanis
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
//  Texture Manager RTL object
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit psv_VXTextures;

interface

uses
  Classes, uPSCompiler, uPSRuntime;

type
  TPixelArray = array[0..$FFFF] of LongWord;
  PPixelArray = ^TPixelArray;

  TVXTexture = class(TObject)
  private
    tmpfilename: string;
    originalfilename: string;
    fwidth: integer;
    fheight: integer;
    fscaledwidth: integer;
    fscaledheight: integer;
    fbuffer: PPixelArray;
    fdormant: boolean;
  protected
    procedure SetDormant(const value: boolean); virtual;
    function DoLoadImage(const tname: string): boolean; virtual;
  public
    constructor Create(const afilename: string); virtual;
    destructor Destroy; override;
    function Pixels(const x, y: integer): LongWord;
    procedure ScaleTo(x, y: integer);
    property Width: integer read fwidth;
    property Height: integer read fheight;
    property ScaledWidth: integer read fscaledwidth;
    property ScaledHeight: integer read fscaledheight;
    property dormant: boolean read fdormant write SetDormant;
  end;

  TVXTextures = class(TObject)
  private
    ftextures: TStringList;
    fcache: TStringList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear;
    function RTLGetTexture(tname: string): LongWord;
  end;

procedure SIRegister_VXTextures(CL: TPSPascalCompiler);

procedure RIRegister_VXTextures(CL: TPSRuntimeClassImporter);

procedure RIRegisterRTL_VXTextures(Exec: TPSExec);

procedure VXT_ResetTextures;

implementation

uses
  SysUtils, Graphics, psv_voxel, jpeg, xDIB, pcximage, pngimage, xGIF, xTGA,
  xPPM, zBitmap, vxe_tmp, psv_script_functions, psv_temp;

// -----------------------------------------------------------------------------
// TVXTexture
// -----------------------------------------------------------------------------
constructor TVXTexture.Create(const afilename: string);
begin
  tmpfilename := '';
  fwidth := 0;
  fheight := 0;
  fbuffer := nil;
  fdormant := False;
  DoLoadImage(afilename);
  fscaledwidth := fwidth;
  fscaledheight := fheight;
  originalfilename := afilename;
  Inherited Create;
end;

destructor TVXTexture.Destroy;
begin
  if tmpfilename <> '' then
    if FileExists(tmpfilename) then
      DeleteFile(tmpfilename);
  ReallocMem(fbuffer, 0);
  Inherited;
end;

resourcestring
  rsExtBMP = '.bmp';
  rsExtPNG = '.png';
  rsExtJPG1 = '.jpg';
  rsExtJPG2 = '.jpeg';
  rsExtPCX = '.pcx';
  rsExtPPM = '.ppm';
  rsExtDIB = '.dib';
  rsExtTGA = '.tga';
  rsExtGIF = '.gif';
  rsExtBMZ = '.bmz';
  rsExtTmpTex = '.tmptex';

function TVXTexture.DoLoadImage(const tname: string): boolean;
var
  b: TBitmap;
  png: TPNGObject;
  jpg: TJPEGImage;
  pcx: TPCXImage;
  ppm: TPPMBitmap;
  dib: TDIB;
  tga: TTGABitmap;
  gif: TGifBitmap;
  bmz: TZBitmap;
  fs: TFileStream;
  fname: string;
  ext: string;

  procedure _TransferToBuffer;
  var
    src, dest: PPixelArray;
    i: integer;
  begin
    fwidth := b.Width;
    fheight := b.Height;
    ReallocMem(fbuffer, fwidth * fheight * 4);
    dest := @fbuffer[0];
    for i := 0 to fheight - 1 do
    begin
      src := b.ScanLine[i];
      Move(src^, dest^, fwidth * 4);
      dest := @dest[fwidth];
    end;
  end;

begin
  fname := VXT_FindFile(tname);
  if not FileExists(fname) then
  begin
    fwidth := 0;
    fheight := 0;
    printf('VXT_FindFile(): Can not find file "' + fname + '"'#13#10);
    ReallocMem(fbuffer, 0);
    Result := False;
    Exit;
  end;

  ext := UpperCase(ExtractFileExt(fname));
  if ext = UpperCase(rsExtBMP) then
  begin
    b := TBitmap.Create;
    try
      b.LoadFromFile(fname);
      b.PixelFormat := pf32bit;
      _TransferToBuffer;
    finally
      b.Free;
    end;
  end
  else if ext = UpperCase(rsExtPNG) then
  begin
    b := TBitmap.Create;
    png := TPNGObject.Create;
    try
      png.LoadFromFile(fname);
      b.Width := png.Width;
      b.Height := png.Height;
      b.PixelFormat := pf32bit;
      b.Canvas.Draw(0, 0, png);
      _TransferToBuffer;
    finally
      png.Free;
      b.Free;
    end;
  end
  else if (ext = UpperCase(rsExtJPG1)) or (ext = UpperCase(rsExtJPG2)) then
  begin
    b := TBitmap.Create;
    jpg := TJPEGImage.Create;
    try
      jpg.LoadFromFile(fname);
      b.Width := jpg.Width;
      b.Height := jpg.Height;
      b.PixelFormat := pf32bit;
      b.Canvas.Draw(0, 0, jpg);
      _TransferToBuffer;
    finally
      jpg.Free;
      b.Free;
    end;
  end
  else if ext = UpperCase(rsExtPCX) then
  begin
    b := TBitmap.Create;
    pcx := TPCXImage.Create;
    try
      pcx.LoadFromFile(fname);
      b.Width := pcx.Width;
      b.Height := pcx.Height;
      b.PixelFormat := pf32bit;
      b.Canvas.Draw(0, 0, pcx);
      _TransferToBuffer;
    finally
      pcx.Free;
      b.Free;
    end;
  end
  else if ext = UpperCase(rsExtPPM) then
  begin
    b := TBitmap.Create;
    ppm := TPPMBitmap.Create;
    try
      ppm.LoadFromFile(fname);
      b.Width := ppm.Width;
      b.Height := ppm.Height;
      b.PixelFormat := pf32bit;
      b.Canvas.Draw(0, 0, ppm);
      _TransferToBuffer;
    finally
      ppm.Free;
      b.Free;
    end;
  end
  else if ext = UpperCase(rsExtDIB) then
  begin
    b := TBitmap.Create;
    dib := TDIB.Create;
    try
      dib.LoadFromFile(fname);
      b.Width := dib.Width;
      b.Height := dib.Height;
      b.PixelFormat := pf32bit;
      b.Canvas.Draw(0, 0, dib);
      _TransferToBuffer;
    finally
      dib.Free;
      b.Free;
    end;
  end
  else if ext = UpperCase(rsExtTGA) then
  begin
    b := TBitmap.Create;
    tga := TTGABitmap.Create;
    try
      tga.LoadFromFile(fname);
      b.Width := tga.Width;
      b.Height := tga.Height;
      b.PixelFormat := pf32bit;
      b.Canvas.Draw(0, 0, tga);
      _TransferToBuffer;
    finally
      tga.Free;
      b.Free;
    end;
  end
  else if ext = UpperCase(rsExtGIF) then
  begin
    b := TBitmap.Create;
    gif := TGifBitmap.Create;
    try
      gif.LoadFromFile(fname);
      b.Width := gif.Width;
      b.Height := gif.Height;
      b.PixelFormat := pf32bit;
      b.Canvas.Draw(0, 0, gif);
      _TransferToBuffer;
    finally
      gif.Free;
      b.Free;
    end;
  end
  else if ext = UpperCase(rsExtBMZ) then
  begin
    b := TBitmap.Create;
    bmz := TZBitmap.Create;
    try
      bmz.LoadFromFile(fname);
      b.Width := bmz.Width;
      b.Height := bmz.Height;
      b.PixelFormat := pf32bit;
      b.Canvas.Draw(0, 0, bmz);
      _TransferToBuffer;
    finally
      bmz.Free;
      b.Free;
    end;
  end
  else if ext = UpperCase(rsExtTmpTex) then
  begin
    fs := TFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);
    try
      fs.Read(fwidth, SizeOf(fwidth));
      fs.Read(fheight, SizeOf(fheight));
      ReallocMem(fbuffer, fwidth * fheight * 4);
      fs.Read(fbuffer^, fwidth * fheight * 4);
    finally
      fs.Free;
    end;
  end
  else
  begin
    fwidth := 0;
    fheight := 0;
    printf('TVXTexture.DoLoadImage(): Unknown image format "' + ext + '"'#13#10);
    ReallocMem(fbuffer, 0);
    Result := False;
    Exit;
  end;
  Result := True;
end;

var
  tmpid: integer = 0;

procedure TVXTexture.SetDormant(const value: boolean);
var
  fs: TFileStream;
begin
  if value = fdormant then
    Exit;

  if value then
  begin
    if tmpfilename <> '' then
    begin
      if DoLoadImage(tmpfilename) then
        fdormant := False
      else if DoLoadImage(originalfilename) then
        fdormant := False;
    end;
  end
  else
  begin
    if tmpfilename = '' then
    begin
      inc(tmpid);
      tmpfilename := I_NewTempFile('VXTexture_' + IntToStr(tmpid) + rsExtTmpTex);
      fs := TFileStream.Create(tmpfilename, fmCreate or fmShareDenyNone);
      try
        fs.Write(fwidth, SizeOf(fwidth));
        fs.Write(fheight, SizeOf(fheight));
        fs.Write(fbuffer^, fwidth * fheight * 4);
      finally
        fs.Free;
      end;
    end;
    ReallocMem(fbuffer, 0);
    fdormant := True;
  end;
end;

procedure TVXTexture.ScaleTo(x, y: integer);
begin
  fscaledwidth := x;
  fscaledheight := y;
end;

function RGBSwap(const c: LongWord): LongWord;
var
  A: PByteArray;
  tmp: byte;
begin
  Result := c;
  A := @Result;
  tmp := A[0];
  A[0] := A[2];
  A[2] := tmp;
end;

function TVXTexture.Pixels(const x, y: integer): LongWord;
var
  ax, ay: integer;
begin
  SetDormant(False);
  if (fwidth = 0) or (fheight = 0) or (fbuffer = nil) or (fscaledwidth = 0) or (fscaledheight = 0) then
  begin
    Result := 0;
    Exit;
  end;

  if (fscaledwidth = fwidth) and (fscaledheight = fheight) then
  begin
    ax := x mod fwidth;
    if ax < 0 then
      ax := -ax;
    ay := y mod fheight;
    if ay < 0 then
      ay := -ay;
    Result := RGBSwap(fbuffer[ay * fwidth + ax]);
  end
  else
  begin
    ax := Trunc(x * fwidth / fscaledwidth) mod fwidth;
    if ax < 0 then
      ax := -ax;
    ay := Trunc(y * fheight / fscaledheight) mod fheight;
    if ay < 0 then
      ay := -ay;
    Result := RGBSwap(fbuffer[ay * fwidth + ax]);
  end;
end;

// -----------------------------------------------------------------------------
// TVXTextures
// -----------------------------------------------------------------------------
constructor TVXTextures.Create;
begin
  ftextures := TStringList.Create;
  fcache := TStringList.Create;
  Inherited;
end;

destructor TVXTextures.Destroy;
var
  i: integer;
begin
  for i := 0 to ftextures.Count - 1 do
    (ftextures.Objects[i] as TVXTexture).Free;
  ftextures.Free;
  fcache.Free;
  Inherited;
end;

procedure TVXTextures.Clear;
var
  i: integer;
begin
  for i := 0 to ftextures.Count - 1 do
    (ftextures.Objects[i] as TVXTexture).Free;
  ftextures.Clear;
  fcache.Clear;
end;

const
  MAXCACHETEXTURES = 10;

function TVXTextures.RTLGetTexture(tname: string): LongWord;
var
  su: string;
  idx: Integer;
  tex: TVXTexture;
begin
  su := UpperCase(tname);

  idx := fcache.IndexOf(su);
  if idx >= 0 then
  begin
    tex := (fcache.Objects[idx] as TVXTexture);
    tex.Dormant := False;
    Result := LongWord(tex);
    Exit;
  end;

  idx := ftextures.IndexOf(su);
  if idx < 0 then
    idx := ftextures.AddObject(su, TVXTexture.Create(tname));
  tex := ftextures.Objects[idx] as TVXTexture;

  tex.Dormant := False;

  idx := fcache.IndexOf(su);
  if idx < 0 then
  begin
    fcache.AddObject(su, tex);
    while fcache.Count > MAXCACHETEXTURES do
    begin
      (fcache.Objects[0] as TVXTexture).Dormant := True;
      fcache.Delete(0);
    end;
    // Unneeded
    idx := fcache.IndexOf(su);
    if idx < 0 then
    begin
      fcache.AddObject(su, tex);
      tex.Dormant := False;
    end;
  end;

  Result := LongWord(tex);
end;

//------------------------------------------------------------------------------

procedure SIRegister_VXTextures(CL: TPSPascalCompiler);
begin
  with CL.AddClassN(CL.FindClass('!TOBJECT'), '!TVXTexture') do
  begin
    RegisterProperty('Width', 'integer', iptR);
    RegisterProperty('Height', 'integer', iptR);
    RegisterProperty('Pixels', 'longword integer integer', iptR);
    RegisterMethod('procedure ScaleTo(x, y: integer);');
    SetDefaultPropery('Pixels');
  end;

  with CL.AddClassN(CL.FindClass('!TOBJECT'), '!TVXTextures') do
  begin
    RegisterMethod('constructor Create');
    RegisterProperty('texture', '!TVXTexture string', iptR);
    SetDefaultPropery('texture');
  end;
  AddImportedClassVariable(CL, 'Textures', '!TVXTextures');
end;

procedure TVXTextureWidth_R(Self: TVXTexture; var T: longword);
begin
  T := Self.ScaledWidth;
end;

procedure TVXTextureHeight_R(Self: TVXTexture; var T: longword);
begin
  T := Self.ScaledHeight;
end;

procedure TVXTexturePixels_R(Self: TVXTexture; var T: longword; const x, y: integer);
begin
  T := Self.Pixels(x, y);
end;

procedure TVXTexturesTexture_R(Self: TVXTextures; var T: longword; const s: string);
begin
  T := Self.RTLGetTexture(s);
end;

procedure RIRegister_VXTextures(CL: TPSRuntimeClassImporter);
begin
  with CL.Add2(TVXTexture, '!TVXTexture') do
  begin
    RegisterPropertyHelper(@TVXTextureWidth_R, nil, 'Width');
    RegisterPropertyHelper(@TVXTextureHeight_R, nil, 'Height');
    RegisterPropertyHelper(@TVXTexturePixels_R, nil, 'Pixels');
    RegisterMethod(@TVXTexture.ScaleTo, 'ScaleTo');
  end;
  with CL.Add2(TVXTextures, '!TVXTextures') do
  begin
    RegisterConstructor(@TVXTextures.Create, 'Create');
    RegisterPropertyHelper(@TVXTexturesTexture_R, nil, 'texture');
  end;
end;

var
  RTL_VXTextures: TVXTextures;

procedure RIRegisterRTL_VXTextures(Exec: TPSExec);
begin
  SetVariantToClass(Exec.GetVarNo(Exec.GetVar('Textures')), RTL_VXTextures);
end;

//------------------------------------------------------------------------------

procedure VXT_ResetTextures;
begin
  RTL_VXTextures.Clear;
end;

initialization
  RTL_VXTextures := TVXTextures.Create;

finalization
  RTL_VXTextures.Free;

end.
