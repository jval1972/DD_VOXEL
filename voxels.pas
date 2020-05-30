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
//  Basic Voxel Definitions
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit voxels;

interface

const
  FLG_SKIPX0 = 1;
  FLG_SKIPX1 = 2;
  FLG_SKIPY0 = 4;
  FLG_SKIPY1 = 8;
  FLG_SKIPZ0 = 16;
  FLG_SKIPZ1 = 32;

const
  MAXVOXELSIZE = 256;

type
  voxelview_t = (vv_none, vv_front, vv_back, vv_left, vv_right, vv_top, vv_down);

  voxelitem_t = LongWord;
  voxelitem_p = ^voxelitem_t;
  voxelbuffer_t = array[0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1] of voxelitem_t;
  voxelbuffer_p = ^voxelbuffer_t;

  voxelbuffer2d_t = array[0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1] of voxelitem_t;
  voxelbuffer2d_p = ^voxelbuffer2d_t;

  depthvoxelitem_t = record
    color: LongWord;
    depth: LongWord;
    prev: voxelitem_p;
  end;

  depthvoxelbuffer2d_t = array[0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1] of depthvoxelitem_t;
  depthvoxelbuffer2d_p = ^depthvoxelbuffer2d_t;

  voxelbuffer1d_t = array[0..MAXVOXELSIZE - 1] of voxelitem_t;
  voxelbuffer1d_p = ^voxelbuffer1d_t;

type
  voxelrenderflags_t = packed array[0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1] of byte;
  voxelrenderflags_p = ^voxelrenderflags_t;

procedure vox_removenonvisiblecells(const buf: voxelbuffer_p; const size: integer);

procedure vox_cropyaxis(const buf: voxelbuffer_p; const size: integer;
  const amin, amax: integer);

procedure vox_shrinkyaxis(const buf: voxelbuffer_p; const size: integer;
  const amin, amax: integer);

procedure vox_getviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const outbuf: voxelbuffer2d_p; const vv: voxelview_t);

procedure vox_setviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const inpbuf: voxelbuffer2d_p; const vv: voxelview_t);

procedure vox_getdepthviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const outbuf: depthvoxelbuffer2d_p; const vv: voxelview_t);

procedure vox_setdepthviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const inpbuf: depthvoxelbuffer2d_p; const vv: voxelview_t; const erase: boolean);

function vox_getdepthitemAt(const buf: voxelbuffer_p; const size: integer;
  const atX, atY: integer; const vv: voxelview_t): depthvoxelitem_t;

function vox_getdepthpointerAtXY(const buf: voxelbuffer_p; const size: integer;
  const atX, atY: integer; const vv: voxelview_t): voxelitem_p;

function vox_getdepthpointerAtXYZ(const buf: voxelbuffer_p; const size: integer;
  const atX, atY, atZ: integer; const vv: voxelview_t): voxelitem_p;

procedure vox_clearbuffer(const buf: voxelbuffer_p; const size: integer);

procedure vox_initthreads;

procedure vox_shutdownthreads;

procedure vox_initbuffers;

function vox_getbuffer: voxelbuffer_p;

procedure vox_freebuffer(var p: voxelbuffer_p);

implementation

uses
  SysUtils,
  vxe_utils,
  vxe_threads,
  vxe_multithreading,
  progressfrm;

type
  flags_t = array[0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1] of boolean;
  flags_p = ^flags_t;

type
  parms1_t = record
    flags: flags_p;
    buf: voxelbuffer_p;
    ifrom, ito: integer;
    size: integer;
  end;
  parms1_p = ^parms1_t;

function threadworker1(const p: pointer): integer; stdcall;
var
  parms: parms1_p;
  buf: voxelbuffer_p;
  i, j, k: integer;
  size: integer;
begin
  parms := p;
  buf := parms.buf;
  size := parms.size;
  for i := parms.ifrom to parms.ito do
    for j := 1 to size - 2 do
      for k := 1 to size - 2 do
        if buf[i, j, k] <> 0 then
          if buf[i - 1, j, k] <> 0 then
            if buf[i + 1, j, k] <> 0 then
              if buf[i, j - 1, k] <> 0 then
                if buf[i, j + 1, k] <> 0 then
                  if buf[i, j, k - 1] <> 0 then
                    if buf[i, j, k + 1] <> 0 then
                      parms.flags^[i, j, k] := true;
  result := 0;
end;

