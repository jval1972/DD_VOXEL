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
//  Heighmap Crop/Shrink Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit frm_srinkheightmap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ExtDlgs, Buttons, StdCtrls, PngImage, ComCtrls;

type
  shf_mode_t = (shf_shrink, shf_crop);

  TSrinkHeightmapForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Timer1: TTimer;
    GroupBox1: TGroupBox;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Panel3: TPanel;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    amin, amax: integer;
    amode: shf_mode_t;
    sample: TBitmap;
    destroying: boolean;
  protected
    procedure SetMinMax(mn, mx: Integer);
    procedure SetSample(const asample: TBitmap);
    procedure SetMode(const md: shf_mode_t);
    procedure UpdateControls;
  public
    { Public declarations }
  end;

function SrinkHeightmapGetInfo(var mn, mx: integer; const asample: TBitmap = nil): boolean;

function CropHeightmapGetInfo(var mn, mx: integer; const asample: TBitmap = nil): boolean;

function SrinkHeightmapFormExecute(var mn, mx: integer; const fmode: shf_mode_t; const asample: TBitmap = nil): boolean;

implementation

{$R *.dfm}

function SrinkHeightmapGetInfo(var mn, mx: integer; const asample: TBitmap = nil): boolean;
begin
  Result := SrinkHeightmapFormExecute(mn, mx,  shf_shrink, asample);
end;

function CropHeightmapGetInfo(var mn, mx: integer; const asample: TBitmap = nil): boolean;
begin
  Result := SrinkHeightmapFormExecute(mn, mx,  shf_crop, asample);
end;

function SrinkHeightmapFormExecute(var mn, mx: integer; const fmode: shf_mode_t; const asample: TBitmap = nil): boolean;
var
  f: TSrinkHeightmapForm;
begin
  Result := False;
  f := TSrinkHeightmapForm.Create(nil);
  try
    f.SetMinMax(mn, mx);
    f.SetMode(fmode);
    if asample <> nil then
      f.SetSample(asample);
    if f.ShowModal = mrOK then
    begin
      mn := f.amin;
      mx := f.amax;
      Result := True;
    end;
  finally
    f.Free;
  end;
end;

procedure TSrinkHeightmapForm.FormCreate(Sender: TObject);
begin
  destroying := false;
  amode := shf_shrink;
  sample := TBitmap.Create;
  sample.Width := 256;
  sample.Height := 256;
  sample.PixelFormat := pf32bit;
  sample.Canvas.Brush.Style := bsSolid;
  sample.Canvas.Brush.Color := clBlack;
  sample.Canvas.Pen.Style := psSolid;
  sample.Canvas.Pen.Color := clBlack;
  sample.Canvas.FillRect(Rect(0, 0, 255, 255));
  amin := 0;
  amax := 255;
  Image1.Picture.Bitmap.PixelFormat := pf32bit;
  UpdateControls;
end;

procedure TSrinkHeightmapForm.TrackBarChange(Sender: TObject);
var
  mn, mx: integer;
begin
  mn := TrackBar1.Position;
  mx := TrackBar2.Position;
  SetMinMax(mn, mx);
end;

procedure TSrinkHeightmapForm.SetMinMax(mn, mx: Integer);
var
  tmp: integer;
begin
  if mn < 0 then
    mn := 0
  else if mn > 255 then
    mn := 255;

  if mx < 0 then
    mx := 0
  else if mx > 255 then
    mx := 255;

  if mn > mx then
  begin
    tmp := mn;
    mn := mx;
    mx := tmp;
  end;

  if (mn = amin) and (mx = amax) then
    exit;

  amin := mn;
  amax := mx;

  UpdateControls;
end;

procedure TSrinkHeightmapForm.SetSample(const asample: TBitmap);
begin
  if asample = nil then
    Exit;
    
  sample.Canvas.StretchDraw(Rect(0, 0, 255, 255), asample);
  UpdateControls;
end;

procedure TSrinkHeightmapForm.UpdateControls;
var
  b: TBitmap;
begin
  Label1.Caption := Format('Top: %.*d/255', [3, amin]);
  Label2.Caption := Format('Bottom: %.*d/255', [3, amax]);

  b := TBitmap.Create;
  try
    b.Width := 256;
    b.Height := 256;
    b.PixelFormat := pf32bit;
    b.Canvas.Brush.Style := bsSolid;
    b.Canvas.Brush.Color := clBlack;
    b.Canvas.Pen.Style := psSolid;
    b.Canvas.Pen.Color := clBlack;
    b.Canvas.FillRect(Rect(0, 0, 255, 255));
    if not destroying then
    begin
      if amode = shf_shrink then
        b.Canvas.StretchDraw(Rect(0, amin, 255, amax), sample)
      else
        b.Canvas.StretchDraw(Rect(0, 0, 255, 255), sample)
    end;
    b.Canvas.Brush.Style := bsDiagCross;
    b.Canvas.Brush.Color := clBlue;
    b.Canvas.FillRect(Rect(0, 0, 255, amin));
    b.Canvas.FillRect(Rect(0, amax, 255, 255));
    b.Canvas.Pen.Color := clYellow;
    b.Canvas.MoveTo(0, amin);
    b.Canvas.LineTo(255, amin);
    b.Canvas.MoveTo(0, amax);
    b.Canvas.LineTo(255, amax);
    Image1.Picture.Bitmap.Canvas.Draw(0, 0, b);
    Image1.Invalidate;
  finally
    b.Free;
  end;
end;

procedure TSrinkHeightmapForm.FormDestroy(Sender: TObject);
begin
  destroying := true;
  sample.Free;
end;

procedure TSrinkHeightmapForm.FormShow(Sender: TObject);
begin
  UpdateControls;
end;

procedure TSrinkHeightmapForm.SetMode(const md: shf_mode_t);
begin
  amode := md;
  if amode = shf_shrink then
    Caption := 'Shrink Heighmap'
  else if amode = shf_crop then
    Caption := 'Crop Heighmap';
    
  UpdateControls;
end;

end.
