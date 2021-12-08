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
//  OpenGL Voxel Rendering
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit vxe_gl;

interface

uses
  Windows,
  dglOpenGL,
  voxels;

var
  gld_max_texturesize: integer = 0;
  gl_tex_format: integer = GL_RGBA8;
  gl_tex_filter: integer = GL_LINEAR;
  PANELSIZE: integer;

procedure glInit(const psize: integer);

procedure ResetCamera(const axis: Char);

procedure glBeginScene(const Width, Height: integer);
procedure glEndScene(dc: HDC);
procedure glRenderAxes(const voxsize: Integer; const level: string);
procedure glRenderVoxel_Boxes(const voxsize: Integer; const vox: voxelbuffer_p; const dowireframe: boolean; const skipoptimization: boolean);
procedure glRenderVoxel_Points(const voxsize: Integer; const vox: voxelbuffer_p; const windowsize: integer);

procedure gld_InitVoxelTexture;
procedure gld_ShutDownVoxelTexture;

procedure gld_GetVoxelUVFromColor(const c: LongWord; var u, v: Single);

type
  TCDCamera = record
    x, y, z: glfloat;
    ax, ay, az: glfloat;
  end;

var
  camera: TCDCamera;

var
  vx_rendredvoxels: integer = 0;

var
  voxeltexture: TGLuint;

implementation

uses
  SysUtils,
  Math,
  vxe_defs,
  vxe_multithreading;

procedure ResetCamera(const axis: Char);
begin
  camera.x := 0.0;
  camera.y := 0.0;
  camera.z := -3.0;
  camera.ax := 0.0;
  camera.ay := 0.0;
  camera.az := 0.0;
end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure glInit(const psize: integer);
begin
  glClearColor(0.0, 0.0, 0.0, 0.0);   // Black Background
  glShadeModel(GL_SMOOTH);            // Enables Smooth Color Shading
  glClearDepth(1.0);                  // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);            // Enable Depth Buffer
  glDepthFunc(GL_LESS);		            // The Type Of Depth Test To Do
  glEnable(GL_POINT_SIZE);

  glGetIntegerv(GL_MAX_TEXTURE_SIZE, @gld_max_texturesize);

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations
  glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
  glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
  glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);

  PANELSIZE := psize;
end;

//
// JVAL
//  Create the palette texture, 512x512
//
type
  PLongWordArray = ^TLongWordArray;
  TLongWordArray = array[0..$FFFF] of LongWord;

procedure gld_InitVoxelTexture;
var
  buffer: PLongWordArray;
  r, g, b: integer;
  dest: PLongWord;
begin
  GetMem(buffer, 512 * 512 * SizeOf(LongWord));
  dest := @buffer[0];
  for r := 0 to 63 do
    for g := 0 to 63 do
      for b := 0 to 63 do
      begin
        dest^ := 255 shl 24 + (r * 4 + 2) shl 16 + (g * 4 + 2) shl 8 + (b * 4 + 2);
        inc(dest);
      end;

  buffer[0] := $010101;

  glGenTextures(1, @voxeltexture);
  glBindTexture(GL_TEXTURE_2D, voxeltexture);

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,
               512, 512,
               0, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

  FreeMem(buffer, 512 * 512 * SizeOf(LongWord));
end;

procedure gld_ShutDownVoxelTexture;
begin
  glDeleteTextures(1, @voxeltexture);
end;

procedure gld_GetVoxelUVFromColor(const c: LongWord; var u, v: Single);
var
  r, g, b: byte;
  x, y, idx: LongWord;
begin
  b := (c shr 16) and $FF;
  g := (c shr  8) and $FF;
  r := (c       ) and $FF;
  idx := (r div 4) + (g div 4) * 64 + (b div 4) * 64 * 64;
  x := idx and 511;
  y := idx shr 9;
  u := x / 512 + 1 / 1024;
  v := y / 512 + 1 / 1024
end;

procedure infinitePerspective(fovy: GLdouble; aspect: GLdouble; znear: GLdouble);
var
  left, right, bottom, top: GLdouble;
  m: array[0..15] of GLdouble;
