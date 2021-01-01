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
//  Script main execute function
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit psv_script;

interface

uses
  SysUtils,
  Classes;

function VDL_CompileScript(const Script: string; const doRun: boolean): boolean;

implementation

uses
  uPSC_buttons,
  uPSC_classes,
  uPSC_comobj,
  uPSC_controls,
  uPSC_dateutils,
  uPSC_DB,
  uPSC_extctrls,
  uPSC_forms,
  uPSC_graphics,
  uPSC_menus,
  uPSC_std,
  uPSC_stdctrls,
  uPSC_dll,
  uPSR_buttons,
  uPSR_classes,
  uPSR_comobj,
  uPSR_controls,
  uPSR_dateutils,
  uPSR_DB,
  uPSR_extctrls,
  uPSR_forms,
  uPSR_graphics,
  uPSR_menus,
  uPSR_std,
  uPSR_stdctrls,
  uPSR_dll,
  Forms,
  psv_script_proclist,
  psv_script_functions,
  psv_voxelbuffer,
  psv_VXTextures,
  psv_VXVoxels,
  uPSCompiler,
  uPSRuntime;

function ScriptOnUses(Sender: TPSPascalCompiler; const Name: string): Boolean;
var
  uT_extended: TPSType;
  uT_integer: TPSType;
begin
  if Name = 'SYSTEM' then
  begin
    Sender.AddTypeS('TIntegerArray', 'array of integer');
    Sender.AddTypeS('TInt64Array', 'array of int64');
    Sender.AddTypeS('TLongWordArray', 'array of LongWord');
    Sender.AddTypeS('TSingleArray', 'array of single');
    Sender.AddTypeS('TFloatArray', 'array of single');
    Sender.AddTypeS('TDoubleArray', 'array of double');
    Sender.AddTypeS('TExtendedArray', 'array of extended');
    Sender.AddTypeS('float', 'single');
    Sender.AddTypeS('real', 'double');

    uT_extended := Sender.FindType('extended');
    Sender.AddConstant('NaN', uT_extended).Value.textended := 0.0 / 0.0;
    Sender.AddConstant('Infinity', uT_extended).Value.textended := 1.0 / 0.0;
    Sender.AddConstant('NegInfinity', uT_extended).Value.textended := - 1.0 / 0.0;

    uT_integer := Sender.FindType('integer');
    Sender.AddConstant('MAXINT', uT_integer).Value.ts32 := MAXINT;

    VDL_RegisterProcsCompiler(Sender);

    SIRegister_VoxelBuffer(Sender);
    SIRegister_VXTextures(Sender);
    SIRegister_VXVoxels(Sender);

    SIRegister_Std(Sender);
    SIRegister_Classes(Sender, True);
    SIRegister_Controls(Sender);
    SIRegister_StdCtrls(Sender);
    SIRegister_Buttons(Sender);
    SIRegister_ComObj(Sender);
    RegisterDateTimeLibrary_C(Sender);
    SIRegister_DB(Sender);
    RegisterDll_Compiletime(Sender);
    SIRegister_ExtCtrls(Sender);
    SIRegister_Forms(Sender);
    SIRegister_Graphics(Sender, True);
    SIRegister_Menus(Sender);

    AddImportedClassVariable(Sender, 'Self', 'TForm');
    AddImportedClassVariable(Sender, 'Application', 'TApplication');

    Result := True;
  end
  else
    Result := False;
end;

type
  TRTLObject = class(TObject)
  public
    procedure FakeFree;
  end;

procedure TRTLObject.FakeFree;
begin
  // JVAL: Do nothing :)
  // Explanation:
  //   Since we can only use imported classes usage of Free procedure inside script could cause problems.
  //   Instead we use a stub method, and we leave the actual Free of the objects to the calling Application
end;

function VDL_CompileScript(const Script: string; const doRun: boolean): boolean;
var
  i: integer;
  Compiler: TPSPascalCompiler;
  importer: TPSRuntimeClassImporter;
  Exec: TPSExec;
  {$IFDEF UNICODE}Data: AnsiString;{$ELSE}Data: string;{$ENDIF}
begin
  VDL_InitProcList;

  Compiler := TPSPascalCompiler.Create; // create an instance of the compiler.
  Compiler.OnUses := ScriptOnUses; // assign the OnUses event.
  if not Compiler.Compile(Script) then  // Compile the Pascal script into bytecode.
  begin
    for i := 0 to Compiler.MsgCount - 1 do
      printf(Format('Pos: %.*d, "%s"', [6,  compiler.Msg[i].Pos, compiler.Msg[i].MessageToString]));

    Compiler.Free;
    VDL_ShutDownProcList;
    Result := False;
    Exit;
  end;

  Compiler.GetOutput(Data); // Save the output of the compiler in the string Data.
  Compiler.Free; // After compiling the script, there is no need for the compiler anymore.

  printf('Compile successful'#13#10);

  if doRun then
  begin
    importer := TPSRuntimeClassImporter.Create;
    with importer.Add2(TRTLObject, '!TOBJECT') do
    begin
      RegisterConstructor(@TRTLObject.Create, 'Create');
      RegisterMethod(@TRTLObject.FakeFree, 'Free');
    end;
    RIRegister_VoxelBuffer(importer);
    RIRegister_VXTextures(importer);
    RIRegister_VXVoxels(importer);

    Exec := TPSExec.Create;  // Create an instance of the executer.

  //  Exec.AllowNullClasses := True;
    RegisterClassLibraryRuntime(Exec, importer);

    VDL_RegisterProcsExec(Exec);

    RIRegister_Std(importer);
    RIRegister_Classes(importer, True);
    RIRegister_Controls(importer);
    RIRegister_stdctrls(importer);
    RIRegister_Buttons(importer);
    RIRegister_ComObj(Exec);
    RegisterDateTimeLibrary_R(Exec);
    RIRegister_DB(importer);
    RegisterDLLRuntime(Exec);
    RIRegister_ExtCtrls(importer);
    RIRegister_Forms(importer);
    RIRegister_Graphics(importer, True);
    RIRegister_Menus(importer);

    SetVariantToClass(Exec.GetVarNo(Exec.GetVar('SELF')), Application.MainForm);
    SetVariantToClass(Exec.GetVarNo(Exec.GetVar('APPLICATION')), Application);

    if not Exec.LoadData(Data) then // Load the data from the Data string.
    begin
      printf('Can not run script, internal error!');
      { For some reason the script could not be loaded. This is usually the case when a
        library that has been used at compile time isn't registered at runtime. }
      Exec.Free;
       // You could raise an exception here.
      VDL_ShutDownProcList;
      Result := False;
      Exit;
    end;
    RIRegisterRTL_VoxelBuffer(exec);
    RIRegisterRTL_VXTextures(exec);
    RIRegisterRTL_VXVoxels(exec);

    printf('Running...'#13#10);
    Exec.RunScript; // Run the script.
    Exec.Free; // Free the executer.
    importer.Free;

    printf('Done'#13#10);
  end;
  VDL_ShutDownProcList;
  Result := True;
end;

end.

