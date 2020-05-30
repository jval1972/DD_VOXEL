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
//  Go to line number Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit frm_GotoLine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SynEditTypes;

type
  TfrmGotoLine = class(TForm)
    edtCharNumber: TEdit;
    edtLineNumber: TEdit;
    Button1: TButton;
    btnGoto: TButton;
    lblLineNumber: TLabel;
    lblCharNumber: TLabel;
    procedure FormShow(Sender: TObject);
  private
    function GetCaret: TBufferCoord;
    procedure SetCaret(const Value: TBufferCoord);
    procedure SetChar(const Value: Integer);
    procedure SetLine(const Value: Integer);
    function GetChar: Integer;
    function GetLine: Integer;
    { Private declarations }
  public
    { Public declarations }
    property Char: Integer read GetChar write SetChar;
    property Line: Integer read GetLine write setLine;
    property CaretXY: TBufferCoord read GetCaret write SetCaret;
  end;

implementation

{$R *.dfm}

{ TfrmGotoLine }

function TfrmGotoLine.GetCaret: TBufferCoord;
begin
  Result.Char := StrToInt(edtCharNumber.Text);
  Result.Line := StrToInt(edtLineNumber.Text);
end;

function TfrmGotoLine.GetChar: Integer;
begin
  Result := StrToInt(edtCharNumber.Text)
end;

function TfrmGotoLine.GetLine: Integer;
begin
  Result := StrToInt(edtLineNumber.Text)
end;

procedure TfrmGotoLine.SetCaret(const Value: TBufferCoord);
begin
  edtCharNumber.Text := IntToStr(Value.Char);
  edtLineNumber.Text := IntToStr(Value.Line);
end;

procedure TfrmGotoLine.SetChar(const Value: Integer);
begin
  edtCharNumber.Text := IntToStr(Value);
end;

procedure TfrmGotoLine.SetLine(const Value: Integer);
begin
  edtLineNumber.Text := IntToStr(Value);
end;

procedure TfrmGotoLine.FormShow(Sender: TObject);
begin
  edtLineNumber.SetFocus;
end;

end.