begin
  top := znear * tan(fovy * pi / 360.0);
  bottom := -top;
  left := bottom * aspect;
  right := top * aspect;

  m[ 0] := (2 * znear) / (right - left);
  m[ 4] := 0;
  m[ 8] := (right + left) / (right - left);
  m[12] := 0;

  m[ 1] := 0;
  m[ 5] := (2 * znear) / (top - bottom);
  m[ 9] := (top + bottom) / (top - bottom);
  m[13] := 0;

  m[ 2] := 0;
  m[ 6] := 0;
  m[10] := -1;
  m[14] := -2 * znear;

  m[ 3] := 0;
  m[ 7] := 0;
  m[11] := -1;
  m[15] := 0;

  glMultMatrixd(@m);
end;

procedure glBeginScene(const Width, Height: integer);
begin
  glDisable(GL_CULL_FACE);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;

  infinitePerspective(64.0, width / height, 0.01);

  glMatrixMode(GL_MODELVIEW);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer
  glLoadIdentity;                                       // Reset The View

  glTranslatef(camera.x, camera.y, camera.z);
  glRotatef(camera.az, 0, 0, 1);
  glRotatef(camera.ay, 0, 1, 0);
  glRotatef(camera.ax, 1, 0, 0);
end;

procedure glEndScene(dc: HDC);
begin
  SwapBuffers(dc);                                // Display the scene
end;

var
  step: single;
  mid: single;

function xCoord(const x, y, z: Integer): Single;
begin
  result := mid - x * step;
end;

function yCoord(const x, y, z: Integer): Single;
begin
  result := y * step - mid;
end;

function zCoord(const x, y, z: Integer): Single;
begin
  result := z * step - mid;
end;

procedure glRenderAxes(const voxsize: Integer; const level: string);
const
  DRUNIT = 0.5;
var
  c: char;
  s: string;
  pos, xpos, ypos, zpos: integer;
  i: integer;
  xx, yy, zz: integer;
