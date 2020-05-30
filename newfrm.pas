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
//  New Voxel Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit newfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TNewForm = class(TForm)
    RadioGroup1: TRadioGroup;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private declarations }
    lastSize: integer;
  public
    { Public declarations }
  end;

function GetNewVoxelSize(var sz: Integer): Boolean;

implementation

{$R *.dfm}

uses
  voxels;

function GetNewVoxelSize(var sz: Integer): Boolean;
var
  frm: TNewForm;
begin
  Result := False;
  frm := TNewForm.Create(nil);
  try
    frm.ShowModal;
    if frm.ModalResult = mrOK then
    begin
      sz := StrToIntDef(frm.Edit1.Text, 32);
      Result := True;
    end;
  finally
    frm.Free;
  end;
end;

procedure TNewForm.Edit1Change(Sender: TObject);
var
  x: integer;
  s: string;
begin
  s := Edit1.Text;
  x := StrToIntDef(s, -1);

  if (IntToStr(x) <> s) or (x < 0) or (x > MAXVOXELSIZE) then
  begin
    Edit1.Text := IntToStr(lastSize);
    Beep;
  end
  else
    lastSize := x;
end;

procedure TNewForm.FormCreate(Sender: TObject);
begin
  lastSize := 32;
  RadioGroup1.ItemIndex := 3;
  Edit1.Text := '32';
end;

procedure TNewForm.RadioGroup1Click(Sender: TObject);
begin
  if RadioGroup1.ItemIndex < 7 then
  begin
    lastSize := 1 shl (RadioGroup1.ItemIndex + 2);
    Edit1.Text := IntToStr(lastSize);
  end
  else
  begin
    if Edit1.CanFocus then
      Edit1.SetFocus;
    Edit1.SelectAll;
  end;
end;

end.