function threadworker2(const p: pointer): integer; stdcall;
var
  parms: parms1_p;
  buf: voxelbuffer_p;
  i, j, k: integer;
  size: integer;
begin
  parms := p;
  buf := parms.buf;
  size := parms.size;
  for i := parms.ifrom to parms.ito do
    for j := 1 to size - 2 do
      for k := 1 to size - 2 do
        if parms.flags^[i, j, k] then
          buf[i, j, k] := 0;
  result := 0;
end;

var
  tr1: TDThread;

procedure vox_removenonvisiblecells(const buf: voxelbuffer_p; const size: integer);
var
  i, j, k: integer;
  flags: flags_p;
  parms1: parms1_t;
begin
  ProgressStart('Remove non visible voxels', 2 * (size - 3 - (size div 2)));
  GetMem(flags, SizeOf(flags_t));
  FillChar(flags^, SizeOf(flags_t), Chr(0));

  parms1.flags := flags;
  parms1.buf := buf;
  parms1.ifrom := 1;
  parms1.ito := size div 2;
  parms1.size := size;

  tr1.Activate(@threadworker1, @parms1);

  for i := (size div 2) + 1 to size - 2 do
  begin
    ProgressStep;
    for j := 1 to size - 2 do
      for k := 1 to size - 2 do
        if buf[i, j, k] <> 0 then
          if buf[i - 1, j, k] <> 0 then
            if buf[i + 1, j, k] <> 0 then
              if buf[i, j - 1, k] <> 0 then
                if buf[i, j + 1, k] <> 0 then
                  if buf[i, j, k - 1] <> 0 then
                    if buf[i, j, k + 1] <> 0 then
                      flags^[i, j, k] := true;
  end;
  tr1.Wait;

  tr1.Activate(@threadworker2, @parms1);

  for i := (size div 2) + 1 to size - 2 do
  begin
    ProgressStep;
    for j := 1 to size - 2 do
      for k := 1 to size - 2 do
        if flags^[i, j, k] then
          buf[i, j, k] := 0;
  end;

  tr1.Wait;

  FreeMem(flags);

  ProgressStop;
end;

procedure vox_cropyaxis(const buf: voxelbuffer_p; const size: integer;
  const amin, amax: integer);
var
  topb, bottomb: voxelbuffer2d_p;
  mn, mx, tmp: integer;
  x, y, z: integer;
  c: voxelitem_t;
begin
  if amin = 0 then
    if amax = 255 then
      Exit;

  if amax = 0 then
    if amin = 255 then
      Exit;

  GetMem(topb, SizeOf(voxelbuffer2d_t));
  for x := 0 to size - 1 do
    for y := 0 to size - 1 do
      topb[x, y] := 0;

  GetMem(bottomb, SizeOf(voxelbuffer2d_t));
  for x := 0 to size - 1 do
    for y := 0 to size - 1 do
      bottomb[x, y] := 0;

  if size = MAXVOXELSIZE then
  begin
    mn := amin;
    mx := amax;
  end
  else
  begin
    mn := Round(amin * size / MAXVOXELSIZE);
    mx := Round(amax * size / MAXVOXELSIZE);
  end;

  if mn < 0 then
    mn := 0
  else if mn >= size then
    mn := size - 1;

  if mx < 0 then
    mx := 0
  else if mx >= size then
    mx := size - 1;

  if mn > mx then
  begin
    tmp := mn;
    mn := mx;
    mx := tmp;
  end;

  for x := 0 to size - 1 do
    for z := 0 to size - 1 do
    begin
      c := 0;
      for y := 0 to mn do
        if buf[x, y, z] <> 0 then
        begin
          c := buf[x, y, z];
          Break;
        end;
      topb[x, z] := c;
    end;

  for x := 0 to size - 1 do
    for z := 0 to size - 1 do
    begin
      c := 0;
      for y := size - 1 downto mx do
        if buf[x, y, z] <> 0 then
        begin
          c := buf[x, y, z];
          Break;
        end;
      bottomb[x, z] := c;
    end;

  for x := 0 to size - 1 do
    for z := 0 to size - 1 do
    begin
      for y := 0 to mn - 1 do
        buf[x, y, z] := 0;
      for y := mx + 1 to size - 1 do
        buf[x, y, z] := 0;
      buf[x, mn, z] := topb[x, z];
      buf[x, mx, z] := bottomb[x, z];
    end;

  FreeMem(topb, SizeOf(voxelbuffer2d_t));
  FreeMem(bottomb, SizeOf(voxelbuffer2d_t));
