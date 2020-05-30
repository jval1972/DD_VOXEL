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
//  Script functions import
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit psv_script_proclist;

interface

uses
  vxe_utils,
  uPSCompiler,
  uPSRuntime;

type
  procitem_t = record
    proc: Pointer;
    decl: TString;
    name: TString;
    exportdecl: TString;
    iscomputed: boolean;
  end;
  Pprocitem_t = ^procitem_t;
  procitem_tArray = array[0..$FFF] of procitem_t;
  Pprocitem_tArray = ^procitem_tArray;

type
  TProcedureList = class(TObject)
  private
    fList: Pprocitem_tArray;
    fNumItems: integer;
    fRealSize: integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Add(const decl: string; const proc: pointer); virtual;
    procedure RegisterProcsComp(Sender: TPSPascalCompiler); virtual;
    procedure RegisterProcsExec(Sender: TPSExec); virtual;
    procedure Reset;
    function GetDeclarations: string;
    function GetFunctionNames: string;
    property Count: integer read fNumItems;
  end;

procedure VDL_InitProcList;

procedure VDL_ShutDownProcList;

procedure VDL_RegisterProcsCompiler(const C: TPSPascalCompiler);

procedure VDL_RegisterProcsExec(const E: TPSExec);

function VDL_Procs: string;

implementation

uses
  SysUtils,
  psv_voxel,
  psv_script_functions;

constructor TProcedureList.Create;
begin
  fList := nil;
  fNumItems := 0;
  fRealSize := 0;
  inherited Create;
end;


destructor TProcedureList.Destroy;
var
  i: integer;
begin
  if fRealSize > 0 then
  begin
    for i := 0 to fRealSize - 1 do
    begin
      fList[i].decl.Free;
      fList[i].name.Free;
      fList[i].exportdecl.Free;
    end;
    ReallocMem(fList, 0);
  end;

  inherited;
end;

procedure TProcedureList.Add(const decl: string; const proc: pointer);
const
  REALLOCSTEP = 16;
var
  i: integer;
  decl1: string;
begin
  decl1 := Trim(decl);
  if decl1 = '' then
    Exit;

  if decl1[Length(decl1)] <> ';' then
    decl1 := decl1 + ';';
  if fNumItems >= fRealSize then
  begin
    ReallocMem(fList, (fRealSize + REALLOCSTEP) * SizeOf(procitem_t));
    for i := fRealSize to fRealSize + REALLOCSTEP - 1 do
    begin
      fList[i].decl := TString.Create('');
      fList[i].name := TString.Create('');
      fList[i].exportdecl := TString.Create('');
    end;
    fRealSize := fRealSize + REALLOCSTEP;
  end;
  fList[fNumItems].proc := proc;
  fList[fNumItems].decl.str := decl1;
  fList[fNumItems].exportdecl.str := decl1;
  fList[fNumItems].iscomputed := true;
  inc(fNumItems);
end;

procedure TProcedureList.RegisterProcsComp(Sender: TPSPascalCompiler);
var
  i: integer;
  reg: TPSRegProc;
begin
  for i := 0 to fNumItems - 1 do
  begin
    reg := Sender.AddDelphiFunction(fList[i].decl.str);
    if reg <> nil then
    begin
      fList[i].name.str := reg.Name;
      fList[i].iscomputed := true;
    end;
  end;
end;

procedure TProcedureList.RegisterProcsExec(Sender: TPSExec);
var
  i: integer;
begin
  for i := 0 to fNumItems - 1 do
    if fList[i].iscomputed then
      Sender.RegisterDelphiFunction(fList[i].proc, fList[i].name.str, cdRegister);
end;

procedure TProcedureList.Reset;
var
  i: integer;
begin
  for i := 0 to fNumItems - 1 do
    fList[i].iscomputed := false;
end;

function TProcedureList.GetDeclarations: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to fNumItems - 1 do
    Result := Result + flist[i].exportdecl.str + #13#10;
end;

function TProcedureList.GetFunctionNames: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to fNumItems - 1 do
    Result := Result + flist[i].name.str + #13#10;
end;

var
  proclist: TProcedureList;

