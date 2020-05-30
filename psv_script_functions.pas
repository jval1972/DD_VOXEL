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
//  Script functions library
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit psv_script_functions;

interface

// --------------------------- general -----------------------------------------

type
  TDynamicIntegerArray = array of Integer;
  TDynamicInt64Array = array of Int64;
  TDynamicLongWordArray = array of LongWord;
  TDynamicSingleArray = array of single;
  TDynamicDoubleArray = array of double;
  TDynamicExtendedArray = array of extended;

procedure VDLS_Write(const parm: string);

procedure VDLS_WriteFmt(const Fmt: string; const args: array of const);

procedure VDLS_Writeln(const parm: string);

procedure VDLS_WritelnFmt(const Fmt: string; const args: array of const);

procedure VDLS_BreakPoint(const msg: string);

function VDLS_Tan(const parm: Extended): Extended;

function VDLS_Sin360(const parm: Extended): Extended;

function VDLS_Cos360(const parm: Extended): Extended;

function VDLS_Tan360(const parm: Extended): Extended;

function VDLS_Format(const Fmt: string; const args: array of const): string;

function VDLS_IFI(const condition: boolean; const iftrue, iffalse: Int64): Int64;

function VDLS_IFF(const condition: boolean; const iftrue, iffalse: Extended): Extended;

function VDLS_IFS(const condition: boolean; const iftrue, iffalse: string): string;

function VDLS_Odd(const x: integer): boolean;

function VDLS_Even(const x: integer): boolean;

function VDLS_MergeIntegerArrays(const A1, A2: TDynamicIntegerArray): TDynamicIntegerArray;

function VDLS_MergeInt64Arrays(const A1, A2: TDynamicInt64Array): TDynamicInt64Array;

function VDLS_MergeLongWordArrays(const A1, A2: TDynamicLongWordArray): TDynamicLongWordArray;

function VDLS_MergeSingleArrays(const A1, A2: TDynamicSingleArray): TDynamicSingleArray;

function VDLS_MergeDoubleArrays(const A1, A2: TDynamicDoubleArray): TDynamicDoubleArray;

function VDLS_MergeExtendedArrays(const A1, A2: TDynamicExtendedArray): TDynamicExtendedArray;

function VDLS_IsPrime(const N: Int64): Boolean;

function VDLS_IsIntegerInRange(const test, f1, f2: integer): boolean;

function VDLS_IsLongWordInRange(const test, f1, f2: LongWord): boolean;

function VDLS_IsFloatInRange(const test, f1, f2: single): boolean;

function VDLS_IsDoubleInRange(const test, f1, f2: double): boolean;

function VDLS_IsExtendedInRange(const test, f1, f2: Extended): boolean;

function VDLS_Sqr(const x: Extended): Extended;

function VDLS_Sqrt(const x: Extended): Extended;

function VDLS_Cube(const x: Extended): Extended;

function VDLS_ArcCos(const X: Extended): Extended;

function VDLS_ArcSin(const X: Extended): Extended;

function VDLS_ArcTan2(const Y, X: Extended): Extended;

procedure VDLS_SinCosE(const Theta: Extended; var S, C: Extended);

procedure VDLS_SinCosD(const Theta: Extended; var S, C: Double);

procedure VDLS_SinCosF(const Theta: Extended; var S, C: Single);

function VDLS_Cosh(const X: Extended): Extended;

function VDLS_Sinh(const X: Extended): Extended;

function VDLS_Tanh(const X: Extended): Extended;

function VDLS_ArcCosh(const X: Extended): Extended;

function VDLS_ArcSinh(const X: Extended): Extended;

function VDLS_ArcTanh(const X: Extended): Extended;

function VDLS_Log10(const X: Extended): Extended;

function VDLS_Log2(const X: Extended): Extended;

function VDLS_Ln(const X: Extended): Extended;

function VDLS_LogN(const Base, X: Extended): Extended;

function VDLS_IntPower(const Base: Extended; const Exponent: Integer): Extended;

function VDLS_Power(const Base, Exponent: Extended): Extended;

function VDLS_Ceil(const X: Extended):Integer;

function VDLS_Floor(const X: Extended): Integer;

type
  outproc_t = procedure(const s: string);

var
  outproc: outproc_t;

procedure printf(const s: string);

// ---------------------------- opengl -----------------------------------------

implementation

uses
  SysUtils,
  Math;

procedure printf(const s: string);
begin
  if Assigned(outproc) then
    outproc(s);
end;

procedure VDLS_Write(const parm: string);
begin
  printf(parm);
end;

