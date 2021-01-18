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
//  VoxelScript loader
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit psv_voxel;

interface

uses
  SysUtils,
  Classes,
  voxels,
  vxe_utils;

type
  voxelcmd_t = record
    cmd: integer;
    x, y, z: byte;
    Color: voxelitem_t;
  end;
  voxelcmd_p = ^voxelcmd_t;
  voxelcmd_a = array[0..$FFF] of voxelcmd_t;
  voxelcmd_pa = ^voxelcmd_a;

const
  C_vxSet = 0;
  C_vxClear = 1;

const
  VDL_MAGIC = $2;

type
  scriptlanguage_t = (sl_pascal, sl_voxelddscript, sl_clang);

  TDDVoxelScriptLoader = class(TObject)
  private
    fNumCmds: integer;
    fRealNumCmds: integer;
    fCmds: voxelcmd_pa;
    voxelbuf: voxelbuffer_p;
    voxelsz: integer;
    function Grow: voxelcmd_p;
  protected
    procedure AddCmd(const cmd: integer; const x, y, z: byte; const cl: LongWord);
  public
    constructor Create(const abuf: voxelbuffer_p; const asz: integer); virtual;
    destructor Destroy; override;
    procedure Clear;
    function LoadFromScript(const aScript: string; const doCompile, doRun: boolean;
      var Data: {$IFDEF UNICODE}AnsiString{$ELSE}string{$ENDIF}): boolean;
    function AppendFromScript(const aScript: string; const doCompile, doRun: boolean;
      var Data: {$IFDEF UNICODE}AnsiString{$ELSE}string{$ENDIF}): boolean;
    function LoadFromStream(const aStream: TStream): boolean;
    function AppendFromStream(const aStream: TStream): boolean;
    function LoadFromFile(const aFileName: string): boolean;
    function AppendFromFile(const aFileName: string): boolean;
    procedure SaveToStream(const aStream: TStream);
    procedure SaveToFile(const aFileName: string);
    function RenderToBuffer: integer;
    function VoxelItemAt(const x, y, z: byte): LongWord;
    property NumCmds: integer read fNumCmds;
  end;

procedure VDLS_SetVoxel(const x, y, z: byte; const value: LongWord);
procedure VDLS_ClearVoxel(const value: LongWord);
procedure VDLS_Clear;
function VDLS_GetVoxel(const x, y, z: byte): LongWord;
function VDLS_VoxelSize: Integer;
function VDLS_RGB(const r, g, b: byte): LongWord;
function VDLS_GetRValue(const c: LongWord): LongWord;
function VDLS_GetGValue(const c: LongWord): LongWord;
function VDLS_GetBValue(const c: LongWord): LongWord;

implementation

uses
  psv_script,
  psv_script_functions,
  frm_Editor,
  main,
  psv_VXTextures,
  psv_VXVoxels,
  psv_temp;

var
  currentvoxelloader: TDDVoxelScriptLoader;

constructor TDDVoxelScriptLoader.Create(const abuf: voxelbuffer_p; const asz: integer);
begin
  fNumCmds := 0;
  fRealNumCmds := 0;
  fCmds := nil;
  voxelbuf := abuf;
  voxelsz := asz;
  inherited Create;
end;

destructor TDDVoxelScriptLoader.Destroy;
begin
  Clear;
  inherited;
end;

function TDDVoxelScriptLoader.Grow: voxelcmd_p;
begin
  Inc(fNumCmds);
  if fNumCmds >= fRealNumCmds then
  begin
    fRealNumCmds := fRealNumCmds + 1024;
    ReallocMem(fCmds, fRealNumCmds * SizeOf(voxelcmd_t));
  end;
  Result := @fCmds[fNumCmds - 1];
end;

procedure TDDVoxelScriptLoader.AddCmd(const cmd: integer; const x, y, z: byte;
  const cl: LongWord);
var
  pc: voxelcmd_p;
begin
  pc := Grow;
  pc.cmd := cmd;
  pc.x := x;
  pc.y := y;
  pc.z := z;
  pc.Color := cl;
end;

procedure TDDVoxelScriptLoader.Clear;
begin
  ReallocMem(fCmds, 0);
  fNumCmds := 0;
  fRealNumCmds := 0;
end;

function TDDVoxelScriptLoader.LoadFromScript(const aScript: string; const doCompile, doRun: boolean;
  var Data: {$IFDEF UNICODE}AnsiString{$ELSE}string{$ENDIF}): boolean;
begin
  Clear;
  Result := AppendFromScript(aScript, doCompile, doRun, Data);
end;

function TDDVoxelScriptLoader.AppendFromScript(const aScript: string; const doCompile, doRun: boolean;
  var Data: {$IFDEF UNICODE}AnsiString{$ELSE}string{$ENDIF}): boolean;
begin
  currentvoxelloader := Self;
  VXT_ResetTextures;
  VXT_ResetVoxels;
  VXT_ClearSearchPaths;
  VXT_AddSearchPath(ExtractFilePath(EditorForm.FileName));
  VXT_AddSearchPath(ExtractFilePath(Form1.FileName));
  VXT_AddSearchPath(ExtractFilePath(ParamStr(0)));
  VXT_AddSearchPath(GetCurrentDir);
  Result := VDL_CompileScript(aScript, doCompile, doRun, Data);
  VXT_ResetTextures;
  VXT_ResetVoxels;
  VXT_ClearSearchPaths;
