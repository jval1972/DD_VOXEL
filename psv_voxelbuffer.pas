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
//  Voxelbuffer RTL object
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit psv_voxelbuffer;

interface

uses
  uPSCompiler, uPSRuntime;

type
  TVoxelBuffer = class(TObject)
  protected
    function Get(x, y, z: byte): LongWord; virtual;
    procedure Put(x, y, z: byte; const value: LongWord); virtual;
  public
    constructor Create; virtual;
    property value[x, y, z: byte]: LongWord read Get write Put; default;
    procedure ClearColor(c: LongWord);
    procedure Clear;
  end;

procedure SIRegister_VoxelBuffer(CL: TPSPascalCompiler);

procedure RIRegister_VoxelBuffer(CL: TPSRuntimeClassImporter);

procedure RIRegisterRTL_VoxelBuffer(Exec: TPSExec);

implementation

uses
  psv_voxel;

function TVoxelBuffer.Get(x, y, z: byte): LongWord;
begin
  Result := VDLS_GetVoxel(x, y, z);
end;

procedure TVoxelBuffer.Put(x, y, z: byte; const value: LongWord);
begin
  VDLS_SetVoxel(x, y, z, value);
end;

procedure TVoxelBuffer.ClearColor(c: LongWord);
begin
  VDLS_ClearVoxel(c);
end;

procedure TVoxelBuffer.Clear;
begin
  VDLS_Clear;
end;

constructor TVoxelBuffer.Create;
begin
  Inherited;
end;

procedure SIRegister_VoxelBuffer(CL: TPSPascalCompiler);
begin
  with CL.AddClassN(CL.FindClass('!TOBJECT'), '!TVoxelBuffer') do
  begin
    RegisterMethod('constructor Create');
    RegisterMethod('procedure ClearColor(c: LongWord)');
    RegisterMethod('procedure Clear');
    RegisterProperty('value', 'longword byte byte byte', iptRW);
    SetDefaultPropery('value');
  end;
  AddImportedClassVariable(CL, 'VoxelBuffer', '!TVoxelBuffer');
end;

procedure TVoxelBuffervalue_W(Self: TVoxelBuffer; const T: LongWord; const x, y, z: byte);
begin
  Self.value[x, y, z] := T;
end;

procedure TVoxelBuffervalue_R(Self: TVoxelBuffer; var T: LongWord; const x, y, z: byte);
begin
  T := Self.value[x, y, z];
end;

procedure RIRegister_VoxelBuffer(CL: TPSRuntimeClassImporter);
begin
  with CL.Add2(TVoxelBuffer, '!TVOXELBUFFER') do
  begin
    RegisterConstructor(@TVoxelBuffer.Create, 'Create');
    RegisterMethod(@TVoxelBuffer.ClearColor, 'ClearColor');
    RegisterMethod(@TVoxelBuffer.Clear, 'Clear');
    RegisterPropertyHelper(@TVoxelBuffervalue_R, @TVoxelBuffervalue_W, 'value');
  end;
end;

var
  RTL_VoxelBuffer: TVoxelBuffer;

procedure RIRegisterRTL_VoxelBuffer(Exec: TPSExec);
begin
  SetVariantToClass(Exec.GetVarNo(Exec.GetVar('voxelbuffer')), RTL_VoxelBuffer);
end;

initialization
  RTL_VoxelBuffer := TVoxelBuffer.Create;

finalization
  RTL_VoxelBuffer.Free;

end.