procedure VDLS_WriteFmt(const Fmt: string; const args: array of const);
begin
  VDLS_Write(VDLS_Format(Fmt, args));
end;

procedure VDLS_Writeln(const parm: string);
begin
  printf(parm + #13#10);
end;

procedure VDLS_WritelnFmt(const Fmt: string; const args: array of const);
begin
  VDLS_Writeln(VDLS_Format(Fmt, args));
end;

var
  bpmsg: string = '';

// Actually for debuging the engine, not script
procedure VDLS_BreakPoint(const msg: string);
begin
  bpmsg := msg;
end;

function VDLS_Tan(const parm: Extended): Extended;
begin
  Result := tan(parm);
end;

function VDLS_Sin360(const parm: Extended): Extended;
begin
  Result := sin(parm / 360 * 2 * pi);
end;

function VDLS_Cos360(const parm: Extended): Extended;
begin
  Result := cos(parm / 360 * 2 * pi);
end;

function VDLS_Tan360(const parm: Extended): Extended;
begin
  Result := tan(parm / 360 * 2 * pi);
end;

function VDLS_Format(const Fmt: string; const args: array of const): string;
begin
  try
    Result := Format(Fmt, Args);
  except
    Result := Fmt;
  end;
end;

function VDLS_IFI(const condition: boolean; const iftrue, iffalse: Int64): Int64;
begin
  if condition then
    Result := iftrue
  else
    Result := iffalse;
end;

function VDLS_IFF(const condition: boolean; const iftrue, iffalse: Extended): Extended;
begin
  if condition then
    Result := iftrue
  else
    Result := iffalse;
end;

function VDLS_IFS(const condition: boolean; const iftrue, iffalse: string): string;
begin
  if condition then
    Result := iftrue
  else
    Result := iffalse;
end;

function VDLS_Odd(const x: integer): boolean;
begin
  Result := Odd(x);
end;

function VDLS_Even(const x: integer): boolean;
begin
  Result := not Odd(x);
end;

function VDLS_MergeIntegerArrays(const A1, A2: TDynamicIntegerArray): TDynamicIntegerArray;
var
  l1, l2: integer;
  i: integer;
begin
  l1 := Length(A1);
  l2 := Length(A2);
  SetLength(Result, l1 + l2);
  for i := 0 to l1 - 1 do
    Result[i] := A1[i];
  for i := 0 to l2 - 1 do
    Result[l1 + i] := A2[i];
end;

function VDLS_MergeInt64Arrays(const A1, A2: TDynamicInt64Array): TDynamicInt64Array;
var
  l1, l2: integer;
  i: integer;
begin
  l1 := Length(A1);
  l2 := Length(A2);
  SetLength(Result, l1 + l2);
  for i := 0 to l1 - 1 do
    Result[i] := A1[i];
  for i := 0 to l2 - 1 do
    Result[l1 + i] := A2[i];
end;

function VDLS_MergeLongWordArrays(const A1, A2: TDynamicLongWordArray): TDynamicLongWordArray;
var
  l1, l2: integer;
  i: integer;
begin
  l1 := Length(A1);
  l2 := Length(A2);
  SetLength(Result, l1 + l2);
  for i := 0 to l1 - 1 do
    Result[i] := A1[i];
  for i := 0 to l2 - 1 do
    Result[l1 + i] := A2[i];
end;

function VDLS_MergeSingleArrays(const A1, A2: TDynamicSingleArray): TDynamicSingleArray;
var
  l1, l2: integer;
  i: integer;
begin
  l1 := Length(A1);
  l2 := Length(A2);
  SetLength(Result, l1 + l2);
  for i := 0 to l1 - 1 do
    Result[i] := A1[i];
  for i := 0 to l2 - 1 do
    Result[l1 + i] := A2[i];
end;

function VDLS_MergeDoubleArrays(const A1, A2: TDynamicDoubleArray): TDynamicDoubleArray;
var
  l1, l2: integer;
  i: integer;
begin
  l1 := Length(A1);
  l2 := Length(A2);
  SetLength(Result, l1 + l2);
  for i := 0 to l1 - 1 do
    Result[i] := A1[i];
  for i := 0 to l2 - 1 do
    Result[l1 + i] := A2[i];
end;

function VDLS_MergeExtendedArrays(const A1, A2: TDynamicExtendedArray): TDynamicExtendedArray;
var
  l1, l2: integer;
  i: integer;
begin
  l1 := Length(A1);
  l2 := Length(A2);
  SetLength(Result, l1 + l2);
  for i := 0 to l1 - 1 do
    Result[i] := A1[i];
  for i := 0 to l2 - 1 do
    Result[l1 + i] := A2[i];
end;

function VDLS_IsPrime(const N: Int64): Boolean;
var
  Test, k: Int64;
  ee: Extended;
begin
  if N <= 3 then
    Result := N > 1
  else if ((N mod 2) = 0) or ((N mod 3) = 0) then
    Result := False
  else
  begin
    Result := True;
    ee := N;
    k := Trunc(Sqrt(ee));
    Test := 5;
    while Test <= k do
    begin
      if ((N mod Test) = 0) or ((N mod (Test + 2)) = 0) then
      begin
        Result := False;
        break; // jump out of the for loop
      end;
      Test := Test + 6;
    end;
  end;
end;

function VDLS_IsIntegerInRange(const test, f1, f2: integer): boolean;
begin
  if f1 < f2 then
    result := (test >= f1) and (test <= f2)
  else
    result := (test >= f2) and (test <= f1)
end;

function VDLS_IsLongWordInRange(const test, f1, f2: LongWord): boolean;
begin
  if f1 < f2 then
    result := (test >= f1) and (test <= f2)
  else
    result := (test >= f2) and (test <= f1)
end;

function VDLS_IsFloatInRange(const test, f1, f2: single): boolean;
begin
  if f1 < f2 then
    result := (test >= f1) and (test <= f2)
  else
    result := (test >= f2) and (test <= f1)
end;

function VDLS_IsDoubleInRange(const test, f1, f2: double): boolean;
begin
  if f1 < f2 then
    result := (test >= f1) and (test <= f2)
  else
    result := (test >= f2) and (test <= f1)
end;

function VDLS_IsExtendedInRange(const test, f1, f2: Extended): boolean;
begin
  if f1 < f2 then
    result := (test >= f1) and (test <= f2)
  else
    result := (test >= f2) and (test <= f1)
end;

function VDLS_Sqr(const x: Extended): Extended;
begin
  Result := x * x;
end;

function VDLS_Sqrt(const x: Extended): Extended;
begin
  Result := Sqrt(x);
end;

function VDLS_Cube(const x: Extended): Extended;
begin
  Result := x * x * x;
end;

function VDLS_ArcCos(const X: Extended): Extended;
begin
  Result := ArcCos(X);
end;

function VDLS_ArcSin(const X: Extended): Extended;
begin
  Result := ArcSin(X);
end;

function VDLS_ArcTan2(const Y, X: Extended): Extended;
begin
  Result := ArcTan2(Y, X);
end;

procedure VDLS_SinCosE(const Theta: Extended; var S, C: Extended);
begin
  SinCos(Theta, S, C);
end;

procedure VDLS_SinCosD(const Theta: Extended; var S, C: Double);
var
  S1, C1: Extended;
begin
  SinCos(Theta, S1, C1);
  S := S1;
  C := C1;
end;

procedure VDLS_SinCosF(const Theta: Extended; var S, C: Single);
var
  S1, C1: Extended;
begin
  SinCos(Theta, S1, C1);
  S := S1;
  C := C1;
end;

function VDLS_Cosh(const X: Extended): Extended;
begin
  Result := Cosh(X);
end;

function VDLS_Sinh(const X: Extended): Extended;
begin
  Result := Sinh(X);
end;

function VDLS_Tanh(const X: Extended): Extended;
begin
  Result := Tanh(X);
end;

function VDLS_ArcCosh(const X: Extended): Extended;
begin
  Result := ArcCosh(X);
end;

function VDLS_ArcSinh(const X: Extended): Extended;
begin
  Result := ArcSinh(X);
end;

function VDLS_ArcTanh(const X: Extended): Extended;
begin
  Result := ArcTanh(X);
end;

function VDLS_Log10(const X: Extended): Extended;
begin
  Result := Log10(X);
end;

function VDLS_Log2(const X: Extended): Extended;
begin
  Result := Log2(X);
end;

function VDLS_Ln(const X: Extended): Extended;
begin
  Result := Ln(X);
end;

function VDLS_LogN(const Base, X: Extended): Extended;
begin
  Result := LogN(Base, X);
end;

function VDLS_IntPower(const Base: Extended; const Exponent: Integer): Extended;
begin
  Result := IntPower(Base, Exponent);
end;

function VDLS_Power(const Base, Exponent: Extended): Extended;
begin
  Result := Power(Base, Exponent);
end;

function VDLS_Ceil(const X: Extended): Integer;
begin
  Result := Ceil(X);
end;

function VDLS_Floor(const X: Extended): Integer;
begin
  Result := Floor(X);
end;

end.

