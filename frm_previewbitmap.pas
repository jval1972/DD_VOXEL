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
//  Preview Bitmap Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit frm_previewbitmap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtDlgs, ExtCtrls, Buttons, clipbrd;

type
  TPreviewBitmapForm = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    Panel2: TPanel;
    SavePictureDialog1: TSavePictureDialog;
    Button1: TButton;
    Button2: TButton;
    Panel3: TPanel;
    CopyButton1: TSpeedButton;
    Bevel1: TBevel;
    PasteButton1: TSpeedButton;
    Timer1: TTimer;
    procedure CopyButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PasteButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function PreviewBitmapForSaving(const acaption: string; const bm: TBitmap): Boolean;

function PreviewBitmapFor3dImport(const acaption: string; const bm: TBitmap): Boolean;

implementation

{$R *.dfm}

function PreviewBitmapForSaving(const acaption: string; const bm: TBitmap): Boolean;
var
  f: TPreviewBitmapForm;
begin
  result := false;
  f := TPreviewBitmapForm.Create(nil);
  try
    f.Image1.Width := bm.Width;
    f.Image1.Height := bm.Height;
    f.Image1.Picture.Bitmap.Assign(bm);
    f.Caption := acaption;
    f.Button1.Caption := 'Save';
    f.PasteButton1.Visible := False;
    f.ShowModal;
    if f.ModalResult = mrOK then
      Result := true;
  finally
    f.Free;
  end;
end;

function PreviewBitmapFor3dImport(const acaption: string; const bm: TBitmap): Boolean;
var
  f: TPreviewBitmapForm;
begin
  result := false;
  f := TPreviewBitmapForm.Create(nil);
  try
    f.Image1.Width := bm.Width;
    f.Image1.Height := bm.Height;
    f.Image1.Picture.Bitmap.Assign(bm);
    f.Caption := acaption;
    f.Button1.Caption := 'OK';
    f.PasteButton1.Visible := True;
    f.ShowModal;
    if f.ModalResult = mrOK then
      Result := true;
  finally
    f.Free;
  end;
end;

procedure TPreviewBitmapForm.CopyButton1Click(Sender: TObject);
begin
  Clipboard.Assign(Image1.Picture.Bitmap);
end;

procedure TPreviewBitmapForm.Timer1Timer(Sender: TObject);
begin
  if PasteButton1.Visible then
    PasteButton1.Enabled := Clipboard.HasFormat(CF_BITMAP);
end;

procedure TPreviewBitmapForm.FormShow(Sender: TObject);
begin
  if PasteButton1.Visible then
    PasteButton1.Enabled := Clipboard.HasFormat(CF_BITMAP);
end;

procedure TPreviewBitmapForm.PasteButton1Click(Sender: TObject);
var
  tempBitmap: TBitmap;
  w, h: integer;
begin
  // if there is an image on clipboard
  if Clipboard.HasFormat(CF_BITMAP) then
  begin
    tempBitmap := TBitmap.Create;

    try
      tempBitmap.LoadFromClipboardFormat(CF_BITMAP, ClipBoard.GetAsHandle(cf_Bitmap), 0);

      w := Image1.Picture.Bitmap.Width;
      h := Image1.Picture.Bitmap.Height;
      Image1.Picture.Bitmap.Canvas.StretchDraw(Rect(0, 0, w, h), tempBitmap);
    finally
      tempBitmap.Free;
    end;
  end;
end;

end.