end;

procedure vox_shrinkyaxis(const buf: voxelbuffer_p; const size: integer;
  const amin, amax: integer);
var
  bck: voxelbuffer_p;
  mn, mx, tmp: integer;
  x, y, y1, z: integer;
  factor, mne: Extended;
begin
  if amin = 0 then
    if amax = 255 then
      Exit;

  if amax = 0 then
    if amin = 255 then
      Exit;

  bck := vox_getbuffer;
  for x := 0 to size - 1 do
    for y := 0 to size - 1 do
      for z := 0 to size - 1 do
        bck[x, y, z] := buf[x, y, z];

  mn := amin;
  mx := amax;

  if mn < 0 then
    mn := 0
  else if mn > 255 then
    mn := 255;

  if mx < 0 then
    mx := 0
  else if mx > 255 then
    mx := 255;

  if mn > mx then
  begin
    tmp := mn;
    mn := mx;
    mx := tmp;
  end;

  for x := 0 to size - 1 do
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
        buf[x, y, z] := 0;

  factor := (mx - mn) / MAXVOXELSIZE;
  if size = MAXVOXELSIZE then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
        for y := 0 to size - 1 do
        begin
          y1 := Round(mn + y * factor);
          if y1 < 0 then
            y1 := 0
          else if y1 >= MAXVOXELSIZE then
            y1 := MAXVOXELSIZE;
          if buf[x, y1, z] = 0 then
            buf[x, y1, z] := bck[x, y, z];
        end;
  end
  else
  begin
    mne := mn * size / MAXVOXELSIZE;
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
        for y := 0 to size - 1 do
        begin
          y1 := Round(mne + y * factor);
          if y1 < 0 then
            y1 := 0
          else if y1 >= size then
            y1 := size;
          if buf[x, y1, z] = 0 then
            buf[x, y1, z] := bck[x, y, z];
        end;
  end;

  vox_freebuffer(bck);
end;

procedure vox_getviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const outbuf: voxelbuffer2d_p; const vv: voxelview_t);
var
  x, y, z: integer;
  c: voxelitem_t;
begin
  if size >= MAXVOXELSIZE div 2 then
    MT_ZeroMemory(outbuf, SizeOf(voxelbuffer2d_t))
  else
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
        outbuf[x, y] := 0;

  if vv = vv_front then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        for z := 0 to size - 1 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[x, y] := c;
      end;
    Exit;
  end;

  if vv = vv_back then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        for z := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[x, y] := c;
      end;
    Exit;
  end;

  if vv = vv_left then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        for x := 0 to size - 1 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[size - 1 - z, y] := c;
      end;
    Exit;
  end;

  if vv = vv_right then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        for x := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[z, y] := c;
      end;
    Exit;
  end;

  if vv = vv_top then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
      begin
        c := 0;
        for y := 0 to size - 1 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[x, size - 1 - z] := c;
      end;
    Exit;
  end;

  if vv = vv_down then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
      begin
        c := 0;
        for y := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[x, z] := c;
      end;
    Exit;
  end;
end;

procedure vox_setviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const inpbuf: voxelbuffer2d_p; const vv: voxelview_t);
var
  x, y, z: integer;
begin
  if vv = vv_front then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
        for z := 0 to size - 1 do
          if (buf[x, y, z] <> 0) or (z = size - 1) then
          begin
            buf[x, y, z] := inpbuf[x, y];
            Break;
          end;
    Exit;
  end;

  if vv = vv_back then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
        for z := size - 1 downto 0 do
          if (buf[x, y, z] <> 0) or (z = 0) then
          begin
            buf[x, y, z] := inpbuf[x, y];
            Break;
          end;
    Exit;
  end;

  if vv = vv_left then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
        for x := 0 to size - 1 do
          if (buf[x, y, z] <> 0) or (x = size - 1) then
          begin
            buf[x, y, z] := inpbuf[size - 1 - z, y];
            Break;
          end;
    Exit;
  end;

  if vv = vv_right then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
        for x := size - 1 downto 0 do
          if (buf[x, y, z] <> 0) or (x = 0) then
          begin
            buf[x, y, z] := inpbuf[z, y];
            Break;
          end;
    Exit;
  end;

  if vv = vv_top then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
        for y := 0 to size - 1 do
          if (buf[x, y, z] <> 0) or (y = size - 1) then
          begin
            buf[x, y, z] := inpbuf[x, size - 1 - z];
            Break;
          end;
    Exit;
  end;

  if vv = vv_down then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
        for y := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            buf[x, y, z] := inpbuf[x, z];
            Break;
          end;
    Exit;
  end;
