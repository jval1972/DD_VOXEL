//------------------------------------------------------------------------------
//
//  DD_VOXEL: DelphiDoom Voxel Editor
//  Copyright (C) 2013-2017 by Jim Valavanis
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
//  System functions
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit vxe_system;

interface

function I_GetTime: integer;

const
  TICRATE = 100;

implementation

uses
  Windows;

var
  basetime: int64;
  Freq: int64;

function I_GetSysTime: extended;
var
  _time: int64;
begin
  if Freq = 1000 then
    _time := GetTickCount
  else
  begin
    if not QueryPerformanceCounter(_time) then
    // QueryPerformanceCounter() failed, basetime reset.
    begin
      _time := GetTickCount;
      Freq := 1000;
      basetime := 0;
    end;
  end;
  if basetime = 0 then
    basetime := _time;
  result := (_time - basetime) / Freq;
end;

function I_GetTime: integer;
begin
  result := trunc(I_GetSysTime * TICRATE);
end;

initialization
  basetime := 0;

  if not QueryPerformanceFrequency(Freq) then
    Freq := 1000;

end.
