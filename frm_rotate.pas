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
//  Get Rotation Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit frm_rotate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TRotateVoxelForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    TrackBar1: TTrackBar;
    Edit1: TEdit;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Private declarations }
    ineditchange: boolean;
  protected
    procedure UpdateControls;
  public
    { Public declarations }
  end;

function GetRotationInput(var theta: integer): boolean;

implementation

{$R *.dfm}

function GetRotationInput(var theta: integer): boolean;
var
  f: TRotateVoxelForm;
begin
  result := false;
  f := TRotateVoxelForm.Create(nil);
  try
    f.TrackBar1.Position := theta;
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      result := True;
      theta := f.TrackBar1.Position;
    end;
  finally
    f.Free;
  end;
end;

procedure TRotateVoxelForm.FormCreate(Sender: TObject);
begin
  ineditchange := False;
  Edit1.Text := IntToStr(TrackBar1.Position);
end;

procedure TRotateVoxelForm.UpdateControls;
var
  theta: integer;
begin
  theta := StrToIntDef(Edit1.Text, -1);
  if theta = -1 then
  begin

  end;
end;

procedure TRotateVoxelForm.Edit1Change(Sender: TObject);
var
  theta: integer;
begin
  if ineditchange then
    Exit;
  ineditchange := True;
  theta := StrToIntDef(Edit1.Text, -1);
  if theta = -1 then
  begin
    Edit1.Text := IntToStr(TrackBar1.Position);
  end
  else
  begin
    if theta <> theta mod 360 then
    begin
      theta := theta mod 360;
      Edit1.Text := IntToStr(theta);
    end;
    TrackBar1.Position := theta;
  end;
  ineditchange := False;
end;

procedure TRotateVoxelForm.TrackBar1Change(Sender: TObject);
begin
  if not ineditchange then
    Edit1.Text := IntToStr(TrackBar1.Position);
end;

end.