begin
  if opt_renderaxes then
  begin
    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_LINE_STRIP);
      glVertex3f(-DRUNIT, -DRUNIT, -DRUNIT);
      glVertex3f(-DRUNIT,  DRUNIT, -DRUNIT);
      glVertex3f( DRUNIT,  DRUNIT, -DRUNIT);
      glVertex3f( DRUNIT, -DRUNIT, -DRUNIT);
      glVertex3f(-DRUNIT, -DRUNIT, -DRUNIT);
    glEnd;

    glBegin(GL_LINE_STRIP);
      glVertex3f(-DRUNIT, -DRUNIT,  DRUNIT);
      glVertex3f(-DRUNIT,  DRUNIT,  DRUNIT);
      glVertex3f( DRUNIT,  DRUNIT,  DRUNIT);
      glVertex3f( DRUNIT, -DRUNIT,  DRUNIT);
      glVertex3f(-DRUNIT, -DRUNIT,  DRUNIT);
    glEnd;

    glBegin(GL_LINE_STRIP);
      glVertex3f(-DRUNIT, -DRUNIT, -DRUNIT);
      glVertex3f(-DRUNIT, -DRUNIT,  DRUNIT);
      glVertex3f( DRUNIT, -DRUNIT,  DRUNIT);
      glVertex3f( DRUNIT, -DRUNIT, -DRUNIT);
      glVertex3f(-DRUNIT, -DRUNIT, -DRUNIT);
    glEnd;

    glBegin(GL_LINE_STRIP);
      glVertex3f(-DRUNIT,  DRUNIT, -DRUNIT);
      glVertex3f(-DRUNIT,  DRUNIT,  DRUNIT);
      glVertex3f( DRUNIT,  DRUNIT,  DRUNIT);
      glVertex3f( DRUNIT,  DRUNIT, -DRUNIT);
      glVertex3f(-DRUNIT,  DRUNIT, -DRUNIT);
    glEnd;

    glBegin(GL_LINES);
      glVertex3f(0.0, 2 * DRUNIT, 0.0);
      glVertex3f(0.0, -2 * DRUNIT, 0.0);
      glVertex3f(2 * DRUNIT, 0.0, 0.0);
      glVertex3f(-2 * DRUNIT, 0.0, 0.0);
      glVertex3f(0.0, 0.0, 2 * DRUNIT);
      glVertex3f(0.0, 0.0, -2 * DRUNIT);
    glEnd;
  end;


  if opt_renderglgrid then
  begin
    s := Trim(level);
    if s = '' then
      exit;

    c := s[1];
    s[1] := ' ';
    pos := StrToIntDef(s, 0);
    if c = 'x' then
    begin
      xpos := pos;
      ypos := -1;
      zpos := -1;
    end
    else if c = 'y' then
    begin
      xpos := -1;
      ypos := pos;
      zpos := -1;
    end
    else if c = 'z' then
    begin
      xpos := -1;
      ypos := -1;
      zpos := pos;
    end
    else
      exit;

    step := -1.0 / voxsize;
    mid := step * voxsize / 2;

    glColor3f(1.0, 1.0, 0.0);
    glBegin(GL_LINES);
      if xpos >= 0 then
      begin
        for xx := xpos to xpos + 1 do
        begin
          for i := 0 to voxsize do
          begin
            glVertex3f(xCoord(xx, -1, i),  yCoord(xx, -1, i),  zCoord(xx, -1, i));
            glVertex3f(xCoord(xx, voxsize + 1, i),  yCoord(xx, voxsize + 1, i),  zCoord(xx, voxsize + 1, i));
          end;
          for i := 0 to voxsize do
          begin
            glVertex3f(xCoord(xx, i, -1),  yCoord(xx, i, -1),  zCoord(xx, i, -1));
            glVertex3f(xCoord(xx, i, voxsize + 1),  yCoord(xx, i, voxsize + 1),  zCoord(xx, i, voxsize + 1));
          end;
        end;
      end;

      if ypos >= 0 then
      begin
        for yy := ypos to ypos + 1 do
        begin
          for i := 0 to voxsize do
          begin
            glVertex3f(xCoord(-1, yy, i),  yCoord(-1, yy, i), zCoord(-1, yy, i));
            glVertex3f(xCoord(voxsize + 1, yy, i),  yCoord(voxsize + 1, yy, i), zCoord(voxsize + 1, yy, i));
          end;
          for i := 0 to voxsize do
          begin
            glVertex3f(xCoord(i, yy, -1),  yCoord(i, yy, -1), zCoord(i, yy, -1));
            glVertex3f(xCoord(i, yy, voxsize + 1),  yCoord(i, yy, voxsize + 1), zCoord(i, yy, voxsize + 1));
          end;
        end;
      end;

      if zpos >= 0 then
      begin
        for zz := zpos to zpos + 1 do
        begin
          for i := 0 to voxsize do
          begin
            glVertex3f(xCoord(-1, i, zz),  yCoord(-1, i, zz), zCoord(-1, i, zz));
            glVertex3f(xCoord(voxsize + 1, i, zz),  yCoord(voxsize + 1, i, zz), zCoord(voxsize + 1, i, zz));
          end;
          for i := 0 to voxsize do
          begin
            glVertex3f(xCoord(i, -1, zz),  yCoord(i, -1, zz), zCoord(i, -1, zz));
            glVertex3f(xCoord(i, voxsize + 1, zz),  yCoord(i, voxsize + 1, zz), zCoord(i, voxsize + 1, zz));
          end;
        end;
      end;
    glEnd;
  end;

end;

// jval: make it static
var
  global_flags: voxelrenderflags_t;
  global_vox: voxelbuffer_p;
  global_voxsize: integer;

procedure vxinitflags(const start, stop: integer);
var
  xx, yy, zz: integer;
  b: byte;
begin
  for xx := start to stop do
    for yy := 0 to global_voxsize - 1 do
      for zz := 0 to global_voxsize - 1 do
      begin
        if (xx > 0) and (xx < global_voxsize - 1) and
           (yy > 0) and (yy < global_voxsize - 1) and
           (zz > 0) and (zz < global_voxsize - 1) then
        begin
          b := 0;
          if global_vox[xx - 1, yy, zz] <> 0 then
            b := FLG_SKIPX0;
          if global_vox[xx + 1, yy, zz] <> 0 then
            b := b + FLG_SKIPX1;
          if global_vox[xx, yy - 1, zz] <> 0 then
            b := b + FLG_SKIPY0;
          if global_vox[xx, yy + 1, zz] <> 0 then
            b := b + FLG_SKIPY1;
          if global_vox[xx, yy, zz - 1] <> 0 then
            b := b + FLG_SKIPZ0;
          if global_vox[xx, yy, zz + 1] <> 0 then
            b := b + FLG_SKIPZ1;
          global_flags[xx, yy, zz] := b;
        end
        else
          global_flags[xx, yy, zz] := 0;
      end;