end;

function TDDVoxelScriptLoader.LoadFromStream(const aStream: TStream): boolean;
begin
  Clear;
  Result := AppendFromStream(aStream);
end;

function TDDVoxelScriptLoader.AppendFromStream(const aStream: TStream): boolean;
var
  header: integer;
  sz: integer;
begin
  aStream.Read(header, SizeOf(integer));
  if header <> VDL_MAGIC then
  begin
    Result := False;
    Exit;
  end;
  aStream.Read(sz, SizeOf(integer));
  if sz < 0 then
  begin
    Result := False;
    Exit;
  end;
  fNumCmds := sz;
  fRealNumCmds := sz;
  ReallocMem(fCmds, fNumCmds * SizeOf(voxelcmd_t));
  aStream.Read(fCmds^, fNumCmds * SizeOf(voxelcmd_t));
  Result := True;
end;

function TDDVoxelScriptLoader.LoadFromFile(const aFileName: string): boolean;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(aFileName, fmOpenRead);
  try
    Result := LoadFromStream(fs);
  finally
    fs.Free;
  end;
end;

function TDDVoxelScriptLoader.AppendFromFile(const aFileName: string): boolean;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(aFileName, fmOpenRead);
  try
    Result := AppendFromStream(fs);
  finally
    fs.Free;
  end;
end;

procedure TDDVoxelScriptLoader.SaveToStream(const aStream: TStream);
var
  header: integer;
  sz: integer;
begin
  header := VDL_MAGIC;
  aStream.Write(header, SizeOf(integer));
  sz := fNumCmds;
  aStream.Write(sz, SizeOf(integer));
  aStream.Write(fCmds^, sz * SizeOf(voxelcmd_t));
end;

procedure TDDVoxelScriptLoader.SaveToFile(const aFileName: string);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(aFileName, fmOpenReadWrite or fmCreate);
  try
    SaveToStream(fs);
  finally
    fs.Free;
  end;
end;

function TDDVoxelScriptLoader.RenderToBuffer: integer;
var
  cnt, i, j, k: integer;
  pc: voxelcmd_p;
begin
  Result := 0;
  for cnt := 0 to fNumCmds - 1 do
  begin
    pc := @fCmds[cnt];

    case pc.cmd of
      C_vxSet:
        if pc.x < voxelsz then
          if pc.y < voxelsz then
            if pc.z < voxelsz then
              if voxelbuf[pc.x, pc.y, pc.z] <> pc.Color then
              begin
                voxelbuf[pc.x, pc.y, pc.z] := pc.Color;
                Inc(Result);
              end;
      C_vxClear:
        for i := 0 to voxelsz - 1 do
          for j := 0 to voxelsz - 1 do
            for k := 0 to voxelsz - 1 do
              if voxelbuf[i, j, k] <> pc.Color then
              begin
                voxelbuf[i, j, k] := pc.Color;
                Inc(Result);
              end;
    end;
  end;
end;

function TDDVoxelScriptLoader.VoxelItemAt(const x, y, z: byte): LongWord;
begin
  if (x >= voxelsz) or (y >= voxelsz) or (z >= voxelsz) then
    Result := 0
  else
    Result := voxelbuf[x, y, z];
end;

//-------------------------- PascalScript Functions ----------------------------

procedure VDLS_SetVoxel(const x, y, z: byte; const value: LongWord);
begin
  if currentvoxelloader = nil then
  begin
    printf('VDLS_SetVoxel(): No voxel loader available'#13#10);
    Exit;
  end;
  currentvoxelloader.AddCmd(C_vxSet, x, y, z, value);
end;

procedure VDLS_ClearVoxel(const value: LongWord);
begin
  if currentvoxelloader = nil then
  begin
    printf('VDLS_ClearVoxel(): No voxel loader available'#13#10);
    Exit;
  end;
  currentvoxelloader.AddCmd(C_vxClear, 0, 0, 0, value);
end;

procedure VDLS_Clear;
begin
  if currentvoxelloader = nil then
  begin
    printf('VDLS_Clear(): No voxel loader available'#13#10);
    Exit;
  end;
  currentvoxelloader.AddCmd(C_vxClear, 0, 0, 0, 0);
end;

function VDLS_GetVoxel(const x, y, z: byte): LongWord;
begin
  if currentvoxelloader = nil then
  begin
    printf('VDLS_Clear(): No voxel loader available'#13#10);
    Result := 0;
    Exit;
  end;
  Result := currentvoxelloader.VoxelItemAt(x, y, z);
end;

function VDLS_VoxelSize: Integer;
begin
  if currentvoxelloader = nil then
  begin
    printf('VDLS_VoxelSize(): No voxel loader available'#13#10);
    Result := 0;
    Exit;
  end;
  Result := currentvoxelloader.voxelsz;
end;

function VDLS_RGB(const r, g, b: byte): LongWord;
begin
  Result := (r or (g shl 8) or (b shl 16));
end;

function VDLS_GetRValue(const c: LongWord): LongWord;
begin
  Result := Byte(c);
end;

function VDLS_GetGValue(const c: LongWord): LongWord;
begin
  Result := Byte(c shr 8);
end;

function VDLS_GetBValue(const c: LongWord): LongWord;
begin
  Result := Byte(c shr 16);
end;

end.