end;

procedure vox_getdepthviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const outbuf: depthvoxelbuffer2d_p; const vv: voxelview_t);
var
  x, y, z: integer;
  c: voxelitem_t;
  depth: integer;
  prev: voxelitem_p;
begin
  for x := 0 to size - 1 do
    for y := 0 to size - 1 do
    begin
      outbuf[x, y].color := 0;
      outbuf[x, y].depth := size;
      outbuf[x, y].prev := nil;
    end;

  if vv = vv_front then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        depth := size;
        prev := @buf[x, y, size - 1];
        for z := 0 to size - 1 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            prev := @buf[x, y, MaxI(z - 1, 0)];
            depth := z;
            Break;
          end;
        outbuf[x, y].color := c;
        outbuf[x, y].depth := depth;
        outbuf[x, y].prev := prev;
      end;
    Exit;
  end;

  if vv = vv_back then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        depth := size;
        prev := @buf[x, y, 0];
        for z := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            prev := @buf[x, y, MinI(z + 1, size - 1)];
            depth := z;
            Break;
          end;
        outbuf[x, y].color := c;
        outbuf[x, y].depth := depth;
        outbuf[x, y].prev := prev;
      end;
    Exit;
  end;

  if vv = vv_left then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        depth := size;
        prev := @buf[size - 1, y, z];
        for x := 0 to size - 1 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            prev := @buf[MaxI(x - 1, 0), y, z];
            depth := x;
            Break;
          end;
        outbuf[size - 1 - z, y].color := c;
        outbuf[size - 1 - z, y].depth := depth;
        outbuf[size - 1 - z, y].prev := prev;
      end;
    Exit;
  end;

  if vv = vv_right then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        depth := size;
        prev := @buf[0, y, z];
        for x := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            prev := @buf[MinI(x + 1, size - 1), y, z];
            depth := x;
            Break;
          end;
        outbuf[z, y].color := c;
        outbuf[z, y].depth := depth;
        outbuf[z, y].prev := prev;
      end;
    Exit;
  end;

  if vv = vv_top then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
      begin
        c := 0;
        depth := size;
        prev := @buf[x, size - 1, z];
        for y := 0 to size - 1 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            prev := @buf[x, MaxI(y - 1, 0), z];
            depth := y;
            Break;
          end;
        outbuf[x, size - 1 - z].color := c;
        outbuf[x, size - 1 - z].depth := depth;
        outbuf[x, size - 1 - z].prev := prev;
      end;
    Exit;
  end;

  if vv = vv_down then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
      begin
        c := 0;
        depth := size;
        prev := @buf[x, 0, z];
        for y := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            prev := @buf[x, MinI(y + 1, size - 1), z];
            depth := y;
            Break;
          end;
        outbuf[x, z].color := c;
        outbuf[x, z].depth := depth;
        outbuf[x, z].prev := prev;
      end;
    Exit;
  end;
end;

procedure vox_setdepthviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const inpbuf: depthvoxelbuffer2d_p; const vv: voxelview_t; const erase: boolean);
var
  x, y, z: integer;
  wsize: LongWord;