procedure VDL_InitProcList;
begin
  proclist := TProcedureList.Create;

  //--- base functions
  proclist.Add('procedure Write(const parm: string);', @VDLS_Write);
  proclist.Add('procedure WriteFmt(const Fmt: string; const args: array of const);', @VDLS_WriteFmt);
  proclist.Add('procedure Writeln(const parm: string);', @VDLS_Writeln);
  proclist.Add('procedure WritelnFmt(const Fmt: string; const args: array of const);', @VDLS_WritelnFmt);
  proclist.Add('procedure BreakPoint(const msg: string);', @VDLS_BreakPoint);
  proclist.Add('function Tan(const parm: Extended): Extended;', @VDLS_Tan);
  proclist.Add('function Sin360(const parm: Extended): Extended;', @VDLS_Sin360);
  proclist.Add('function Cos360(const parm: Extended): Extended;', @VDLS_Cos360);
  proclist.Add('function Tan360(const parm: Extended): Extended;', @VDLS_Tan360);
  proclist.Add('function Format(const Fmt: string; const args: array of const): string;', @VDLS_Format);
  proclist.Add('function IFI(const condition: boolean; const iftrue, iffalse: Int64): Int64;', @VDLS_IFI);
  proclist.Add('function IFF(const condition: boolean; const iftrue, iffalse: Extended): Extended;', @VDLS_IFF);
  proclist.Add('function IFS(const condition: boolean; const iftrue, iffalse: string): string;', @VDLS_IFS);
  proclist.Add('function Odd(const x: integer): boolean;', @VDLS_Odd);
  proclist.Add('function Even(const x: integer): boolean;', @VDLS_Even);
  proclist.Add('function MergeIntegerArrays(const A1, A2: TIntegerArray): TIntegerArray;', @VDLS_MergeIntegerArrays);
  proclist.Add('function MergeInt64Arrays(const A1, A2: TInt64Array): TInt64Array;', @VDLS_MergeInt64Arrays);
  proclist.Add('function MergeLongWordArrays(const A1, A2: TLongWordArray): TLongWordArray;', @VDLS_MergeLongWordArrays);
  proclist.Add('function MergeSingleArrays(const A1, A2: TSingleArray): TSingleArray;', @VDLS_MergeSingleArrays);
  proclist.Add('function MergeFloatArrays(const A1, A2: TFloatArray): TFloatArray;', @VDLS_MergeSingleArrays);
  proclist.Add('function MergeDoubleArrays(const A1, A2: TDoubleArray): TDoubleArray;', @VDLS_MergeDoubleArrays);
  proclist.Add('function MergeExtendedArrays(const A1, A2: TExtendedArray): TExtendedArray;', @VDLS_MergeExtendedArrays);
  proclist.Add('function IsPrime(const N: Int64): Boolean;', @VDLS_IsPrime);
  proclist.Add('function IsIntegerInRange(const test, f1, f2: integer): boolean;', @VDLS_IsIntegerInRange);
  proclist.Add('function IsLongWordInRange(const test, f1, f2: LongWord): boolean;', @VDLS_IsLongWordInRange);
  proclist.Add('function IsFloatInRange(const test, f1, f2: single): boolean;', @VDLS_IsFloatInRange);
  proclist.Add('function IsSingleInRange(const test, f1, f2: single): boolean;', @VDLS_IsFloatInRange);
  proclist.Add('function IsDoubleInRange(const test, f1, f2: double): boolean;', @VDLS_IsDoubleInRange);
  proclist.Add('function IsExtendedInRange(const test, f1, f2: Extended): boolean;', @VDLS_IsExtendedInRange);
  proclist.Add('function Sqr(const x: Extended): Extended;', @VDLS_Sqr);
  proclist.Add('function Sqrt(const x: Extended): Extended;', @VDLS_Sqrt);
  proclist.Add('function Cube(const x: Extended): Extended;', @VDLS_Cube);
  proclist.Add('function ArcCos(const X : Extended) : Extended;', @VDLS_ArcCos);
  proclist.Add('function ArcSin(const X : Extended) : Extended;', @VDLS_ArcSin);
  proclist.Add('function ArcTan2(const Y, X: Extended): Extended;', @VDLS_ArcTan2);
  proclist.Add('procedure SinCosE(const Theta: Extended; var S, C: Extended);', @VDLS_SinCosE);
  proclist.Add('procedure SinCosD(const Theta: Extended; var S, C: Double);', @VDLS_SinCosD);
  proclist.Add('procedure SinCosF(const Theta: Extended; var S, C: Single);', @VDLS_SinCosF);
  proclist.Add('function Cosh(const X: Extended): Extended;', @VDLS_Cosh);
  proclist.Add('function Sinh(const X: Extended): Extended;', @VDLS_Sinh);
  proclist.Add('function Tanh(const X: Extended): Extended;', @VDLS_Tanh);
  proclist.Add('function ArcCosh(const X: Extended): Extended;', @VDLS_ArcCosh);
  proclist.Add('function ArcSinh(const X: Extended): Extended;', @VDLS_ArcSinh);
  proclist.Add('function ArcTanh(const X: Extended): Extended;', @VDLS_ArcTanh);
  proclist.Add('function Log10(const X: Extended): Extended;', @VDLS_Log10);
  proclist.Add('function Log2(const X: Extended): Extended;', @VDLS_Log2);
  proclist.Add('function Ln(const X: Extended): Extended;', @VDLS_Ln);
  proclist.Add('function LogN(const Base, X: Extended): Extended;', @VDLS_LogN);
  proclist.Add('function IntPower(const Base: Extended; const Exponent: Integer): Extended;', @VDLS_IntPower);
  proclist.Add('function Power(const Base, Exponent: Extended): Extended;', @VDLS_Power);
  proclist.Add('function Ceil(const X: Extended):Integer;', @VDLS_Ceil);
  proclist.Add('function Floor(const X: Extended): Integer;', @VDLS_Floor);
  //--- voxel drawing
  proclist.Add('procedure SetVoxel(const x, y, z: byte; const value: LongWord);', @VDLS_SetVoxel);
  proclist.Add('function GetVoxel(const x, y, z: byte): LongWord;', @VDLS_GetVoxel);
  proclist.Add('procedure ClearVoxel(const value: LongWord);', @VDLS_ClearVoxel);
  proclist.Add('function voxelSize: Integer;', @VDLS_VoxelSize);
  proclist.Add('procedure Clear;', @VDLS_Clear);
  proclist.Add('function RGB(const r, g, b: byte): LongWord;', @VDLS_RGB);
  proclist.Add('function GetRValue(const c: LongWord): LongWord;', @VDLS_GetRValue);
  proclist.Add('function GetGValue(const c: LongWord): LongWord;', @VDLS_GetGValue);
  proclist.Add('function GetBValue(const c: LongWord): LongWord;', @VDLS_GetBValue);
end;

procedure VDL_ShutDownProcList;
begin
  proclist.Free;
end;

procedure VDL_RegisterProcsCompiler(const C: TPSPascalCompiler);
begin
  proclist.RegisterProcsComp(C);
end;

procedure VDL_RegisterProcsExec(const E: TPSExec);
begin
  proclist.RegisterProcsExec(E);
end;

function VDL_Procs: string;
begin
  VDL_InitProcList;
  result := proclist.GetDeclarations;
  VDL_ShutDownProcList;
end;

end.
