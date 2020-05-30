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
//  WAD file writer
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit vxe_wadwriter;

interface

uses
  Classes;

type
  TWadWriter = class(TObject)
  private
    lumps: TStringList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure AddFile(const lumpname: string; const fname: string);
    procedure AddSeparator(const lumpname: string);
    procedure SaveToStream(const strm: TStream);
    procedure SaveToFile(const fname: string);
  end;

implementation

uses
  SysUtils;

constructor TWadWriter.Create;
begin
  lumps := TStringList.Create;
  Inherited;
end;

destructor TWadWriter.Destroy;
var
  i: integer;
begin
  for i := 0 to lumps.Count - 1 do
    lumps.Objects[i].Free;
  lumps.Free;
  Inherited;
end;

procedure TWadWriter.AddFile(const lumpname: string; const fname: string);
var
  m: TMemoryStream;
  fs: TFileStream;
begin
  m := TMemoryStream.Create;
  fs := TFileStream.Create(fname, fmOpenRead);
  try
    m.CopyFrom(fs, fs.Size);
    lumps.AddObject(lumpname, m);
  finally
    fs.Free;
  end;
end;

procedure TWadWriter.AddSeparator(const lumpname: string);
begin
  lumps.AddObject(lumpname, TMemoryStream.Create);
end;

const
  PWAD = integer(Ord('P') or
                (Ord('W') shl 8) or
                (Ord('A') shl 16) or
                (Ord('D') shl 24));

type
  header_t = packed record
    identification: integer;
    numlumps: integer;
    infotableofs: integer;
  end;
  header_p = ^header_t;

  char8_t = packed array[0..7] of char;

  lump_t = packed record
    filepos: integer;
    size: integer;
    name: char8_t;
  end;
  lump_p = ^lump_t;
  lumparray_t = array[0..$FFF] of lump_t;
  lumparray_p = ^lumparray_t;

function string2char8(const s: string): char8_t;
var
  i: integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  for i := 1 to Length(s) do
  begin
    Result[i - 1] := s[i];
    if i = 8 then
      exit;
  end;
end;

procedure TWadWriter.SaveToStream(const strm: TStream);
var
  h: header_t;
  la: lumparray_p;
  i: integer;
  p, ssize: integer;
  m: TMemoryStream;
begin
  p := strm.Position;
  h.identification := PWAD;
  h.numlumps := lumps.Count;
  h.infotableofs := p + SizeOf(header_t);
  strm.Write(h, SizeOf(h));
  p := strm.Position;
  GetMem(la, lumps.Count * SizeOf(lump_t));
  strm.Write(la^, lumps.Count * SizeOf(lump_t));
  for i := 0 to lumps.Count - 1 do
  begin
    la[i].filepos := strm.Position;
    m := lumps.Objects[i] as TMemoryStream;
    la[i].size := m.Size;
    la[i].name := string2char8(lumps.Strings[i]);
    m.Position := 0;
    strm.CopyFrom(m, m.Size);
  end;
  ssize := strm.Position;
  strm.Position := p;
  strm.Write(la^, lumps.Count * SizeOf(lump_t));
  FreeMem(la, lumps.Count * SizeOf(lump_t));
  strm.Position := ssize;
end;

procedure TWadWriter.SaveToFile(const fname: string);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(fname, fmCreate);
  try
    SaveToStream(fs);
  finally
    fs.Free;
  end;
end;

end.