begin
  if size <= 0 then
    Exit; // Ouh

  wsize := size;  // JVAL: Avoid compiler warning

  if vv = vv_front then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        if erase then
          for z := 0 to inpbuf[x, y].depth - 1 do
            buf[x, y, z] := 0;
        if inpbuf[x, y].depth < wsize then
          buf[x, y, inpbuf[x, y].depth] := inpbuf[x, y].color;
      end;
    Exit;
  end;

  if vv = vv_back then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        if erase then
          for z := size - 1 downto inpbuf[x, y].depth + 1 do
            buf[x, y, z] := 0;
        if inpbuf[x, y].depth < wsize then
          buf[x, y, inpbuf[x, y].depth] := inpbuf[x, y].color;
      end;
    Exit;
  end;

  if vv = vv_left then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        for x := 0 to inpbuf[size - 1 - z, y].depth - 1 do
          buf[x, y, z] := 0;
        if inpbuf[size - 1 - z, y].depth < wsize then
          buf[inpbuf[size - 1 - z, y].depth, y, z] := inpbuf[size - 1 - z, y].color;
      end;
    Exit;
  end;

  if vv = vv_right then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        for x := size - 1 downto inpbuf[z, y].depth + 1 do
          buf[x, y, z] := 0;
        if inpbuf[z, y].depth < wsize then
          buf[inpbuf[z, y].depth, y, z] := inpbuf[z, y].color;
      end;
    Exit;
  end;

  if vv = vv_top then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
      begin
        for y := 0 to inpbuf[x, size - 1 - z].depth - 1 do
          buf[x, y, z] := 0;
        if inpbuf[x, size - 1 - z].depth < wsize then
          buf[x, inpbuf[x, size - 1 - z].depth, z] := inpbuf[x, size - 1 - z].color;
      end;
    Exit;
  end;

  if vv = vv_down then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
      begin
        for y := size downto inpbuf[x, z].depth + 1 do
          buf[x, y, z] := 0;
        if inpbuf[x, z].depth < wsize then
          buf[x, inpbuf[x, z].depth, z] := inpbuf[x, z].color;
      end;
    Exit;
  end;
end;

function vox_getdepthitemAt(const buf: voxelbuffer_p; const size: integer;
  const atX, atY: integer; const vv: voxelview_t): depthvoxelitem_t;
var
  x, y, z: integer;
