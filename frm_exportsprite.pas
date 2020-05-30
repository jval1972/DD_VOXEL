//------------------------------------------------------------------------------
//
//  DD_VOXEL: DelphiDoom Voxel Editor
//  Copyright (C) 2013-2019 by Jim Valavanis
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
//  Export sprite form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit frm_exportsprite;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls, voxels;

type
  rotationinfo_t = record
    bitmap: TBitmap;
    recalc: boolean;
    angle: double;
  end;

type
  TExportSpriteForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    FileNameEdit: TEdit;
    Label1: TLabel;
    SavePK3Dialog: TSaveDialog;
    AnglesRadioGroup: TRadioGroup;
    SpriteFormatRadioGroup: TRadioGroup;
    Label3: TLabel;
    ContainerTypeLabel: TLabel;
    PatchRadioGroup: TRadioGroup;
    SelectFileButton: TSpeedButton;
    ProjectionModeRadioGroup: TRadioGroup;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    ViewHeightTrackBar: TTrackBar;
    DistanceTrackBar: TTrackBar;
    ViewHeightLabel: TLabel;
    DistanceLabel: TLabel;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    PrefixEdit: TEdit;
    SpritePrefixButton: TSpeedButton;
    HQCheckBox: TCheckBox;
    GroupBox3: TGroupBox;
    Panel3: TPanel;
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    Panel4: TPanel;
    ZoomInSpeedButton: TSpeedButton;
    ZoomOutSpeedButton: TSpeedButton;
    HourglassTimer: TTimer;
    HourglassLabel: TLabel;
    procedure SelectFileButtonClick(Sender: TObject);
    procedure FileNameEditChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpritePrefixButtonClick(Sender: TObject);
    procedure ViewHeightTrackBarChange(Sender: TObject);
    procedure DistanceTrackBarChange(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ProjectionModeRadioGroupClick(Sender: TObject);
    procedure Label4DblClick(Sender: TObject);
    procedure Label5DblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure HQCheckBoxClick(Sender: TObject);
    procedure AnglesRadioGroupClick(Sender: TObject);
    procedure ZoomInSpeedButtonClick(Sender: TObject);
    procedure ZoomOutSpeedButtonClick(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure PaintBox1DblClick(Sender: TObject);
    procedure HourglassTimerTimer(Sender: TObject);
  private
    { Private declarations }
    oldpreviewdist: integer;
    oldpreviewheight: integer;
    oldangleindex: integer;
    shown: boolean;
    frotation: integer;
    rotationinfo: array[0..31] of rotationinfo_t;
    tmpbuffer1: voxelbuffer_t;
    tmpbuffer2: voxelbuffer_t;
    zoom: integer;
    zoomrects: array[2..10] of TRect;
    hourglassindex: integer;
  protected
    fvoxelsize: Integer;
    voxelbuffer: voxelbuffer_p;
    filetype: string;
    procedure UpdateFileType;
    procedure MakePreview;
    function GetRotationAngle: double;
    function GetRotationIndex: integer;
    procedure RecalcNeeded;
    procedure DoHourglass;
    procedure StopHourglass;
  public
    { Public declarations }
  end;

function GetExportSpriteInfo(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  var filename: string; var prefix: string; var spritesavetype: string; var angles: integer;
  var hq: boolean; var spriteformat: string; var spritepalette: string; var perspective: boolean;
  var viewheight: integer; var dist: integer): boolean;

implementation

uses
  vxe_utils,
  vxe_defs,
  vxe_export,
  frm_spriteprefix;

{$R *.dfm}

function GetExportSpriteInfo(const voxelbuffer: voxelbuffer_p; const fvoxelsize: Integer;
  var filename: string; var prefix: string; var spritesavetype: string; var angles: integer;
  var hq: boolean; var spriteformat: string; var spritepalette: string; var perspective: boolean;
  var viewheight: integer; var dist: integer): boolean;
var
  f: TExportSpriteForm;
begin
  Result := False;
  f := TExportSpriteForm.Create(nil);
  try
    f.voxelbuffer := voxelbuffer;
    f.fvoxelsize := fvoxelsize;
    f.FileNameEdit.Text := filename;
    f.PrefixEdit.Text := prefix;
    if angles = 1 then
      f.AnglesRadioGroup.ItemIndex := 0
    else if angles = 8 then
      f.AnglesRadioGroup.ItemIndex := 1
    else if angles = 16 then
      f.AnglesRadioGroup.ItemIndex := 2
    else
      f.AnglesRadioGroup.ItemIndex := 3;
    if UpperCase(spriteformat) = 'PNG' then
      f.SpriteFormatRadioGroup.ItemIndex := 1
    else
      f.SpriteFormatRadioGroup.ItemIndex := 0;
    if UpperCase(spritepalette) = 'DOOM' then
      f.PatchRadioGroup.ItemIndex := 0
    else if UpperCase(spritepalette) = 'HERETIC' then
      f.PatchRadioGroup.ItemIndex := 1
    else if UpperCase(spritepalette) = 'HEXEN' then
      f.PatchRadioGroup.ItemIndex := 2
    else if UpperCase(spritepalette) = 'STRIFE' then
      f.PatchRadioGroup.ItemIndex := 3
    else if UpperCase(spritepalette) = 'RADIX' then
      f.PatchRadioGroup.ItemIndex := 4
    else
      f.PatchRadioGroup.ItemIndex := 0; // Default is Doom
    if perspective then
      f.ProjectionModeRadioGroup.ItemIndex := 0
    else
      f.ProjectionModeRadioGroup.ItemIndex := 1;
    f.HQCheckBox.Checked := hq;
    viewheight := GetIntInRange(viewheight, f.ViewHeightTrackBar.Min, f.ViewHeightTrackBar.Max);
    f.ViewHeightTrackBar.Position := viewheight;
    f.ViewHeightLabel.Caption := IntToStr(viewheight);
    dist := GetIntInRange(dist, f.DistanceTrackBar.Min, f.DistanceTrackBar.Max);
    f.DistanceTrackBar.Position := dist;
    f.DistanceLabel.Caption := IntToStr(dist);
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      Result := True;
      filename := f.FileNameEdit.Text;
      prefix := f.PrefixEdit.Text;
      hq := f.HQCheckBox.Checked;
      if f.AnglesRadioGroup.ItemIndex = 0 then
        angles := 1
      else if f.AnglesRadioGroup.ItemIndex = 1 then
        angles := 8
      else if f.AnglesRadioGroup.ItemIndex = 2 then
        angles := 16
      else
        angles := 32;
      if f.SpriteFormatRadioGroup.ItemIndex = 0 then
        spriteformat := 'LMP'
      else
        spriteformat := 'PNG';
      if f.PatchRadioGroup.ItemIndex = 0 then
        spritepalette := 'DOOM'
      else if f.PatchRadioGroup.ItemIndex = 1 then
        spritepalette := 'HERETIC'
      else if f.PatchRadioGroup.ItemIndex = 2 then
        spritepalette := 'HEXEN'
      else if f.PatchRadioGroup.ItemIndex = 3 then
        spritepalette := 'STRIFE'
      else
        spritepalette := 'RADIX';
      viewheight := f.ViewHeightTrackBar.Position;
      dist := f.DistanceTrackBar.Position;
      perspective := f.ProjectionModeRadioGroup.ItemIndex = 0;
      spritesavetype := f.filetype;
    end;
  finally
    f.Free;
  end;
end;

procedure TExportSpriteForm.HQCheckBoxClick(Sender: TObject);
begin
  RecalcNeeded;
end;

procedure TExportSpriteForm.SelectFileButtonClick(Sender: TObject);
begin
  SavePK3Dialog.FileName := FileNameEdit.Text;
  if SavePK3Dialog.Execute then
  begin
    FileNameEdit.Text := SavePK3Dialog.FileName;
    UpdateFileType;
  end;
end;

procedure TExportSpriteForm.FileNameEditChange(Sender: TObject);
var
  ok: boolean;
begin
  ok := (Trim(FileNameEdit.Text) <> '') and (DirectoryExists(ExtractFilePath(Trim(FileNameEdit.Text))));
  Button1.Enabled := ok;
  UpdateFileType;
end;

procedure TExportSpriteForm.UpdateFileType;
var
  ext: string;
begin
  ext := UpperCase(ExtractFileExt(Trim(FileNameEdit.Text)));
  if ext = '.PK3' then
    filetype := 'PK3'
  else if ext = '.PK4' then
    filetype := 'PK3'
  else if ext = '.ZIP' then
    filetype := 'PK3'
  else
    filetype := 'WAD';
  ContainerTypeLabel.Caption := filetype;
end;

procedure TExportSpriteForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  prefix: string;
  path: string;
begin
  if ModalResult = mrOK then
  begin
    prefix := Trim(PrefixEdit.Text);
    if Length(prefix) <> 5 then
    begin
      CanClose := False;
      ShowMessage('Prefix must have 5 characters');
      try PrefixEdit.SetFocus; except end;
      exit;
    end;

    if Trim(FileNameEdit.Text) = '' then
    begin
      CanClose := False;
      ShowMessage('Please specify the filename');
      try FileNameEdit.SetFocus; except end;
      exit;
    end;

    path := ExtractFilePath(Trim(FileNameEdit.Text));
    if not DirectoryExists(path) then
    begin
      CanClose := False;
      ShowMessage('Directory "' + path + '" does not exist');
      try FileNameEdit.SetFocus; except end;
      exit;
    end;

  end;
end;

procedure TExportSpriteForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to 31 do
  begin
    rotationinfo[i].bitmap := TBitmap.Create;
    rotationinfo[i].recalc := True;
    rotationinfo[i].angle := 0.0;
  end;
  UpdateFileType;
  oldpreviewdist := -1;
  oldpreviewheight := -1;
  oldangleindex := -1;
  frotation := 0;
  hourglassindex := 0;
  shown := False;
  zoom := GetIntInRange(spriteexportpreviewzoom, 1, 10);
  for i := 2 to 10 do
  begin
    zoomrects[i].Left := (i - 1) * 10;
    zoomrects[i].Top := (i - 1) * 20;
    zoomrects[i].Right := MAXVOXELSIZE - zoomrects[i].Left;
    zoomrects[i].Bottom := MAXVOXELSIZE - 1;
  end;
end;

procedure TExportSpriteForm.FormShow(Sender: TObject);
begin
  shown := True;
  Timer1.Enabled := True;
  UpdateFileType;
end;

procedure TExportSpriteForm.SpritePrefixButtonClick(Sender: TObject);
var
  s: string;
begin
  s := PrefixEdit.Text;
  if GetSpritePrefix(s) then
    PrefixEdit.Text := s;
end;

procedure TExportSpriteForm.ViewHeightTrackBarChange(Sender: TObject);
begin
  ViewHeightLabel.Caption := IntToStr(ViewHeightTrackBar.Position);
  RecalcNeeded;
  MakePreview;
end;

procedure TExportSpriteForm.DistanceTrackBarChange(Sender: TObject);
begin
  DistanceLabel.Caption := IntToStr(DistanceTrackBar.Position);
  RecalcNeeded;
  MakePreview;
end;

procedure TExportSpriteForm.MakePreview;
var
  bm1: TBitmap;
  dist, height: integer;
  offsl, offst: integer;
  rot: double;
  idx: integer;
begin
  if not shown then
    Exit;

  bm1 := nil;
  offsl := 0;
  offst := 0;
  rot := GetRotationAngle;
  idx := GetRotationIndex;
  if ProjectionModeRadioGroup.ItemIndex = 0 then
  begin
    dist := DistanceTrackBar.Position;
    height := ViewHeightTrackBar.Position;
    if (dist <> oldpreviewdist) or (height <> oldpreviewheight) or
       (AnglesRadioGroup.ItemIndex <> oldangleindex) or (rotationinfo[idx].recalc) then
    begin
      DoHourglass;
      if DoubleEqual(rot, 0.0) then
        bm1 := VXE_ExportGetFrontPerspective(voxelbuffer, fvoxelsize, @tmpbuffer1, dist, height)
      else
      begin
        if HQCheckBox.Checked then
          VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, rot, @tmpbuffer2)
        else
          VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, rot, @tmpbuffer2);
        bm1 := VXE_ExportGetFrontPerspective(@tmpbuffer2, fvoxelsize, @tmpbuffer1, dist, height);
      end;

      VXE_GetPerspectiveOffsets(dist, height, offsl, offst);
      oldpreviewdist := dist;
      oldpreviewheight := height;
      oldangleindex := AnglesRadioGroup.ItemIndex;
      rotationinfo[idx].recalc := False;
    end;
  end
  else
  begin
    dist := 0;
    height := 0;
    if (dist <> oldpreviewdist) or (height <> oldpreviewheight) or
       (AnglesRadioGroup.ItemIndex <> oldangleindex) or (rotationinfo[idx].recalc) then
    begin
      DoHourglass;
      if DoubleEqual(rot, 0.0) then
        bm1 := VXE_ExportGetFront(voxelbuffer, fvoxelsize)
      else if DoubleEqual(rot, pi / 2) then
        bm1 := VXE_ExportGetRight(voxelbuffer, fvoxelsize)
      else if DoubleEqual(rot, pi) then
        bm1 := VXE_ExportGetBack(voxelbuffer, fvoxelsize)
      else if DoubleEqual(rot, pi + pi / 2) then
        bm1 := VXE_ExportGetLeft(voxelbuffer, fvoxelsize)
      else
      begin
        if HQCheckBox.Checked then
          VXE_RotateVoxelBufferHQ(voxelbuffer, fvoxelsize, rot, @tmpbuffer2)
        else
          VXE_RotateVoxelBuffer(voxelbuffer, fvoxelsize, rot, @tmpbuffer2);
        bm1 := VXE_ExportGetFront(@tmpbuffer2, fvoxelsize);
      end;
      offsl := fvoxelsize div 2;
      offst := fvoxelsize - 1;
      oldpreviewdist := dist;
      oldpreviewheight := height;
      oldangleindex := AnglesRadioGroup.ItemIndex;
      rotationinfo[idx].recalc := False;
    end;
  end;

  if bm1 <> nil then
  begin
    rotationinfo[idx].bitmap.Width := MAXVOXELSIZE;
    rotationinfo[idx].bitmap.height := MAXVOXELSIZE;
    if (bm1.Width = MAXVOXELSIZE) and (bm1.Height = MAXVOXELSIZE) then
      rotationinfo[idx].bitmap.Assign(bm1)
    else
    begin
      offsl := GetIntInRange((offsl * MAXVOXELSIZE) div fvoxelsize, 0, MAXVOXELSIZE - 1);
      offst := GetIntInRange((offst * MAXVOXELSIZE) div fvoxelsize, 0, MAXVOXELSIZE - 1);
      rotationinfo[idx].bitmap.Canvas.Brush.Color := RGB(0, 0, 0);
      rotationinfo[idx].bitmap.Canvas.Brush.Style := bsSolid;
      rotationinfo[idx].bitmap.Canvas.Pen.Color := RGB(0, 0, 0);
      rotationinfo[idx].bitmap.Canvas.Pen.Style := psSolid;
      rotationinfo[idx].bitmap.Canvas.FillRect(Rect(0, 0, MAXVOXELSIZE, MAXVOXELSIZE));
      rotationinfo[idx].bitmap.Canvas.Draw((MAXVOXELSIZE - bm1.Width) div 2, MAXVOXELSIZE - bm1.Height, bm1);
    end;
    // Draw Offsets;
    rotationinfo[idx].bitmap.Canvas.Pen.Style := psSolid;
    rotationinfo[idx].bitmap.Canvas.Pen.Color := RGB(128, 128, 128);
    rotationinfo[idx].bitmap.Canvas.MoveTo(offsl, 0);
    rotationinfo[idx].bitmap.Canvas.LineTo(offsl, MAXVOXELSIZE - 1);
    rotationinfo[idx].bitmap.Canvas.MoveTo(0, offst);
    rotationinfo[idx].bitmap.Canvas.LineTo(MAXVOXELSIZE - 1, offst);
    bm1.Free;
  end
  else
    StopHourglass;
  if zoom = 1 then
    PaintBox1.Canvas.StretchDraw(PaintBox1.ClientRect, rotationinfo[idx].bitmap)
  else
    PaintBox1.Canvas.CopyRect(PaintBox1.ClientRect, rotationinfo[idx].bitmap.Canvas, zoomrects[zoom]);