end;

procedure vxinitflags1(p: Pointer); stdcall;
begin
  vxinitflags(0, global_voxsize div 4);
end;

procedure vxinitflags2(p: Pointer); stdcall;
begin
  vxinitflags(global_voxsize div 4 + 1, global_voxsize div 2);
end;

procedure vxinitflags3(p: Pointer); stdcall;
begin
  vxinitflags(global_voxsize div 2 + 1, (global_voxsize div 4) * 3);
end;

procedure vxinitflags4(p: Pointer); stdcall;
begin
  vxinitflags((global_voxsize div 4) * 3 + 1, global_voxsize - 1);
end;

procedure glRenderVoxel_Boxes(const voxsize: Integer; const vox: voxelbuffer_p; const dowireframe: boolean; const skipoptimization: boolean);
var
  xx, yy, zz: integer;
  xxx, yyy, zzz,
  xxx1, yyy1, zzz1: single;
  vp: LongWord;
  oldc: LongWord;
  b: byte;
  i: integer;
  skip: Integer;
  u, v: single;
  flags: voxelrenderflags_p;
begin
  vx_rendredvoxels := 0;
  global_vox := vox;
  flags := @global_flags;
  global_voxsize := voxsize;

  if voxsize < 16 then
    vxinitflags(0, voxsize - 1)
  else
    MT_Execute(@vxinitflags1, nil, @vxinitflags2, nil, @vxinitflags3, nil, @vxinitflags4, nil);

  if dowireframe then
    glPolygonMode( GL_FRONT_AND_BACK, GL_LINE )
  else
    glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );

  step := -1.0 / voxsize;
  mid := step * voxsize / 2;
  oldc := $FFFFFFFF;

  glEnable(GL_TEXTURE_2D);

  glBindTexture(GL_TEXTURE_2D, voxeltexture);
  glBegin(GL_QUADS);

  glColor3f(1.0, 1.0, 1.0);

    for xx := 0 to voxsize - 1 do
    begin
      xxx := mid - xx * step;
      xxx1 := mid - (1 + xx) * step;
      for yy := 0 to voxsize - 1 do
      begin
        yyy := yy * step - mid;
        yyy1 := (1 + yy) * step - mid;
        skip := 0;
        for zz := 0 to voxsize - 1 do
        begin
          if skip > 0 then
          begin
            dec(skip);
            if skip > 0 then
              Continue;
          end;
          skip := 0;

          if vox[xx, yy, zz] <> 0 then
          begin
            inc(vx_rendredvoxels);
            b := flags[xx, yy, zz];
            vp := vox[xx, yy, zz];
            if skipoptimization then
              for i := zz to voxsize - 1 do
                if (flags[xx, yy, i] = b) and
                   (vox[xx, yy, i] = vp) then
                  Inc(skip)
                else
                  break;

            zzz := zz * step - mid;
            zzz1 := (skip + zz) * step - mid;
            if oldc <> vp then
            begin
              gld_GetVoxelUVFromColor(vp, u, v);
              glTexCoord2f(u, v);
              oldc := vp;
            end;

            if b and FLG_SKIPZ0 = 0 then
            begin
              glvertex3f(xxx, yyy, zzz);
              glvertex3f(xxx, yyy1, zzz);
              glvertex3f(xxx1, yyy1, zzz);
              glvertex3f(xxx1, yyy, zzz);
            end;

            if b and FLG_SKIPY0 = 0 then
            begin
              glvertex3f(xxx, yyy, zzz);
              glvertex3f(xxx, yyy, zzz1);
              glvertex3f(xxx1, yyy, zzz1);
              glvertex3f(xxx1, yyy, zzz);
            end;

            if b and FLG_SKIPX0 = 0 then
            begin
              glvertex3f(xxx, yyy, zzz);
              glvertex3f(xxx, yyy, zzz1);
              glvertex3f(xxx, yyy1, zzz1);
              glvertex3f(xxx, yyy1, zzz);
            end;

            if b and FLG_SKIPZ1 = 0 then
            begin
              glvertex3f(xxx, yyy, zzz1);
              glvertex3f(xxx, yyy1, zzz1);
              glvertex3f(xxx1, yyy1, zzz1);
              glvertex3f(xxx1, yyy, zzz1);
            end;

            if b and FLG_SKIPY1 = 0 then
            begin
              glvertex3f(xxx, yyy1, zzz);
              glvertex3f(xxx, yyy1, zzz1);
              glvertex3f(xxx1, yyy1, zzz1);
              glvertex3f(xxx1, yyy1, zzz);
            end;

            if b and FLG_SKIPX1 = 0 then
            begin
              glvertex3f(xxx1, yyy, zzz);
              glvertex3f(xxx1, yyy1, zzz);
              glvertex3f(xxx1, yyy1, zzz1);
              glvertex3f(xxx1, yyy , zzz1);
            end;
          end;
        end;
      end;
    end;

  glEnd;

  glBindTexture(GL_TEXTURE_2D, 0);
  glDisable(GL_TEXTURE_2D);
  glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );
