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
//  DDVOX to slab6 VOX
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit ddvox2vox;

interface

function ConvertDDVOX2VOX(const sf, st: string): boolean;

implementation

uses
  vxe_export,
  voxels,
  SysUtils,
  Classes,
  vxe_script;

function ConvertDDVOX2VOX(const sf, st: string): boolean;
var
  xx, yy, zz: integer;
  fvoxelsize: integer;
  voxelbuffer: voxelbuffer_p;
  buf: TStringList;
  sc: TScriptEngine;
begin
  if not FileExists(sf) then
  begin
    Result := False;
    Exit;
  end;

  voxelbuffer := vox_getbuffer;
  FillChar(voxelbuffer^, SizeOf(voxelbuffer_t), Chr(0));

  buf := TStringList.Create;
  try
    buf.LoadFromFile(sf);
    sc := TScriptEngine.Create(buf.Text);
    sc.MustGetInteger;
    fvoxelsize := sc._Integer;
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
        voxelbuffer[xx, yy, zz] := sc._Integer;
        Inc(zz);
      end;
      if zz = fvoxelsize then
      begin
        zz := 0;
        Inc(yy);
        if yy = fvoxelsize then
        begin
          yy := 0;
          Inc(xx);
          if xx = fvoxelsize then
            Break;
        end;
      end;
    end;
    sc.Free;
  finally
    buf.Free;
  end;

  VXE_ExportVoxelToSlab6VOX(voxelbuffer, fvoxelsize, st);

  vox_freebuffer(voxelbuffer);

  Result := True;
end;

end.