end;

procedure TExportSpriteForm.PaintBox1Paint(Sender: TObject);
begin
  MakePreview;
end;

procedure TExportSpriteForm.ProjectionModeRadioGroupClick(Sender: TObject);
begin
  RecalcNeeded;
  MakePreview;
end;

procedure TExportSpriteForm.Label4DblClick(Sender: TObject);
begin
  ViewHeightTrackBar.Position := 41;
end;

procedure TExportSpriteForm.Label5DblClick(Sender: TObject);
begin
  DistanceTrackBar.Position := 1024;
end;

procedure TExportSpriteForm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to 31 do
    rotationinfo[i].bitmap.Free;
  spriteexportpreviewzoom := zoom;
end;

function TExportSpriteForm.GetRotationAngle: double;
begin
  case AnglesRadioGroup.ItemIndex of
    0: Result := 0.0;
    1: Result := (GetRotationIndex) * 2 * pi / 32;
    2: Result := (GetRotationIndex) * 2 * pi / 32;
    3: Result := (frotation) * 2 * pi / 32;
  else
    Result := 0.0;
  end;
end;

function TExportSpriteForm.GetRotationIndex: integer;
begin
  case AnglesRadioGroup.ItemIndex of
    0: Result := 0;
    1: Result := (frotation div 4) * 4;
    2: Result := (frotation div 2) * 2;
    3: Result := frotation;
  else
    Result := 0;
  end;
