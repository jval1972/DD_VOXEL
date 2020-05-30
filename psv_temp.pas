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
//  Script temporary file managment
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit psv_temp;

interface

procedure VXT_ClearSearchPaths;

procedure VXT_AddSearchPath(const fpath: string);

function VXT_FindFile(const fname: string): string;

implementation

uses
  Classes, SysUtils;

var
  vxt_searchpaths: TStringList;

procedure VXT_ClearSearchPaths;
begin
  if vxt_searchpaths <> nil then
  begin
    vxt_searchpaths.Free;
    vxt_searchpaths := nil;
  end;
end;

procedure VXT_AddSearchPath(const fpath: string);
begin
  if vxt_searchpaths = nil then
    vxt_searchpaths := TStringList.Create;

  if fpath <> '' then
    if vxt_searchpaths.IndexOf(UpperCase(fpath)) < 0 then
      vxt_searchpaths.Add(UpperCase(fpath));
end;

function VXT_FindFile(const fname: string): string;
var
  n, p: string;
  i: integer;
begin
  if FileExists(fname) then
  begin
    Result := fname;
    Exit;
  end;

  if vxt_searchpaths = nil then
  begin
    Result := fname;
    Exit;
  end;

  n := ExtractFileName(fname);
  for i := 0 to vxt_searchpaths.Count - 1 do
  begin
    p := vxt_searchpaths.Strings[i];
    if Length(p) > 0 then
    begin
      if p[Length(p)] <> '\' then
        p := p + '\';
      if FileExists(p + n) then
      begin
        Result := p + n;
        Exit;
      end;
    end;
  end;

  Result := fname;
end;

initialization
  vxt_searchpaths := nil;

finalization
  if vxt_searchpaths <> nil then
    vxt_searchpaths.Free;

end.
