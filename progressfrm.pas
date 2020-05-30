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
//  Progress Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit progressfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TProgressForm = class(TForm)
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fsteps: integer;
    fstep: integer;
  public
    { Public declarations }
    property steps: integer read fsteps write fsteps;
    property step: integer read fstep write fstep;
  end;

var
  ProgressForm: TProgressForm;

procedure ProgressStart(const msg: string; const steps: integer = 100);

procedure ProgressStop;

procedure ProgressPos(const x: double);

procedure ProgressStep;

implementation

{$R *.dfm}

procedure ProgressStart(const msg: string; const steps: integer = 100);
begin
  ProgressForm.ProgressBar1.Position := 0;
  ProgressForm.Label1.Caption := msg;
  ProgressForm.steps := steps;
  ProgressForm.step := 0;
  ProgressForm.Show;
  ProgressForm.Update;
end;

procedure ProgressStop;
begin
  ProgressForm.Hide;
end;

procedure ProgressPos(const x: double);
begin
  if ProgressForm.Visible then
  begin
    if x <= 0.0 then
      ProgressForm.ProgressBar1.Position := 0
    else if x >= 1.0 then
      ProgressForm.ProgressBar1.Position := ProgressForm.ProgressBar1.Max
    else
      ProgressForm.ProgressBar1.Position := Trunc(ProgressForm.ProgressBar1.Max * x);
    ProgressForm.ProgressBar1.Update;
  end;
end;

procedure ProgressStep;
begin
  if ProgressForm.steps > 0 then
    ProgressPos(ProgressForm.step / ProgressForm.steps);
  if ProgressForm.step < ProgressForm.steps then
    ProgressForm.step := ProgressForm.step + 1;
end;

procedure TProgressForm.FormCreate(Sender: TObject);
begin
  steps := 100;
  step := 0;
end;

end.