end;

procedure TExportSpriteForm.Timer1Timer(Sender: TObject);
begin
  if frotation <= 0 then
    frotation := 31
  else
    frotation := frotation - 1;
  MakePreview;
end;

procedure TExportSpriteForm.RecalcNeeded;
var
  i: integer;
begin
  for i := 0 to 31 do
    rotationinfo[i].recalc := True;
end;

procedure TExportSpriteForm.AnglesRadioGroupClick(Sender: TObject);
begin
  RecalcNeeded;
end;

procedure TExportSpriteForm.ZoomInSpeedButtonClick(Sender: TObject);
begin
  if zoom < 10 then
  begin
    inc(zoom);
    MakePreview;
  end;
end;

procedure TExportSpriteForm.ZoomOutSpeedButtonClick(Sender: TObject);
begin
  if zoom > 1 then
  begin
    dec(zoom);
    MakePreview;
  end;
end;

procedure TExportSpriteForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
  r: TRect;
begin
  pt := PaintBox1.ScreenToClient(MousePos);
  r := PaintBox1.ClientRect;
  if PtInRect(r, pt) then
    ZoomOutSpeedButtonClick(Sender);
end;

procedure TExportSpriteForm.FormMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
  r: TRect;
begin
  pt := PaintBox1.ScreenToClient(MousePos);
  r := PaintBox1.ClientRect;
  if PtInRect(r, pt) then
    ZoomInSpeedButtonClick(Sender);
end;

procedure TExportSpriteForm.PaintBox1DblClick(Sender: TObject);
begin
  zoom := 1;
  MakePreview;
end;

procedure TExportSpriteForm.HourglassTimerTimer(Sender: TObject);
begin
  hourglassindex := hourglassindex + 1;
  if hourglassindex > 3 then
    hourglassindex := 0;
  DoHourglass;
end;

procedure TExportSpriteForm.DoHourglass;
begin
  HourglassTimer.Enabled := true;
  case hourglassindex of
    0: HourglassLabel.Caption := '.';
    2: HourglassLabel.Caption := '...';
  else
    HourglassLabel.Caption := '..';
  end;
  HourglassLabel.Refresh;
end;

procedure TExportSpriteForm.StopHourglass;
begin
  HourglassTimer.Enabled := False;
  HourglassLabel.Caption := ' ';
  HourglassLabel.Refresh;
end;

end.