begin
  Result.color := 0;
  Result.depth := size;
  Result.prev := nil;

  if vv = vv_front then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    for z := 0 to size - 1 do
      if buf[x, y, z] <> 0 then
      begin
        Result.color := buf[x, y, z];
        Result.depth := z;
        Result.prev := @buf[x, y, MinI(z - 1, 0)];
        Exit;
      end;
    Exit;
  end;

  if vv = vv_back then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    for z := size - 1 downto 0 do
      if buf[x, y, z] <> 0 then
      begin
        Result.color := buf[x, y, z];
        Result.depth := z;
        Result.prev := @buf[x, y, MaxI(z + 1, size - 1)];
        Exit;
      end;
    Exit;
  end;

  if vv = vv_left then
  begin
    z := GetIntInRange(size - 1 - atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    for x := 0 to size - 1 do
      if buf[x, y, z] <> 0 then
      begin
        Result.color := buf[x, y, z];
        Result.depth := x;
        Result.prev := @buf[MaxI(x - 1, 0), y, z];
        Exit;
      end;
    Exit;
  end;

  if vv = vv_right then
  begin
    z := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    for x := size - 1 downto 0 do
      if buf[x, y, z] <> 0 then
      begin
        Result.color := buf[x, y, z];
        Result.depth := x;
        Result.prev := @buf[MinI(x + 1, size - 1), y, z];
        Exit;
      end;
    Exit;
  end;

  if vv = vv_top then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    z := GetIntInRange(size - 1 - atY, 0, size - 1);
    for y := 0 to size - 1 do
      if buf[x, y, z] <> 0 then
      begin
        Result.color := buf[x, y, z];
        Result.depth := y;
        Result.prev := @buf[z, MaxI(y - 1, 0), z];
        Exit;
      end;
    Exit;
  end;

  if vv = vv_down then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    z := GetIntInRange(atY, 0, size - 1);
    for y := size - 1 downto 0 do
      if buf[x, y, z] <> 0 then
      begin
        Result.color := buf[x, y, z];
        Result.depth := y;
        Result.prev := @buf[z, MinI(y + 1, size - 1), z];
        Exit;
      end;
    Exit;
  end;
end;

function vox_getdepthpointerAtXY(const buf: voxelbuffer_p; const size: integer;
  const atX, atY: integer; const vv: voxelview_t): voxelitem_p;
var
  x, y, z: integer;
begin
  Result := nil;

  if vv = vv_front then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    for z := 0 to size - 1 do
      if buf[x, y, z] <> 0 then
      begin
        Result := @buf[x, y, z];
        Exit;
      end;
    Result := @buf[x, y, size - 1];
    Exit;
  end;

  if vv = vv_back then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    for z := size - 1 downto 0 do
      if buf[x, y, z] <> 0 then
      begin
        Result := @buf[x, y, z];
        Exit;
      end;
    Result := @buf[x, y, 0];
    Exit;
  end;

  if vv = vv_left then
  begin
    z := GetIntInRange(size - 1 - atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    for x := 0 to size - 1 do
      if buf[x, y, z] <> 0 then
      begin
        Result := @buf[x, y, z];
        Exit;
      end;
    Result := @buf[size - 1, y, z];
    Exit;
  end;

  if vv = vv_right then
  begin
    z := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    for x := size - 1 downto 0 do
      if buf[x, y, z] <> 0 then
      begin
        Result := @buf[x, y, z];
        Exit;
      end;
    Result := @buf[0, y, z];
    Exit;
  end;

  if vv = vv_top then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    z := GetIntInRange(size - 1 - atY, 0, size - 1);
    for y := 0 to size - 1 do
      if buf[x, y, z] <> 0 then
      begin
        Result := @buf[x, y, z];
        Exit;
      end;
    Result := @buf[x, size - 1, z];
    Exit;
  end;

  if vv = vv_down then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    z := GetIntInRange(atY, 0, size - 1);
    for y := size - 1 downto 0 do
      if buf[x, y, z] <> 0 then
      begin
        Result := @buf[x, y, z];
        Exit;
      end;
    Result := @buf[x, 0, z];
    Exit;
  end;
end;

function vox_getdepthpointerAtXYZ(const buf: voxelbuffer_p; const size: integer;
  const atX, atY, atZ: integer; const vv: voxelview_t): voxelitem_p;
var
  x, y, z: integer;
begin
  Result := nil;

  if vv = vv_front then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    z := GetIntInRange(atZ, 0, size - 1);
    Result := @buf[x, y, z];
    Exit;
  end;

  if vv = vv_back then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    z := GetIntInRange(atZ, 0, size - 1);
    Result := @buf[x, y, z];
    Exit;
  end;

  if vv = vv_left then
  begin
    z := GetIntInRange(size - 1 - atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    x := GetIntInRange(atZ, 0, size - 1);
    Result := @buf[x, y, z];
    Exit;
  end;

  if vv = vv_right then
  begin
    z := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atY, 0, size - 1);
    x := GetIntInRange(atZ, 0, size - 1);
    Result := @buf[x, y, z];
    Exit;
  end;

  if vv = vv_top then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atZ, 0, size - 1);
    z := GetIntInRange(size - 1 - atY, 0, size - 1);
    Result := @buf[x, y, z];
    Exit;
  end;

  if vv = vv_down then
  begin
    x := GetIntInRange(atX, 0, size - 1);
    y := GetIntInRange(atZ, 0, size - 1);
    z := GetIntInRange(atY, 0, size - 1);
    Result := @buf[x, y, z];
    Exit;
  end;
end;

procedure vox_clearbuffer(const buf: voxelbuffer_p; const size: integer);
var
  x, y, z: integer;
begin
  if size >= (MAXVOXELSIZE - 10) then
    MT_ZeroMemory(buf, SizeOf(voxelbuffer_t))
  else
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
        for z := 0 to size - 1 do
          buf[x, y, z] := 0;
end;

procedure vox_initthreads;
begin
  tr1 := TDThread.Create;
end;

procedure vox_shutdownthreads;
begin
  tr1.Free;
end;

const
  NUMVOXBUFFERS = 2;

type
  vovbufferitem_t = record
    vox: voxelbuffer_t;
    available: boolean;
  end;

var
  voxelbuffers: array[0..NUMVOXBUFFERS - 1] of vovbufferitem_t;

procedure vox_initbuffers;
var
  i: integer;
begin
  for i := 0 to NUMVOXBUFFERS - 1 do
    voxelbuffers[i].available := True;
end;

function vox_getbuffer: voxelbuffer_p;
var
  i: integer;
begin
  for i := 0 to NUMVOXBUFFERS - 1 do
    if voxelbuffers[i].available then
    begin
      Result := @voxelbuffers[i].vox;
      voxelbuffers[i].available := False;
      Exit;
    end;

  GetMem(Result, SizeOf(voxelbuffer_t));
end;

procedure vox_freebuffer(var p: voxelbuffer_p);
var
  i: integer;
begin
  for i := 0 to NUMVOXBUFFERS - 1 do
    if not voxelbuffers[i].available then
      if p = @voxelbuffers[i].vox then
      begin
        voxelbuffers[i].available := True;
        p := nil;
        Exit;
      end;

  FreeMem(p, SizeOf(voxelbuffer_t));
  p := nil;
end;

end.