end;

type
  pointsizeinfo_t = record
    z: single;
    size: integer;
  end;

const
  POINTSIZES = 16;

  pointsizeinfo: array[0..POINTSIZES - 1] of pointsizeinfo_t = (
    (z: -1.0; size: 97),
    (z: -1.2; size: 70),
    (z: -1.4; size: 55),
    (z: -1.6; size: 45),
    (z: -1.8; size: 48),
    (z: -1.8; size: 48),
    (z: -2.0; size: 33),
    (z: -2.2; size: 29),
    (z: -2.4; size: 26),
    (z: -2.6; size: 24),
    (z: -2.8; size: 22),
    (z: -3.0; size: 20),
    (z: -3.3; size: 18),
    (z: -3.6; size: 16),
    (z: -4.5; size: 13),
    (z: -6.0; size:  9)
  );

function glGetPointSize(const voxelsize, windowsize: Integer): Single;
var
  i: integer;
begin
  result := 0;

  if camera.z >= pointsizeinfo[0].z then
    result := pointsizeinfo[0].size + 1
  else if camera.z <= pointsizeinfo[POINTSIZES - 1].z then
    result := pointsizeinfo[POINTSIZES - 1].size + 1
  else
  begin
    i := 1;
    while i < POINTSIZES do
    begin
      if camera.z >= pointsizeinfo[i].z then
      begin
        result :=  pointsizeinfo[i].size * (pointsizeinfo[i - 1].z - camera.z) / (pointsizeinfo[i - 1].z - pointsizeinfo[i].z) +
                   pointsizeinfo[i - 1].size * (camera.z - pointsizeinfo[i].z) / (pointsizeinfo[i - 1].z - pointsizeinfo[i].z) + 1;
        i := POINTSIZES;
      end;
      Inc(i);
    end;
  end;

  Result := Result * (16 / voxelsize) * (windowsize / PANELSIZE) * Sqrt(2);
end;

procedure glRenderVoxel_Points(const voxsize: Integer; const vox: voxelbuffer_p; const windowsize: integer);
var
  xx, yy, zz: integer;
  xxx, yyy, zzz: single;
  ps: single;
begin
  vx_rendredvoxels := 0;

  step := -1.0 / voxsize;
  mid := step * voxsize / 2;

  ps := glGetPointSize(voxsize, windowsize);
  glPointSize(ps);
  glBegin(GL_POINTS);

    for xx := 0 to voxsize - 1 do
    begin
      xxx := mid - (0.5 + xx) * step;
      for yy := 0 to voxsize - 1 do
      begin
        yyy := (0.5 + yy) * step - mid;
        for zz := 0 to voxsize - 1 do
          if vox[xx, yy, zz] <> 0 then
          begin
            inc(vx_rendredvoxels);
            zzz := (0.5 + zz) * step - mid;
            glColor3f((vox[xx, yy, zz] and $FF) / 255,
                      ((vox[xx, yy, zz] shr 8) and $FF) / 255,
                      (vox[xx, yy, zz] shr 16) / 255);

            glvertex3f(xxx, yyy, zzz);
          end;
      end;
    end;
  glEnd;
end;

end.
