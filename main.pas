//------------------------------------------------------------------------------
//
//  DD_VOXEL: DelphiDoom Voxel Editor
//  Copyright (C) 2013-2020 by Jim Valavanis
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
//  Main Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00800000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST ON}

unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, xTGA, jpeg, zBitmap, ComCtrls, ExtCtrls, Buttons,
  voxels, Menus, StdCtrls, AppEvnts, ExtDlgs, vxe_undo, dglOpenGL, clipbrd,
  vxe_filemenuhistory, vxe_palette, ToolWin;

type
  paintrespondertype_t = (prt_buttondown, prt_buttonmove, prt_buttonup);

type
  TForm1 = class(TForm)
    SaveDialog1: TSaveDialog;
    ColorDialog1: TColorDialog;
    Panel2: TPanel;
    PalettePanel: TPanel;
    FormPanel: TPanel;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    PaintBox1: TPaintBox;
    Panel3: TPanel;
    Palette: TImage;
    DrawColor1Panel: TPanel;
    DrawColor2Panel: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    ComboBox1: TComboBox;
    Label1: TLabel;
    OpenGLPanel: TPanel;
    ApplicationEvents1: TApplicationEvents;
    OpenDialog1: TOpenDialog;
    Voxel1: TMenuItem;
    Importimage1: TMenuItem;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    N3: TMenuItem;
    Options1: TMenuItem;
    ExportCurrentLevelAsBitmap1: TMenuItem;
    SavePictureDialog1: TSavePictureDialog;
    Import1: TMenuItem;
    N4: TMenuItem;
    KVXVoxel1: TMenuItem;
    OpenDialog2: TOpenDialog;
    Export1: TMenuItem;
    Optimizedmesh1: TMenuItem;
    SaveDialog2: TSaveDialog;
    BatchConvertKVX2DDMESH1: TMenuItem;
    N5: TMenuItem;
    OpenDialog3: TOpenDialog;
    BatchConvert1: TMenuItem;
    BatchConvertDDVOX2DDMESH1: TMenuItem;
    DDMESH1: TMenuItem;
    OpenDialog4: TOpenDialog;
    OpenDialog5: TOpenDialog;
    Heightmap1: TMenuItem;
    ApplyTerrainTexture11: TMenuItem;
    N8: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Terrain1: TMenuItem;
    OpenPictureDialog2: TOpenPictureDialog;
    N6: TMenuItem;
    Removenonvisiblevoxels1: TMenuItem;
    ExportFrontViewAsBitmap1: TMenuItem;
    SavePictureDialog2: TSavePictureDialog;
    ToolPanel: TPanel;
    FreeDrawSpeedButton: TSpeedButton;
    FloodFillSpeedButton: TSpeedButton;
    ColorPickerSpeedButton: TSpeedButton;
    EraseSpeedButton: TSpeedButton;
    Cut1: TMenuItem;
    N7: TMenuItem;
    Clear1: TMenuItem;
    ExportAsBitmap1: TMenuItem;
    ExportBackViewAsBitmap1: TMenuItem;
    ExportLeftViewAsBitmap1: TMenuItem;
    ExportRightViewAsBitmap1: TMenuItem;
    ExportTopViewAsBitmap1: TMenuItem;
    ExportDownViewAsBiitmap1: TMenuItem;
    Copy3D1: TMenuItem;
    CopyFrontView1: TMenuItem;
    CopyBackView1: TMenuItem;
    CopyLeftView1: TMenuItem;
    CopyRightView1: TMenuItem;
    CopyTopView1: TMenuItem;
    CopyDownView1: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    Paste3D1: TMenuItem;
    PasteDownView1: TMenuItem;
    PasteTopView1: TMenuItem;
    PasteRightView1: TMenuItem;
    PasteLeftView1: TMenuItem;
    PasteBackView1: TMenuItem;
    PasteFrontView1: TMenuItem;
    SrinkHeightmap1: TMenuItem;
    N11: TMenuItem;
    ShrinkHeightmap1: TMenuItem;
    ElevateSpeedButton: TSpeedButton;
    Splitter1: TSplitter;
    N12: TMenuItem;
    Panel10: TPanel;
    N13: TMenuItem;
    FileMenuHistoryItem0: TMenuItem;
    FileMenuHistoryItem1: TMenuItem;
    FileMenuHistoryItem2: TMenuItem;
    FileMenuHistoryItem3: TMenuItem;
    FileMenuHistoryItem4: TMenuItem;
    FileMenuHistoryItem5: TMenuItem;
    FileMenuHistoryItem6: TMenuItem;
    FileMenuHistoryItem7: TMenuItem;
    FileMenuHistoryItem8: TMenuItem;
    FileMenuHistoryItem9: TMenuItem;
    Copy3dButton: TSpeedButton;
    Save3dButton: TSpeedButton;
    SavePictureDialog3: TSavePictureDialog;
    GridButton1: TSpeedButton;
    N14: TMenuItem;
    Rotate1: TMenuItem;
    RotateHighQuality1: TMenuItem;
    N15: TMenuItem;
    Sprite1: TMenuItem;
    Script1: TMenuItem;
    Load1: TMenuItem;
    Compile1: TMenuItem;
    Run1: TMenuItem;
    ToolBar1: TToolBar;
    NewButton1: TSpeedButton;
    OpenButton1: TSpeedButton;
    SaveButton1: TSpeedButton;
    SaveAsButton1: TSpeedButton;
    ShowScriptButton1: TSpeedButton;
    AboutButton1: TSpeedButton;
    ExitButton1: TSpeedButton;
    ZoomInButton1: TSpeedButton;
    ZoomOutButton1: TSpeedButton;
    UndoButton1: TSpeedButton;
    RedoButton1: TSpeedButton;
    RotateLeftButton1: TSpeedButton;
    RotateRightButton1: TSpeedButton;
    FlipHorzButton1: TSpeedButton;
    FlipVertButton1: TSpeedButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    N16: TMenuItem;
    ScriptEditor1: TMenuItem;
    OpenDialog6: TOpenDialog;
    Importslab6VOX1: TMenuItem;
    Exportslab6VOX1: TMenuItem;
    SaveDialog3: TSaveDialog;
    Colors1: TMenuItem;
    Countcolorsused1: TMenuItem;
    Greyscale1: TMenuItem;
    N17: TMenuItem;
    Convertto256colorspalette1: TMenuItem;
    OpenPaletteDialog: TOpenDialog;
    PaletteSpeedButton1: TSpeedButton;
    PalettePopupMenu1: TPopupMenu;
    PaletteDoom1: TMenuItem;
    PaletteHeretic1: TMenuItem;
    PaletteHexen1: TMenuItem;
    PaletteStrife1: TMenuItem;
    N18: TMenuItem;
    PaletteGreyScale1: TMenuItem;
    DDVOXtoslab6VOX1: TMenuItem;
    ColorPalette1: TMenuItem;
    PaletteDoom2: TMenuItem;
    PaletteHeretic2: TMenuItem;
    PaletteHexen2: TMenuItem;
    PaletteStrife2: TMenuItem;
    N19: TMenuItem;
    PaletteGreyScale2: TMenuItem;
    N20: TMenuItem;
    View1: TMenuItem;
    Front1: TMenuItem;
    Back1: TMenuItem;
    Left1: TMenuItem;
    Right1: TMenuItem;
    Top1: TMenuItem;
    Down1: TMenuItem;
    N21: TMenuItem;
    Xaxis1: TMenuItem;
    Yaxis1: TMenuItem;
    Zaxis1: TMenuItem;
    N22: TMenuItem;
    Increaselevel1: TMenuItem;
    Decreaselevel1: TMenuItem;
    PaletteRadix1: TMenuItem;
    PaletteRadix2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure NewButton1Click(Sender: TObject);
    procedure SaveButton1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AboutButton1Click(Sender: TObject);
    procedure SaveAsButton1Click(Sender: TObject);
    procedure ExitButton1Click(Sender: TObject);
    procedure DrawColor1PanelDblClick(Sender: TObject);
    procedure DrawColor2PanelDblClick(Sender: TObject);
    procedure OpenButton1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ZoomInButton1Click(Sender: TObject);
    procedure ZoomOutButton1Click(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure PaletteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure OpenGLPanelResize(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure OpenGLPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenGLPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenGLPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure OpenGLPanelDblClick(Sender: TObject);
    procedure Importimage1Click(Sender: TObject);
    procedure RotateLeftButton1Click(Sender: TObject);
    procedure RotateRightButton1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Redo1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure ExportCurrentLevelAsBitmap1Click(Sender: TObject);
    procedure KVXVoxel1Click(Sender: TObject);
    procedure Importslab6VOX1Click(Sender: TObject);
    procedure Optimizedmesh1Click(Sender: TObject);
    procedure BatchConvertKVX2DDMESH1Click(Sender: TObject);
    procedure BatchConvertDDVOX2DDMESH1Click(Sender: TObject);
    procedure DDMESH1Click(Sender: TObject);
    procedure Heightmap1Click(Sender: TObject);
    procedure ApplyTerrainTexture11Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure FlipHorzButton1Click(Sender: TObject);
    procedure FlipVertButton1Click(Sender: TObject);
    procedure Removenonvisiblevoxels1Click(Sender: TObject);
    procedure ExportFrontViewAsBitmap1Click(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure ExportBackViewAsBitmap1Click(Sender: TObject);
    procedure ExportLeftViewAsBitmap1Click(Sender: TObject);
    procedure ExportRightViewAsBitmap1Click(Sender: TObject);
    procedure ExportTopViewAsBitmap1Click(Sender: TObject);
    procedure ExportDownViewAsBiitmap1Click(Sender: TObject);
    procedure CopyFrontView1Click(Sender: TObject);
    procedure CopyBackView1Click(Sender: TObject);
    procedure CopyLeftView1Click(Sender: TObject);
    procedure CopyRightView1Click(Sender: TObject);
    procedure CopyTopView1Click(Sender: TObject);
    procedure CopyDownView1Click(Sender: TObject);
    procedure PasteFrontView1Click(Sender: TObject);
    procedure PasteBackView1Click(Sender: TObject);
    procedure PasteLeftView1Click(Sender: TObject);
    procedure PasteRightView1Click(Sender: TObject);
    procedure PasteTopView1Click(Sender: TObject);
    procedure PasteDownView1Click(Sender: TObject);
    procedure Paste3D1Click(Sender: TObject);
    procedure GridButton1Click(Sender: TObject);
    procedure SrinkHeightmap1Click(Sender: TObject);
    procedure CropHeightmap1Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure Copy3dButtonClick(Sender: TObject);
    procedure Save3dButtonClick(Sender: TObject);
    procedure Rotate1Click(Sender: TObject);
    procedure RotateHighQuality1Click(Sender: TObject);
    procedure Sprite1Click(Sender: TObject);
    procedure ShowScriptButton1Click(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure Compile1Click(Sender: TObject);
    procedure Run1Click(Sender: TObject);
    procedure Script1Click(Sender: TObject);
    procedure ScriptEditor1Click(Sender: TObject);
    procedure Exportslab6VOX1Click(Sender: TObject);
    procedure Countcolorsused1Click(Sender: TObject);
    procedure Greyscale1Click(Sender: TObject);
    procedure Convertto256colorspalette1Click(Sender: TObject);
    procedure PaletteSpeedButton1Click(Sender: TObject);
    procedure PaletteDoomClick(Sender: TObject);
    procedure PaletteHereticClick(Sender: TObject);
    procedure PaletteHexenClick(Sender: TObject);
    procedure PaletteStrifeClick(Sender: TObject);
    procedure PaletteRadixClick(Sender: TObject);
    procedure PaletteGreyScaleClick(Sender: TObject);
    procedure DDVOXtoslab6VOX1Click(Sender: TObject);
    procedure Front1Click(Sender: TObject);
    procedure Back1Click(Sender: TObject);
    procedure Left1Click(Sender: TObject);
    procedure Right1Click(Sender: TObject);
    procedure Top1Click(Sender: TObject);
    procedure Down1Click(Sender: TObject);
    procedure Xaxis1Click(Sender: TObject);
    procedure Yaxis1Click(Sender: TObject);
    procedure Zaxis1Click(Sender: TObject);
    procedure Increaselevel1Click(Sender: TObject);
    procedure Decreaselevel1Click(Sender: TObject);
    procedure View1Click(Sender: TObject);
  private
    { Private declarations }
    spritefilename: string;
    thetarotatey: integer;
    ffilename: string;
    fchanged: Boolean;
    fvoxelsize: Integer;
    fvoxelbuffer: voxelbuffer_p;
    selectionbuffer: voxelbuffer_p;
    xpos, ypos, zpos: integer;
    curpalcolor: LongWord;
    drawcolor1, drawcolor2: LongWord;
    mousedown1, mousedown2: Boolean;
    zoom: integer;
    buffer: TBitmap;
    rc: HGLRC;   // Rendering Context
    dc: HDC;     // Device Context
    Keys: array[0..255] of boolean;
    ElapsedTime, AppStart, LastTime : integer;  // Timing variables
    glpanx, glpany: integer;
    glmousedown: integer;
    undoManager: TUndoRedoManager;
    fsaveundomode: integer;
    glneedrecalc: boolean;
    glneedrefresh: boolean;
    gllist1: GLUint;
    gllist2: GLUint;
    gllist3: GLUint;
    drawbuffer: voxelbuffer2d_t;
    depthbuffer: depthvoxelbuffer2d_t;
    paintroverX, paintroverY: integer;
    voxelview: voxelview_t;
    lastglHorzPos, lastglVertPos: integer;
    rendredvoxels: integer;
    filemenuhistory: TFileMenuHistory;
    xlevel, ylevel, zlevel: integer;
    procedure PaintBox1Responder(X, Y: Integer; prt: paintrespondertype_t);
    procedure PaintBox1FreePaint(X, Y: Integer; prt: paintrespondertype_t);
    procedure DoPaintBox1FreePaint(X, Y: Integer; c: voxelitem_t);
    procedure PaintBox1Elevate(X, Y: Integer; prt: paintrespondertype_t);
    procedure DoPaintBox1Elevate(X, Y: Integer; c: voxelitem_t);
    procedure PaintBox1FloodFill(X, Y: Integer; prt: paintrespondertype_t);
    procedure PaintBox1ColorPicker(X, Y: Integer; prt: paintrespondertype_t);
    procedure PaintBox1Eraser(X, Y: Integer; prt: paintrespondertype_t);
    procedure Idle(Sender: TObject; var Done: Boolean);
    function CheckCanClose: boolean;
    procedure DoNewVoxel(const size: integer);
    procedure DoSaveVoxel(const fname: string);
    function DoLoadVoxel(const fname: string): boolean;
    procedure OnLoadVoxelFileMenuHistory(Sender: TObject; const fname: string);
    function DoLoadKVX(const fname: string): boolean;
    function DoLoadVOX(const fname: string): boolean;
    function DoLoadDDMESH(const fname: string): boolean;
    function DoLoadHeightmap(const fname: string): boolean;
    procedure SetFileName(const fname: string);
    procedure SetDrawColors(const col1, col2: LongWord);
    procedure DoSaveVoxelBinaryUndo(s: TStream);
    procedure DoLoadVoxelBinaryUndo(s: TStream);
    procedure SaveUndo(const mode: integer);
    procedure UpdateStausbar;
    procedure UpdateEnable;
    procedure DoRenderGL;
    function GetGridColor(const c: LongWord): LongWord;
    procedure DoPaintBox1Paint;
    procedure DoPaintBox1PaintPartial;
    procedure Get3dPreviewBitmap(const b: TBitmap);
    procedure ErrorMessage(const serror: string);
    procedure InfoMessage(const sinfo: string);
    function CreatePaletteBitmap(const pal: TPaletteArray): TBitmap;
    procedure UpdatePaletteBitmap(const pal: TPaletteArray);
    procedure SetDefaultPalette(const palname: string);
  public
    { Public declarations }
    procedure SaveUndoEditor;
    procedure UpdateDepthBuffer;
    property needrefresh: boolean read glneedrefresh write glneedrefresh;
    property needrecalc: boolean read glneedrecalc write glneedrecalc;
    property voxelbuffer: voxelbuffer_p read fvoxelbuffer;
    property voxelsize: Integer read fvoxelsize;
    property VoxelChanged: boolean read fchanged write fchanged;
    property FileName: string read ffilename;
  end;

var
  Form1: TForm1;

implementation

uses
  vxe_gl,
  vxe_system,
  vxe_script,
  vxe_rotate,
  vxe_multithreading,
  newfrm,
  vxe_defs,
  optionsfrm,
  vxe_mesh,
  vxe_kvx,
  vxe_utils,
  kvx2mesh,
  progressfrm,
  ddvox2mesh,
  ddvox2vox,
  frm_previewbitmap,
  frm_srinkheightmap,
  frm_rotate,
  vxe_export,
  frm_exportsprite,
  frm_selectpalette,
  frm_editor,
  vxe_quantize;

{$R *.dfm}

resourcestring
  rsTitle = 'DelphiDOOM Voxel Editor';

function axis(x, y, z: integer): char;
begin
  if x >= 0 then
    Result := 'x'
  else if y >= 0 then
    Result := 'y'
  else if z >= 0 then
    Result := 'z'
  else
    axis := ' ';
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  pfd: TPIXELFORMATDESCRIPTOR;
  pf: Integer;
begin
  MT_Init;
  DoubleBuffered := True;

  vox_initthreads;
  vox_initbuffers;

  thetarotatey := 0;
  spritefilename := '';

  filemenuhistory := TFileMenuHistory.Create(self);
  filemenuhistory.MenuItem0 := FileMenuHistoryItem0;
  filemenuhistory.MenuItem1 := FileMenuHistoryItem1;
  filemenuhistory.MenuItem2 := FileMenuHistoryItem2;
  filemenuhistory.MenuItem3 := FileMenuHistoryItem3;
  filemenuhistory.MenuItem4 := FileMenuHistoryItem4;
  filemenuhistory.MenuItem5 := FileMenuHistoryItem5;
  filemenuhistory.MenuItem6 := FileMenuHistoryItem6;
  filemenuhistory.MenuItem7 := FileMenuHistoryItem7;
  filemenuhistory.MenuItem8 := FileMenuHistoryItem8;
  filemenuhistory.MenuItem9 := FileMenuHistoryItem9;
  filemenuhistory.OnOpen := OnLoadVoxelFileMenuHistory;

  Increaselevel1.Caption := Increaselevel1.Caption + #9 + '+';
  Decreaselevel1.Caption := Decreaselevel1.Caption + #9 + '-';

  rendredvoxels := 0;
  Scaled := False;
  voxelview := vv_none;

  vxe_LoadSettingFromFile(ChangeFileExt(ParamStr(0), '.ini'));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory9));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory8));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory7));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory6));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory5));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory4));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory3));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory2));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory1));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory0));

  undoManager := TUndoRedoManager.Create;
  undoManager.OnLoadFromStream := DoLoadVoxelBinaryUndo;
  undoManager.OnSaveToStream := DoSaveVoxelBinaryUndo;
  undoManager.StreamType := sstFile;
  fsaveundomode := 0;
  paintroverX := -1;
  paintroverY := -1;

  GetMem(fvoxelbuffer, SizeOf(voxelbuffer_t));
  GetMem(selectionbuffer, SizeOf(voxelbuffer_t));

  OpenGLPanel.Width := Screen.Width div 2;
  OpenGLPanel.Height := (OpenGLPanel.Width * 3) div 4;
  OpenGLPanel.DoubleBuffered := True;

  glpanx := 0;
  glpany := 0;
  glmousedown := 0;
  curpalcolor := 0;
  zoom := 16;
  mousedown1 := False;
  mousedown2 := False;
  SetDrawColors(RGB(255, 255, 255), 0);
  if ParamCount > 0 then
  begin
    if not DoLoadVoxel(ParamStr(1)) then
      DoNewVoxel(32);
  end
  else
    DoNewVoxel(32);
  buffer := TBitmap.Create;
  buffer.PixelFormat := pf32bit;

  InitOpenGL;
  ReadExtensions;
  ReadImplementationProperties;

  // OpenGL initialisieren
  dc := GetDC(OpenGLPanel.Handle);

  // PixelFormat
  pfd.nSize := SizeOf(pfd);
  pfd.nVersion := 1;
  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or 0;
  pfd.iPixelType := PFD_TYPE_RGBA;      // PFD_TYPE_RGBA or PFD_TYPEINDEX
  pfd.cColorBits := 32;

  pf := ChoosePixelFormat(dc, @pfd);   // Returns format that most closely matches above pixel format
  SetPixelFormat(dc, pf, @pfd);

  rc := wglCreateContext(dc);    // Rendering Context = window-glCreateContext
  wglMakeCurrent(dc, rc);        // Make the DC (Form1) the rendering Context

  // Initialize GL environment variables

  glInit(OpenGLPanel.Width);
  gld_InitVoxelTexture;

  ZeroMemory(@keys, SizeOf(keys));
  ResetCamera(axis(xpos, ypos, zpos));

  OpenGLPanelResize(sender);    // sets up the perspective
  AppStart := I_GetTime;

  glneedrecalc := True;
  glneedrefresh := False;
  gllist1 := glGenLists(1);
  gllist2 := glGenLists(1);
  gllist3 := glGenLists(1);

  lastglHorzPos := 0;
  lastglVertPos := 0;

  // when the app has spare time, render the GL scene
  Application.OnIdle := Idle;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CheckCanClose;
  if CanClose then
    CanClose := EditorForm.CheckCanClose;
end;

function TForm1.CheckCanClose: boolean;
var
  ret: integer;
begin
  if fchanged then
  begin
    ret := MessageDlg('Voxel has been modified'#13#10'Do you want to save changes?', mtConfirmation, mbYesNoCancel, -1);
    if ret = Ord(mrCancel) then
    begin
      Result := False;
      Exit;
    end;
    if ret = Ord(mrNo)	then
    begin
      Result := True;
      Exit;
    end;
    if ret = Ord(mrYes) then
    begin
      SaveButton1Click(self);
      Result := not fchanged;
      Exit;
    end;
  end;
  Result := True;
end;

procedure TForm1.NewButton1Click(Sender: TObject);
var
  sz: integer;
begin
  if not CheckCanClose then
    Exit;

  sz := fvoxelsize;
  if GetNewVoxelSize(sz) then
  begin
    DoNewVoxel(sz);
    ResetCamera(axis(xpos, ypos, zpos));
  end;
end;

procedure TForm1.DoNewVoxel(const size: integer);
var
  i: integer;
  c: char;
begin
  fvoxelsize := size;
  PaintBox1.Width := fvoxelsize * zoom + 1;
  PaintBox1.Height := fvoxelsize * zoom + 1;
  SetFileName('');
  fchanged := False;
  glneedrecalc := True;
  xpos := -1;
  ypos := -1;
  zpos := -1;
  ComboBox1.Items.Clear;
  for c := 'x' to 'z' do
    for i := 0 to fvoxelsize - 1 do
      ComboBox1.Items.Add(c + IntToStr(i));
  ComboBox1.Items.Add('front');
  ComboBox1.Items.Add('back');
  ComboBox1.Items.Add('left');
  ComboBox1.Items.Add('right');
  ComboBox1.Items.Add('top');
  ComboBox1.Items.Add('down');
  ComboBox1.ItemIndex := ComboBox1.Items.Count - 2;
  voxelview := vv_top;
  UpdateDepthBuffer;
  FillChar(fvoxelbuffer^, SizeOf(voxelbuffer_t), Chr(0));
  PaintBox1.Invalidate;
  undoManager.Clear;
  xlevel := 0;
  ylevel := 0;
  zlevel := 0;
end;

procedure TForm1.SetFileName(const fname: string);
begin
  ffilename := fname;
  Caption := rsTitle;
  if ffilename <> '' then
    Caption := Caption + ' - ' + MkShortName(ffilename);
end;

procedure TForm1.SaveButton1Click(Sender: TObject);
begin
  if ffilename = '' then
  begin
    if SaveDialog1.Execute then
    begin
      ffilename := SaveDialog1.FileName;
      filemenuhistory.AddPath(ffilename);
    end
    else
    begin
      Beep;
      Exit;
    end;
  end;
  DoSaveVoxel(ffilename);
end;

procedure TForm1.DoSaveVoxel(const fname: string);
var
  t: TextFile;
  xx, yy, zz: integer;
  skip: integer;
begin
  SetFileName(fname);

  BackupFile(fname);
  AssignFile(t, fname);
  Rewrite(t);
  Writeln(t, fvoxelsize);
  for xx := 0 to fvoxelsize - 1 do
    for yy := 0 to fvoxelsize - 1 do
    begin
      skip := 0;
      for zz := 0 to fvoxelsize - 1 do
      begin
        if fvoxelbuffer[xx, yy, zz] = 0 then
        begin
          Inc(skip);
          if zz = fvoxelsize - 1 then
            Writeln(t, 'skip ', skip);
        end
        else
        begin
          if skip > 0 then
          begin
            Write(t, 'skip ', skip, ', ');
            skip := 0;
          end;
          if zz = fvoxelsize - 1 then
            Writeln(t, fvoxelbuffer[xx, yy, zz])
          else
            Write(t, fvoxelbuffer[xx, yy, zz], ', ');
        end;
      end;
    end;

  CloseFile(t);

  fchanged := False;
end;

function TForm1.DoLoadVoxel(const fname: string): boolean;
var
  buf: TStringList;
  sc: TScriptEngine;
  xx, yy, zz: integer;
  s: string;
begin
  if not FileExists(fname) then
  begin
    s := Format('File %s does not exist!', [MkShortName(fname)]);
    ErrorMessage(s);
    Result := False;
    Exit;
  end;

  undoManager.Clear;

  buf := TStringList.Create;
  try
    buf.LoadFromFile(fname);
    sc := TScriptEngine.Create(buf.Text);
    sc.MustGetInteger;
    DoNewVoxel(sc._Integer);
    xx := 0;
    yy := 0;
    zz := 0;
    while sc.GetString do
    begin
      if sc.MatchString('skip') then
      begin
        sc.MustGetInteger;
        inc(zz, sc._Integer);
      end
      else
      begin
        sc.UnGet;
        sc.MustGetInteger;
        fvoxelbuffer[xx, yy, zz] := sc._Integer;
        Inc(zz);
      end;
      if zz = fvoxelsize then
      begin
        zz := 0;
        Inc(yy);
        if yy = fvoxelsize then
        begin
          yy := 0;
          Inc(xx);
          if xx = fvoxelsize then
            Break;
        end;
      end;
    end;
    sc.Free;
    filemenuhistory.AddPath(fname);
  finally
    buf.Free;
  end;

  SetFileName(fname);
  PaintBox1.Invalidate;
  glneedrecalc := True;
  Result := True;
end;

function TForm1.DoLoadKVX(const fname: string): boolean;
var
  strm: TFileStream;
  pal: array[0..255] of LongWord;
  i: integer;
  r, g, b: byte;
  numbytes: integer;
  xsiz, ysiz, zsiz, xpivot, ypivot, zpivot: integer;
	xoffset: PIntegerArray;
	xyoffset: PSmallIntPArray;
  offs: integer;
  voxdatasize: integer;
  voxdata: PByteArray;
  size: integer;
  xx, yy, zz: integer;
  x1, y1, z1: integer;
  endptr: PByte;
  slab: kvxslab_p;
  s: string;
  kvxbuffer: kvxbuffer_p;
  maxpal: integer;
  cc: integer;
  palfactor: double;
begin
  if not FileExists(fname) then
  begin
    s := Format('File %s does not exist!', [MkShortName(fname)]);
    ErrorMessage(s);
    Result := False;
    Exit;
  end;

  strm := TFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);

  strm.Seek(strm.size - 768, soFromBeginning);
  maxpal := 0;
  for i := 0 to 255 do
  begin
    strm.Read(b, SizeOf(Byte));
    if b > maxpal then
      maxpal := b;
    strm.Read(g, SizeOf(Byte));
    if g > maxpal then
      maxpal := g;
    strm.Read(r, SizeOf(Byte));
    if r > maxpal then
      maxpal := r;
    pal[i] := r shl 16 + g shl 8 + b;
    if pal[i] = 0 then
      pal[i] := $01;
  end;
  if (maxpal < 255) and (maxpal > 0) then
  begin
    palfactor := 255 / maxpal;
    if palfactor > 4.0 then
      palfactor := 4.0;
    for i := 0 to 255 do
    begin
      r := pal[i] shr 16;
      g := pal[i] shr 8;
      b := pal[i];
      cc := round(palfactor * r);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      r := cc;
      cc := round(palfactor * g);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      g := cc;
      cc := round(palfactor * b);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      b := cc;
      pal[i] := r shl 16 + g shl 8 + b;
    end;
  end;

  strm.Seek(0, soFromBeginning);
  strm.Read(numbytes, SizeOf(Integer));
  strm.Read(xsiz, SizeOf(Integer));
  strm.Read(ysiz, SizeOf(Integer));
  strm.Read(zsiz, SizeOf(Integer));

  size := 1;

  while xsiz > size do
    size := size * 2;
  while ysiz > size do
    size := size * 2;
  while zsiz > size do
    size := size * 2;

  if size < 256 then
    size := size * 2;

  DoNewVoxel(size);

  strm.Read(xpivot, SizeOf(Integer));
  strm.Read(ypivot, SizeOf(Integer));
  strm.Read(zpivot, SizeOf(Integer));

  GetMem(xoffset, (xsiz + 1) * SizeOf(Integer));
  GetMem(xyoffset, xsiz * SizeOf(PSmallIntArray));
  for i := 0 to xsiz - 1 do
    GetMem(xyoffset[i], (ysiz + 1) * SizeOf(SmallInt));

  strm.Read(xoffset^, (xsiz + 1) * SizeOf(Integer));

  for i := 0 to xsiz - 1 do
    strm.Read(xyoffset[i]^, (ysiz + 1) * SizeOf(SmallInt));

  offs := xoffset[0];

  voxdatasize := numbytes - 24 - (xsiz + 1) * 4 - xsiz * (ysiz + 1) * 2;
  GetMem(voxdata, voxdatasize);
  strm.Read(voxdata^, voxdatasize);
  strm.Free;

  GetMem(kvxbuffer, SizeOf(kvxbuffer_t));
  for xx := 0 to xsiz - 1 do
    for yy := 0 to ysiz - 1 do
       for zz := 0 to zsiz - 1 do
         kvxbuffer[xx, yy, zz] := $FFFF;

  for xx := 0 to xsiz - 1 do
  begin
    for yy := 0 to ysiz - 1 do
    begin
      endptr := @voxdata[xoffset[xx] + xyoffset[xx][yy + 1] - offs];
      slab := @voxdata[xoffset[xx] + xyoffset[xx][yy] - offs];
      while Integer(slab) < integer(endptr) do
      begin
        for zz := slab.ztop to slab.zleng + slab.ztop - 1 do
          kvxbuffer[xx, yy, zz] := slab.col[zz - slab.ztop];
        slab := kvxslab_p(integer(slab) + slab.zleng + 3);
      end;
    end;
  end;

  x1 := size div 2 - xpivot div 256;
  y1 := size div 2 - ypivot div 256;
  z1 := size{ div 2} - zpivot div 256;
  if x1 < 0 then
    x1 := 0;
  if y1 < 0 then
    y1 := 0;
  if z1 < 0 then
    z1 := 0;
  while x1 + xsiz > size do
    dec(x1);
  while y1 + ysiz > size do
    dec(y1);
  while z1 + zsiz > size do
    dec(z1);
  for xx := x1 to x1 + xsiz - 1 do
    for yy := y1 to y1 + ysiz - 1 do
      for zz := z1 to z1 + zsiz - 1 do
        if kvxbuffer[xx - x1, yy - y1, zz - z1] <> $FFFF then
          fvoxelbuffer[xx, zz, size - yy - 1] := pal[kvxbuffer[xx - x1, yy - y1, zz - z1]];


  FreeMem(xoffset, (xsiz + 1) * SizeOf(Integer));
  for i := 0 to xsiz - 1 do
    FreeMem(xyoffset[i], (ysiz + 1) * SizeOf(SmallInt));
  FreeMem(xyoffset, xsiz * SizeOf(PSmallIntArray));
  FreeMem(voxdata, voxdatasize);
  FreeMem(kvxbuffer, SizeOf(kvxbuffer_t));

  PaintBox1.Invalidate;
  glneedrecalc := True;
  Result := True;
end;

function TForm1.DoLoadVOX(const fname: string): boolean;
var
  strm: TFileStream;
  pal: array[0..255] of LongWord;
  i: integer;
  r, g, b: byte;
  xsiz, ysiz, zsiz: integer;
  voxdatasize: integer;
  voxdata: PByteArray;
  size: integer;
  xx, yy, zz: integer;
  x1, y1, z1: integer;
  s: string;
  maxpal: integer;
  cc: integer;
  palfactor: double;
begin
  if not FileExists(fname) then
  begin
    s := Format('File %s does not exist!', [MkShortName(fname)]);
    ErrorMessage(s);
    Result := False;
    Exit;
  end;

  strm := TFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);

  strm.Seek(strm.size - 768, soFromBeginning);
  maxpal := 0;
  for i := 0 to 255 do
  begin
    strm.Read(b, SizeOf(Byte));
    if b > maxpal then
      maxpal := b;
    strm.Read(g, SizeOf(Byte));
    if g > maxpal then
      maxpal := g;
    strm.Read(r, SizeOf(Byte));
    if r > maxpal then
      maxpal := r;
    pal[i] := r shl 16 + g shl 8 + b;
    if pal[i] = 0 then
      pal[i] := $01;
  end;
  if (maxpal < 255) and (maxpal > 0) then
  begin
    palfactor := 255 / maxpal;
    if palfactor > 4.0 then
      palfactor := 4.0;
    for i := 0 to 255 do
    begin
      r := pal[i] shr 16;
      g := pal[i] shr 8;
      b := pal[i];
      cc := round(palfactor * r);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      r := cc;
      cc := round(palfactor * g);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      g := cc;
      cc := round(palfactor * b);
      if cc < 0 then
        cc := 0
      else if cc > 255 then
        cc := 255;
      b := cc;
      pal[i] := r shl 16 + g shl 8 + b;
    end;
  end;

  strm.Seek(0, soFromBeginning);
  strm.Read(xsiz, SizeOf(Integer));
  strm.Read(ysiz, SizeOf(Integer));
  strm.Read(zsiz, SizeOf(Integer));

  if (xsiz <= 0) or (xsiz > 256) or
     (ysiz <= 0) or (ysiz > 256) or
     (zsiz <= 0) or (zsiz > 256) then
  begin
    s := Format('File %s has invalid dimentions (%dx%dx%d)!', [MkShortName(fname), xsiz, ysiz, zsiz]);
    ErrorMessage(s);
    Result := False;
    strm.Free;
    Exit;
  end;

  size := xsiz;
  if size < ysiz then
    size := ysiz;
  if size < zsiz then
    size := zsiz;

  DoNewVoxel(size);

  voxdatasize := xsiz * ysiz * zsiz;
  GetMem(voxdata, voxdatasize);
  strm.Read(voxdata^, voxdatasize);
  strm.Free;

  x1 := (size - xsiz) div 2;
  y1 := (size - ysiz) div 2;
  z1 := (size - zsiz) div 2;
  i := 0;
  for xx := x1 to x1 + xsiz - 1 do
    for yy := y1 to y1 + ysiz - 1 do
      for zz := z1 to z1 + zsiz - 1 do
      begin
        if voxdata[i] <> 255 then
          fvoxelbuffer[xx, zz, size - yy - 1] := pal[voxdata[i]];
        inc(i);
      end;
  FreeMem(voxdata, voxdatasize);

  PaintBox1.Invalidate;
  glneedrecalc := True;
  Result := True;
end;

function TForm1.DoLoadDDMESH(const fname: string): boolean;
var
  strm: TFileStream;
  i: integer;
  xb, yb, zb: byte;
  HDR: LongWord;
  version: integer;
  size: integer;
  quads: integer;
  fnumvoxels: Integer;
  c: LongWord;
  s: string;
begin
  if not FileExists(fname) then
  begin
    s := Format('File %s does not exist!', [MkShortName(fname)]);
    ErrorMessage(s);
    Result := False;
    Exit;
  end;

  strm := TFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);

  strm.Read(HDR, SizeOf(LongWord));
  if HDR <> Ord('D') + Ord('D') shl 8 + Ord('M') shl 16 + Ord('S') shl 24 then
  begin
    s := Format('File %s does not have DDMESH magic header!', [MkShortName(fname)]);
    ErrorMessage(s);
    Result := False;
    strm.Free;
    Exit;
  end;

  strm.Read(version, SizeOf(integer));
  if version <> 1 then
  begin
    s := Format('File %s is from unsupported version = %d!', [MkShortName(fname), version]);
    ErrorMessage(s);
    Result := False;
    strm.Free;
    Exit;
  end;

  strm.Read(size, SizeOf(integer));
  DoNewVoxel(size);

  strm.Read(quads, SizeOf(integer));

  strm.Position := 16 + quads * (4 * SizeOf(voxelvertex_t) + SizeOf(LongWord));

  strm.Read(fnumvoxels, SizeOf(integer));

  for i := 0 to fnumvoxels - 1 do
  begin
    strm.Read(xb, SizeOf(byte));
    strm.Read(yb, SizeOf(byte));
    strm.Read(zb, SizeOf(byte));
    strm.Read(c, SizeOf(LongWord));
    fvoxelbuffer[xb, yb, zb] := c;
  end;

  strm.Free;

  PaintBox1.Invalidate;
  glneedrecalc := True;
  Result := True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Timer1.Enabled := False;
  glDeleteLists(gllist1, 1);
  glDeleteLists(gllist2, 1);
  glDeleteLists(gllist3, 1);
  gld_ShutDownVoxelTexture;
  FreeMem(fvoxelbuffer, SizeOf(voxelbuffer_t));
  FreeMem(selectionbuffer, SizeOf(voxelbuffer_t));
  buffer.Free;
  undoManager.Free;
  wglMakeCurrent(0, 0);
  wglDeleteContext(rc);

  stringtobigstring(filemenuhistory.PathStringIdx(0), @opt_filemenuhistory0);
  stringtobigstring(filemenuhistory.PathStringIdx(1), @opt_filemenuhistory1);
  stringtobigstring(filemenuhistory.PathStringIdx(2), @opt_filemenuhistory2);
  stringtobigstring(filemenuhistory.PathStringIdx(3), @opt_filemenuhistory3);
  stringtobigstring(filemenuhistory.PathStringIdx(4), @opt_filemenuhistory4);
  stringtobigstring(filemenuhistory.PathStringIdx(5), @opt_filemenuhistory5);
  stringtobigstring(filemenuhistory.PathStringIdx(6), @opt_filemenuhistory6);
  stringtobigstring(filemenuhistory.PathStringIdx(7), @opt_filemenuhistory7);
  stringtobigstring(filemenuhistory.PathStringIdx(8), @opt_filemenuhistory8);
  stringtobigstring(filemenuhistory.PathStringIdx(9), @opt_filemenuhistory9);

  vxe_SaveSettingsToFile(ChangeFileExt(ParamStr(0), '.ini'));
  vox_shutdownthreads;
  MT_ShutDown;
  filemenuhistory.Free;
end;

procedure TForm1.ErrorMessage(const serror: string);
begin
  MessageDlg(serror, mtError, [mbOK], -1);
end;

procedure TForm1.InfoMessage(const sinfo: string);
begin
  MessageDlg(sinfo, mtInformation, [mbOK], -1);
end;

procedure TForm1.AboutButton1Click(Sender: TObject);
begin
  InfoMessage(
      Format(
        '%s'#13#10'Version %s'#13#10#13#10'A tool for creating VOXELS for the DelphiDoom engine.'#13#10'© 2013 - 2020, jvalavanis@gmail.com',
        [rsTitle, I_VersionBuilt]
      )
  );
end;

procedure TForm1.SaveAsButton1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    filemenuhistory.AddPath(SaveDialog1.FileName);
    DoSaveVoxel(SaveDialog1.FileName);
  end;
end;

procedure TForm1.ExitButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.SetDrawColors(const col1, col2: LongWord);
begin
  drawcolor1 := col1;
  drawcolor2 := col2;
  DrawColor1Panel.Color := drawcolor1;
  DrawColor2Panel.Color := drawcolor2;
end;

procedure TForm1.DrawColor1PanelDblClick(Sender: TObject);
begin
  ColorDialog1.Color := drawcolor1;
  if ColorDialog1.Execute then
  begin
    drawcolor1 := ColorDialog1.Color;
    DrawColor1Panel.Color := drawcolor1;
  end;
end;

procedure TForm1.DrawColor2PanelDblClick(Sender: TObject);
begin
  ColorDialog1.Color := drawcolor2;
  if ColorDialog1.Execute then
  begin
    drawcolor2 := ColorDialog1.Color;
    DrawColor2Panel.Color := drawcolor2;
  end;
end;

procedure TForm1.OpenButton1Click(Sender: TObject);
begin
  if not CheckCanClose then
    Exit;

  if OpenDialog1.Execute then
  begin
    DoLoadVoxel(OpenDialog1.FileName);
    ResetCamera(axis(xpos, ypos, zpos));
  end;
end;

procedure TForm1.OnLoadVoxelFileMenuHistory(Sender: TObject; const fname: string);
begin
  if not CheckCanClose then
    Exit;

  DoLoadVoxel(fname);
  ResetCamera(axis(xpos, ypos, zpos));
end;


procedure TForm1.ComboBox1Change(Sender: TObject);
var
  idx: integer;
  c: Char;
  pos: integer;
  s: string;
begin
  idx := ComboBox1.ItemIndex;
  if idx < 0 then
    Exit;

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  s := ComboBox1.Items.Strings[idx];
  if s = 'left' then
    voxelview := vv_left
  else if s = 'right' then
    voxelview := vv_right
  else if s = 'top' then
    voxelview := vv_top
  else if s = 'down' then
    voxelview := vv_down
  else if s = 'front' then
    voxelview := vv_front
  else if s = 'back' then
    voxelview := vv_back
  else
    voxelview := vv_none;

  if voxelview = vv_none then
  begin
    if ElevateSpeedButton.Down then
      FreeDrawSpeedButton.Down := True;
    ElevateSpeedButton.Enabled := False;

    c := s[1];
    s[1] := ' ';
    s := Trim(s);
    pos := StrToIntDef(s, 0);
    if c = 'x' then
    begin
      xlevel := pos;
      xpos := pos;
      ypos := -1;
      zpos := -1;
    end
    else if c = 'y' then
    begin
      ylevel := pos;
      xpos := -1;
      ypos := pos;
      zpos := -1;
    end
    else if c = 'z' then
    begin
      zlevel := pos;
      xpos := -1;
      ypos := -1;
      zpos := pos;
    end;
  end
  else
  begin
    xpos := -1;
    ypos := -1;
    zpos := -1;
    UpdateDepthBuffer;
    ElevateSpeedButton.Enabled := True;
  end;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

function TForm1.GetGridColor(const c: LongWord): LongWord;
const
  CMODIFIER = 16;
  function _c(const bb: byte): byte;
  begin
    if bb < 128 then
      Result := bb + 16
    else
      Result := bb - 16;
  end;
var
  r, g, b: byte;
begin
  r := _c(GetRValue(c));
  g := _c(GetGValue(c));
  b := _c(GetBValue(c));
  Result := RGB(r, g, b);
end;

procedure TForm1.DoPaintBox1Paint;
var
  i, j: integer;
  slice2d: voxelbuffer2d_p;
  cv: TCanvas;
begin
  buffer.Width := fvoxelsize * zoom + 1;
  buffer.Height := fvoxelsize * zoom + 1;
  cv := buffer.Canvas;
  cv.Pen.Style := psSolid;
  cv.Pen.Color := clBlack;
  cv.Brush.Style := bsSolid;
  cv.Brush.Color := RGB(64, 64, 64);
  cv.Rectangle(0, 0, fvoxelsize * zoom + 1, fvoxelsize * zoom + 1);

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
      begin
        cv.Brush.Color := fvoxelbuffer[xpos, i, j];
        if cv.Brush.Color = 0 then
        begin
          cv.Brush.Style := bsDiagCross;
          cv.Pen.Color := clBlack;
        end
        else
        begin
          cv.Brush.Style := bsSolid;
          cv.Pen.Color := GetGridColor(cv.Brush.Color);
        end;
        cv.Rectangle(i * zoom,
                     j * zoom,
                     (1 + i) * zoom,
                     (1 + j) * zoom);
      end;
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
      begin
        cv.Brush.Color := fvoxelbuffer[j, ypos, i];
        if cv.Brush.Color = 0 then
        begin
          cv.Brush.Style := bsDiagCross;
          cv.Pen.Color := clBlack;
        end
        else
        begin
          cv.Brush.Style := bsSolid;
          cv.Pen.Color := GetGridColor(cv.Brush.Color);
        end;
        cv.Rectangle(j * zoom,
                     i * zoom,
                     (1 + j) * zoom,
                     (1 + i) * zoom);
      end;
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
      begin
        cv.Brush.Color := fvoxelbuffer[i, j, zpos];
        if cv.Brush.Color = 0 then
        begin
          cv.Brush.Style := bsDiagCross;
          cv.Pen.Color := clBlack;
        end
        else
        begin
          cv.Brush.Style := bsSolid;
          cv.Pen.Color := GetGridColor(cv.Brush.Color);
        end;
        cv.Rectangle(i * zoom,
                     j * zoom,
                     (1 + i) * zoom,
                     (1 + j) * zoom);
      end;
  end
  else if voxelview <> vv_none then
  begin
    GetMem(slice2d, SizeOf(voxelbuffer2d_t));
    vox_getviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
      begin
        cv.Brush.Color := slice2d[i, j];
        if cv.Brush.Color = 0 then
        begin
          cv.Brush.Style := bsDiagCross;
          cv.Pen.Color := clBlack;
        end
        else
        begin
          cv.Brush.Style := bsSolid;
          cv.Pen.Color := GetGridColor(cv.Brush.Color);
        end;
        cv.Rectangle(i * zoom,
                     j * zoom,
                     (1 + i) * zoom,
                     (1 + j) * zoom);
      end;
    FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
  end;

  PaintBox1.Canvas.Draw(0, 0, buffer);
end;

procedure TForm1.DoPaintBox1PaintPartial;
var
  i, j: integer;
  slice2d: voxelbuffer2d_p;
  aleft, aright, atop, abottom: integer;
  istart, iend, jstart, jend: integer;
  cv: TCanvas;
begin
  aleft := ScrollBox2.HorzScrollBar.ScrollPos;
  atop := ScrollBox2.VertScrollBar.ScrollPos;
  aright := aleft + ScrollBox2.Width;
  if aright > PaintBox1.Width then
    aright := PaintBox1.Width;
  abottom := atop + ScrollBox2.Height;
  if abottom > PaintBox1.Height then
    abottom := PaintBox1.Height;

  istart := GetIntInRange(aleft div zoom, 0, fvoxelsize - 1);
  iend := GetIntInRange(aright div zoom + 1, 0, fvoxelsize - 1);
  jstart := GetIntInRange(atop div zoom, 0, fvoxelsize - 1);
  jend := GetIntInRange(abottom div zoom + 1, 0, fvoxelsize - 1);

  buffer.Width := aright - aleft + 1;
  buffer.Height := abottom - atop + 1;

  cv := buffer.Canvas;
  cv.Pen.Style := psClear;
  cv.Pen.Color := clBlack;
  cv.Brush.Style := bsSolid;
  cv.Brush.Color := RGB(64, 64, 64);
  cv.Rectangle(0, 0, buffer.width, buffer.height);
  cv.Pen.Style := psSolid;

  if xpos >= 0 then
  begin
    for i := istart to iend do
      for j := jstart to jend do
      begin
        cv.Brush.Color := fvoxelbuffer[xpos, i, j];
        if cv.Brush.Color = 0 then
        begin
          cv.Brush.Style := bsDiagCross;
          cv.Pen.Color := clBlack;
        end
        else
        begin
          cv.Brush.Style := bsSolid;
          cv.Pen.Color := GetGridColor(cv.Brush.Color);
        end;
        cv.Rectangle(i * zoom - aleft,
                     j * zoom - atop,
                     (1 + i) * zoom - aleft,
                     (1 + j) * zoom - atop);
      end;
  end
  else if ypos >= 0 then
  begin
    for i := istart to iend do
      for j := jstart to jend do
      begin
        cv.Brush.Color := fvoxelbuffer[j, ypos, i];
        if cv.Brush.Color = 0 then
        begin
          cv.Brush.Style := bsDiagCross;
          cv.Pen.Color := clBlack;
        end
        else
        begin
          cv.Brush.Style := bsSolid;
          cv.Pen.Color := GetGridColor(cv.Brush.Color);
        end;
        cv.Rectangle(j * zoom - aleft,
                     i * zoom - atop,
                     (1 + j) * zoom - aleft,
                     (1 + i) * zoom - atop);
      end;
  end
  else if zpos >= 0 then
  begin
    for i := istart to iend do
      for j := jstart to jend do
      begin
        cv.Brush.Color := fvoxelbuffer[i, j, zpos];
        if cv.Brush.Color = 0 then
        begin
          cv.Brush.Style := bsDiagCross;
          cv.Pen.Color := clBlack;
        end
        else
        begin
          cv.Brush.Style := bsSolid;
          cv.Pen.Color := GetGridColor(cv.Brush.Color);
        end;
        cv.Rectangle(i * zoom - aleft,
                     j * zoom - atop,
                     (1 + i) * zoom - aleft,
                     (1 + j) * zoom - atop);
      end;
  end
  else if voxelview <> vv_none then
  begin
    GetMem(slice2d, SizeOf(voxelbuffer2d_t));
    vox_getviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
    for i := istart to iend do
      for j := jstart to jend do
      begin
        cv.Brush.Color := slice2d[i, j];
        if cv.Brush.Color = 0 then
        begin
          cv.Brush.Style := bsDiagCross;
          cv.Pen.Color := clBlack;
        end
        else
        begin
          cv.Brush.Style := bsSolid;
          cv.Pen.Color := GetGridColor(cv.Brush.Color);
        end;
        cv.Rectangle(i * zoom - aleft,
                     j * zoom - atop,
                     (1 + i) * zoom - aleft,
                     (1 + j) * zoom - atop);
      end;
    FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
  end;

  PaintBox1.Canvas.Draw(aleft, atop, buffer);
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  if (ScrollBox2.HorzScrollBar.ScrollPos = 0) and (ScrollBox2.VertScrollBar.ScrollPos = 0) and
     (ScrollBox2.Width >= PaintBox1.Width) and (ScrollBox2.Height >= PaintBox1.Height) then
    DoPaintBox1Paint
  else
    DoPaintBox1PaintPartial;
end;

procedure TForm1.ZoomInButton1Click(Sender: TObject);
var
  sz: integer;
begin
  if zoom >= 32 then
    Exit;
  Inc(zoom);
{  ScrollBox2.VertScrollBar.Position := (ScrollBox2.VertScrollBar.Position * zoom) div (zoom - 1);
  ScrollBox2.HorzScrollBar.Position := (ScrollBox2.HorzScrollBar.Position * zoom) div (zoom - 1);}
  sz := fvoxelsize * zoom + 1;
  PaintBox1.Width := sz;
  PaintBox1.Height := sz;
  PaintBox1.Invalidate;
end;

procedure TForm1.ZoomOutButton1Click(Sender: TObject);
var
  sz: integer;
begin
  if zoom <= 3 then
    Exit;
  Dec(zoom);
{  ScrollBox2.VertScrollBar.Position := (ScrollBox2.VertScrollBar.Position * zoom) div (zoom + 1);
  ScrollBox2.HorzScrollBar.Position := (ScrollBox2.HorzScrollBar.Position * zoom) div (zoom + 1);}
  sz := fvoxelsize * zoom + 1;
  PaintBox1.Width := sz;
  PaintBox1.Height := sz;
  PaintBox1.Invalidate;
end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
  r: TRect;
  z: glfloat;
begin
  pt := PaintBox1.Parent.Parent.ScreenToClient(MousePos);
  r := PaintBox1.ClientRect;
  if r.Right > ScrollBox2.Width then
    r.Right := ScrollBox2.Width;
  if r.Bottom > ScrollBox2.Height then
    r.Bottom := ScrollBox2.Height;
  if PtInRect(r, pt) then
    ZoomOutButton1Click(Sender);

  pt := OpenGLPanel.Parent.ScreenToClient(MousePos);
  r := OpenGLPanel.ClientRect;
  if r.Right > ScrollBox1.Width then
    r.Right := ScrollBox1.Width;
  if r.Bottom > ScrollBox1.Height then
    r.Bottom := ScrollBox1.Height;
  if PtInRect(r, pt) then
  begin
    z := camera.z - 0.5;
    z := z / 0.99;
    camera.z := z + 0.5;
    if camera.z < -6.0 then
      camera.z := -6.0;
    glneedrefresh := True;
  end;
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
  r: TRect;
  z: glfloat;
begin
  pt := PaintBox1.Parent.Parent.ScreenToClient(MousePos);
  r := PaintBox1.ClientRect;
  if r.Right > ScrollBox2.Width then
    r.Right := ScrollBox2.Width;
  if r.Bottom > ScrollBox2.Height then
    r.Bottom := ScrollBox2.Height;
  if PtInRect(r, pt) then
    ZoomInButton1Click(Sender);

  pt := OpenGLPanel.Parent.ScreenToClient(MousePos);
  r := OpenGLPanel.ClientRect;
  if r.Right > ScrollBox1.Width then
    r.Right := ScrollBox1.Width;
  if r.Bottom > ScrollBox1.Height then
    r.Bottom := ScrollBox1.Height;
  if PtInRect(r, pt) then
  begin
    z := camera.z - 0.5;
    z := z * 0.99;
    camera.z := z + 0.5;
    if camera.z > 0.5 then
      camera.z := 0.5;
    glneedrefresh := True;
  end;
end;

procedure TForm1.PaletteMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not (Button in [mbLeft, mbRight]) then
    Exit;

  if (X < 8) and (Y < 8) then
    curpalcolor := 0
  else
    curpalcolor := Palette.Canvas.Pixels[X, Y];

  if Button = mbLeft then
    SetDrawColors(curpalcolor, drawcolor2)
  else
    SetDrawColors(drawcolor1, curpalcolor);
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  paintroverX := -1;
  paintroverY := -1;
  if Button = mbLeft then
  begin
    mousedown1 := True;
    mousedown2 := False;
    if FreeDrawSpeedButton.Down or EraseSpeedButton.Down or ElevateSpeedButton.Down then
    begin
      if voxelview = vv_none then
        SaveUndo(0)
      else
      begin
        SaveUndo(1);
        UpdateDepthBuffer;
      end;
    end;
    PaintBox1Responder(X, Y, prt_buttondown);
  end
  else if Button = mbRight then
  begin
    mousedown1 := False;
    mousedown2 := True;
    if FreeDrawSpeedButton.Down or EraseSpeedButton.Down or ElevateSpeedButton.Down then
    begin
      if voxelview = vv_none then
        SaveUndo(0)
      else
      begin
        SaveUndo(1);
        UpdateDepthBuffer;
      end;
    end;
    PaintBox1Responder(X, Y, prt_buttondown);
  end
  else
  begin
    mousedown1 := False;
    mousedown2 := False;
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mousedown1 := False;
  mousedown2 := False;
  glneedrecalc := True;
  paintroverX := -1;
  paintroverY := -1;
  UpdateDepthBuffer;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  PaintBox1Responder(X, Y, prt_buttonmove);
end;

procedure TForm1.PaintBox1Responder(X, Y: Integer; prt: paintrespondertype_t);
var
  nx, ny, nz: integer;
  c: voxelitem_t;
  dbitem: depthvoxelitem_t;
  depth: integer;
begin
  if xpos >= 0 then
  begin
    nx := xpos;
    ny := X div zoom;
    nz := Y div zoom;
    depth := nx;
  end
  else if ypos >= 0 then
  begin
    nx := X div zoom;
    ny := ypos;
    nz := Y div zoom;
    depth := ny;
  end
  else if zpos >= 0 then
  begin
    nx := X div zoom;
    ny := Y div zoom;
    nz := zpos;
    depth := nz;
  end
  else if voxelview <> vv_none then
  begin
    nx := X div zoom;
    ny := Y div zoom;
    dbitem := depthbuffer[nx, ny];
    nz := dbitem.depth;
    depth := nz;
  end
  else
    Exit;

  if nx < 0 then
    nx := 0
  else if nx >= fvoxelsize then
    nx := fvoxelsize - 1;
  if ny < 0 then
    ny := 0
  else if ny >= fvoxelsize then
    ny := fvoxelsize - 1;
  if nz < 0 then
    nz := 0
  else if nz >= fvoxelsize then
    nz := fvoxelsize - 1;

  if voxelview = vv_none then
    c := fvoxelbuffer[nx, ny, nz]
  else
    c := dbitem.color;

  StatusBar1.Panels[0].Text :=
    Format('x=%d, y=%d, depth=%d, color=(%d, %d, %d)',
      [X div zoom, Y div zoom, depth, GetRValue(c), GetGValue(c), GetBValue(c)]);

  if not (mousedown1 or mousedown2) then
    Exit;

  if FreeDrawSpeedButton.Down then
    PaintBox1FreePaint(X, Y, prt)
  else if FloodFillSpeedButton.Down then
    PaintBox1FloodFill(X, Y, prt)
  else if ColorPickerSpeedButton.Down then
    PaintBox1ColorPicker(X, Y, prt)
  else if EraseSpeedButton.Down then
    PaintBox1Eraser(X, Y, prt)
  else if ElevateSpeedButton.Down then
    PaintBox1Elevate(X, Y, prt);

  paintroverX := X;
  paintroverY := Y;
end;

procedure TForm1.DoPaintBox1FreePaint(X, Y: Integer; c: voxelitem_t);
var
  vx, vy, vz: integer;
  pv, pv2: voxelitem_p;
  cnew: voxelitem_t;
begin
  if xpos >= 0 then
  begin
    vx := xpos;
    vy := X div zoom;
    vz := Y div zoom;
  end
  else if ypos >= 0 then
  begin
    vx := X div zoom;
    vy := ypos;
    vz := Y div zoom;
  end
  else if zpos >= 0 then
  begin
    vx := X div zoom;
    vy := Y div zoom;
    vz := zpos
  end
  else if voxelview <> vv_none then
  begin
    vx := X div zoom;
    vy := Y div zoom;
    vz := 0;
  end
  else
    Exit;

  if vx < 0 then
    vx := 0
  else if vx >= fvoxelsize then
    vx := fvoxelsize - 1;

  if vy < 0 then
    vy := 0
  else if vy >= fvoxelsize then
    vy := fvoxelsize - 1;

  if vz < 0 then
    vz := 0
  else if vz >= fvoxelsize then
    vz := fvoxelsize - 1;

  if voxelview <> vv_none then
  begin
    pv := vox_getdepthpointerAtXYZ(fvoxelbuffer, fvoxelsize, vx, vy, depthbuffer[vx, vy].depth, voxelview);
    pv^ := c
  end
  else
  begin
    fvoxelbuffer[vx, vy, vz] := c;
    pv := nil;
  end;

  fchanged := True;

  // Real time OpenGL preview in small voxel sizes
  if fvoxelsize <= 32 then
    glneedrecalc := True;

  PaintBox1.Canvas.Brush.Style := bsSolid;
  if pv <> nil then
  begin
    cnew := pv^;
    if cnew = 0 then
    begin
      // JVAL: Get next layer in 3d view
      pv2 := vox_getdepthpointerAtXY(fvoxelbuffer, fvoxelsize, vx, vy, voxelview);
      if pv2 <> nil then
        cnew := pv2^;
    end;

    if cnew = 0 then
    begin
      PaintBox1.Canvas.Brush.Color := RGB(64, 64, 64);
      PaintBox1.Canvas.Brush.Style := bsSolid;
      PaintBox1.Canvas.Pen.Color := clBlack;
      PaintBox1.Canvas.Rectangle((X div zoom) * zoom,
                                 (Y div zoom) * zoom,
                                 (X div zoom + 1) * zoom,
                                 (Y div zoom + 1) * zoom);
      PaintBox1.Canvas.Brush.Color := clBlack;
      PaintBox1.Canvas.Brush.Style := bsDiagCross;
    end
    else
    begin
      PaintBox1.Canvas.Brush.Color := cnew;
      PaintBox1.Canvas.Brush.Style := bsSolid;
      PaintBox1.Canvas.Pen.Color := GetGridColor(PaintBox1.Canvas.Brush.Color);
    end;
    PaintBox1.Canvas.Rectangle((X div zoom) * zoom,
                               (Y div zoom) * zoom,
                               (X div zoom + 1) * zoom,
                               (Y div zoom + 1) * zoom);
  end
  else
  begin
    if fvoxelbuffer[vx, vy, vz] = 0 then
    begin
      PaintBox1.Canvas.Brush.Color := RGB(64, 64, 64);
      PaintBox1.Canvas.Brush.Style := bsSolid;
      PaintBox1.Canvas.Pen.Color := clBlack;
      PaintBox1.Canvas.Rectangle((X div zoom) * zoom,
                                 (Y div zoom) * zoom,
                                 (X div zoom + 1) * zoom,
                                 (Y div zoom + 1) * zoom);
      PaintBox1.Canvas.Brush.Color := clBlack;
      PaintBox1.Canvas.Brush.Style := bsDiagCross;
    end
    else
    begin
      PaintBox1.Canvas.Brush.Color := fvoxelbuffer[vx, vy, vz];
      PaintBox1.Canvas.Brush.Style := bsSolid;
      PaintBox1.Canvas.Pen.Color := GetGridColor(PaintBox1.Canvas.Brush.Color);
    end;
    PaintBox1.Canvas.Rectangle((X div zoom) * zoom,
                               (Y div zoom) * zoom,
                               (X div zoom + 1) * zoom,
                               (Y div zoom + 1) * zoom);
  end;
end;

procedure TForm1.PaintBox1FreePaint(X, Y: Integer; prt: paintrespondertype_t);
var
  c: voxelitem_t;
  dx, dy: Double;
  len: integer;
  i: integer;
  ax, ay: integer;
  lastx, lasty: integer;
begin
  if mousedown1 then
    c := drawcolor1
  else if mousedown2 then
    c := drawcolor2
  else
    Exit;

  lastx := paintroverX;
  lasty := paintroverY;
  if (prt = prt_buttondown) or ((paintroverX = -1) or (paintroverY = -1)) then
    DoPaintBox1FreePaint(X, Y, c)
  else
  begin
    len := Round(Sqrt((X - paintroverX) * (X - paintroverX) + (Y - paintroverY) * (Y - paintroverY)));
    if len > 0 then
    begin
      dx := (paintroverX - X) / len;
      dy := (paintroverY - Y) / len;
      for i := 0 to len - 1 do
      begin
        ax := Round(X + dx * i);
        ay := Round(Y + dy * i);
        if (ax <> lastx) or (ay <> lasty) then
        begin
          DoPaintBox1FreePaint(ax, ay, c);
          lastx := ax;
          lasty := ay;
        end;
      end;
      if (X <> lastx) or (Y <> lasty) then
        DoPaintBox1FreePaint(X, Y, c);
    end;
  end;

  if prt = prt_buttonup then
    glneedrecalc := True;
end;

procedure TForm1.DoPaintBox1Elevate(X, Y: Integer; c: voxelitem_t);
var
  vx, vy: integer;
  pv: voxelitem_p;
begin
  if c = 0 then
    Exit;

  if voxelview <> vv_none then
  begin
    vx := X div zoom;
    vy := Y div zoom;
  end
  else
    Exit;

  if vx < 0 then
    vx := 0
  else if vx >= fvoxelsize then
    vx := fvoxelsize - 1;

  if vy < 0 then
    vy := 0
  else if vy >= fvoxelsize then
    vy := fvoxelsize - 1;

  pv := depthbuffer[vx, vy].prev;
  if pv = nil then
    Exit;

  pv^ := c;

  fchanged := True;
  glneedrecalc := True;

  PaintBox1.Canvas.Brush.Color := c;
  PaintBox1.Canvas.Brush.Style := bsSolid;
  PaintBox1.Canvas.Pen.Color := GetGridColor(PaintBox1.Canvas.Brush.Color);

  PaintBox1.Canvas.Rectangle((X div zoom) * zoom,
                             (Y div zoom) * zoom,
                             (X div zoom + 1) * zoom,
                             (Y div zoom + 1) * zoom);
end;

procedure TForm1.PaintBox1Elevate(X, Y: Integer; prt: paintrespondertype_t);
var
  c: voxelitem_t;
  dx, dy: Double;
  len: integer;
  i: integer;
  ax, ay: integer;
  lastx, lasty: integer;
begin
  if mousedown1 then
    c := drawcolor1
  else if mousedown2 then
    c := drawcolor2
  else
    Exit;

  lastx := paintroverX;
  lasty := paintroverY;
  if (prt = prt_buttondown) or ((paintroverX = -1) or (paintroverY = -1)) then
    DoPaintBox1Elevate(X, Y, c)
  else
  begin
    len := Round(Sqrt((X - paintroverX) * (X - paintroverX) + (Y - paintroverY) * (Y - paintroverY)));
    if len > 0 then
    begin
      dx := (paintroverX - X) / len;
      dy := (paintroverY - Y) / len;
      for i := 0 to len - 1 do
      begin
        ax := Round(X + dx * i);
        ay := Round(Y + dy * i);
        if (ax <> lastx) or (ay <> lasty) then
        begin
          DoPaintBox1Elevate(ax, ay, c);
          lastx := ax;
          lasty := ay;
        end;
      end;
      if (X <> lastx) or (Y <> lasty) then
        DoPaintBox1Elevate(X, Y, c);
    end;
  end;
end;

procedure TForm1.PaintBox1FloodFill(X, Y: Integer; prt: paintrespondertype_t);
var
  i, j: integer;
  vx, vy: integer;
  c: voxelitem_t;

  procedure DoFloodFill(const fx, fy: integer);
  begin
    if fx < 0 then
      Exit;
    if fx >= fvoxelsize then
      Exit;
    if fy < 0 then
      Exit;
    if fy >= fvoxelsize then
      Exit;

    if drawbuffer[fx, fy] = c then
    begin
      if mousedown1 then
        drawbuffer[fx, fy] := drawcolor1
      else if mousedown2 then
        drawbuffer[fx, fy] := drawcolor2;

      if (fx - 1 >= 0) and (fx - 1 < fvoxelsize) and (drawbuffer[fx - 1, fy] = c) then
        DoFloodFill(fx - 1, fy);
      if (fx + 1 >= 0) and (fx + 1 < fvoxelsize) and (drawbuffer[fx + 1, fy] = c) then
        DoFloodFill(fx + 1, fy);
      if (fy - 1 >= 0) and (fy - 1 < fvoxelsize) and (drawbuffer[fx, fy - 1] = c) then
        DoFloodFill(fx, fy - 1);
      if (fy + 1 >= 0) and (fy + 1 < fvoxelsize) and (drawbuffer[fx, fy + 1] = c) then
        DoFloodFill(fx, fy + 1);
    end;
  end;

begin
  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        drawbuffer[i, j] := fvoxelbuffer[xpos, i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        drawbuffer[i, j] := fvoxelbuffer[i, ypos, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        drawbuffer[i, j] := fvoxelbuffer[i, j, zpos];
  end
  else if voxelview <> vv_none then
    vox_getviewbuffer(fvoxelbuffer, fvoxelsize, @drawbuffer, voxelview)
  else
    Exit;

  vx := X div zoom;
  vy := Y div zoom;

  if vx < 0 then
    vx := 0
  else if vx >= fvoxelsize then
    vx := fvoxelsize - 1;

  if vy < 0 then
    vy := 0
  else if vy >= fvoxelsize then
    vy := fvoxelsize - 1;

  c := drawbuffer[vx, vy];

  if mousedown1 and (c = drawcolor1) then
    Exit;

  if mousedown2 and (c = drawcolor2) then
    Exit;

  if voxelview = vv_none then
    SaveUndo(0)
  else
    SaveUndo(1);
  Screen.Cursor := crHourglass;
  DoFloodFill(vx, vy);
  Screen.Cursor := crDefault;

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[xpos, i, j] := drawbuffer[i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, ypos, j] := drawbuffer[i, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, j, zpos] := drawbuffer[i, j];
  end
  else if voxelview <> vv_none then
    vox_setviewbuffer(fvoxelbuffer, fvoxelsize, @drawbuffer, voxelview)
  else
    Exit;

  fchanged := True;
  glneedrecalc := True;
  PaintBox1.Invalidate;
end;

procedure TForm1.PaintBox1ColorPicker(X, Y: Integer; prt: paintrespondertype_t);
var
  vx, vy, vz: integer;
  dbitem: depthvoxelitem_t;
begin
  if xpos >= 0 then
  begin
    vx := xpos;
    vy := X div zoom;
    vz := Y div zoom;
  end
  else if ypos >= 0 then
  begin
    vx := X div zoom;
    vy := ypos;
    vz := Y div zoom;
  end
  else if zpos >= 0 then
  begin
    vx := X div zoom;
    vy := Y div zoom;
    vz := zpos
  end
  else if voxelview <> vv_none then
  begin
    vx := X div zoom;
    vy := Y div zoom;
    dbitem := depthbuffer[vx, vy];
//    dbitem := vox_getdepthitemAt(fvoxelbuffer, fvoxelsize, vx, vy, voxelview);
    vz := dbitem.depth;
  end
  else
    Exit;

  if vx < 0 then
    vx := 0
  else if vx >= fvoxelsize then
    vx := fvoxelsize - 1;

  if vy < 0 then
    vy := 0
  else if vy >= fvoxelsize then
    vy := fvoxelsize - 1;

  if vz < 0 then
    vz := 0
  else if vz >= fvoxelsize then
    vz := fvoxelsize - 1;

  if voxelview <> vv_none then
    curpalcolor := dbitem.color
  else
    curpalcolor := fvoxelbuffer[vx, vy, vz];

  if mousedown1 then
    SetDrawColors(curpalcolor, drawcolor2)
  else if mousedown2 then
    SetDrawColors(drawcolor1, curpalcolor);
end;

procedure TForm1.PaintBox1Eraser(X, Y: Integer; prt: paintrespondertype_t);
var
  dx, dy: double;
  len: integer;
  i: integer;
  ax, ay: integer;
  lastx, lasty: integer;
begin
  lastx := paintroverX;
  lasty := paintroverY;
  if (prt = prt_buttondown) or ((paintroverX = -1) or (paintroverY = -1)) then
    DoPaintBox1FreePaint(X, Y, 0)
  else
  begin
    len := Round(Sqrt((X - paintroverX) * (X - paintroverX) + (Y - paintroverY) * (Y - paintroverY)));
    if len > 0 then
    begin
      dx := (paintroverX - X) / len;
      dy := (paintroverY - Y) / len;
      for i := 0 to len - 1 do
      begin
        ax := Round(X + dx * i);
        ay := Round(Y + dy * i);
        if (ax <> lastx) or (ay <> lasty) then
        begin
          DoPaintBox1FreePaint(ax, ay, 0);
          lastx := ax;
          lasty := ay;
        end;
      end;
    end;
    if (X <> lastx) or (Y <> lasty) then
      DoPaintBox1FreePaint(X, Y, 0);
  end;
end;

procedure TForm1.OpenGLPanelResize(Sender: TObject);
begin
  glViewport(0, 0, OpenGLPanel.Width, OpenGLPanel.Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity;                     // Reset View
  gluPerspective(45.0, OpenGLPanel.Width/OpenGLPanel.Height, 1.0, 500.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
  glneedrecalc := True;
end;

var
  hasrender: boolean = False;

{------------------------------------------------------------------}
{  Application onIdle event                                        }
{------------------------------------------------------------------}
procedure TForm1.Idle(Sender: TObject; var Done: Boolean);
var
  i: integer;
  newglHorzPos, newglVertPos: integer;
begin
  newglHorzPos := ScrollBox1.HorzScrollBar.Position;
  newglVertPos := ScrollBox1.VertScrollBar.Position;
  if (newglHorzPos <> lastglHorzPos) or (newglVertPos <> lastglVertPos) then
  begin
    lastglVertPos := newglVertPos;
    lastglHorzPos := newglHorzPos;
    glneedrecalc := True;
  end;

  UpdateEnable;

  hasrender := True;
  Done := False;

  if not glneedrecalc then
    if not glneedrefresh then
    begin
      Sleep(1); // Avoid CPU utilization
      Exit; // jval: We don't need to render :)
    end;

  LastTime := ElapsedTime;
  ElapsedTime := I_GetTime - AppStart;      // Calculate Elapsed Time

  if LastTime = ElapsedTime then
    Exit;

  for i := LastTime to ElapsedTime - 1 do
  begin

  end;

  DoRenderGL;
  UpdateStausbar;
end;


procedure TForm1.DoRenderGL;
var
  i, j: integer;
  depthbuf: depthvoxelbuffer2d_p;
begin
  glBeginScene(OpenGLPanel.Width, OpenGLPanel.Height);
  if glneedrecalc then
  begin
    Screen.Cursor := crHourGlass;

    try
      glDeleteLists(gllist1, 1);
      gllist1 := glGenLists(1);
      glNewList(gllist1, GL_COMPILE);

      if xpos >= 0 then
        glRenderAxes(fvoxelsize, 'x' + IntToStr(xpos))
      else if ypos >= 0 then
        glRenderAxes(fvoxelsize, 'y' + IntToStr(ypos))
      else if zpos >= 0 then
        glRenderAxes(fvoxelsize, 'z' + IntToStr(zpos))
      else if voxelview = vv_top then
        glRenderAxes(fvoxelsize, 'top')
      else if voxelview = vv_down then
        glRenderAxes(fvoxelsize, 'down')
      else if voxelview = vv_left then
        glRenderAxes(fvoxelsize, 'left')
      else if voxelview = vv_right then
        glRenderAxes(fvoxelsize, 'right')
      else if voxelview = vv_front then
        glRenderAxes(fvoxelsize, 'front')
      else if voxelview = vv_back then
        glRenderAxes(fvoxelsize, 'back');
      glEndList;

      glDeleteLists(gllist2, 1);
      gllist2 := glGenLists(1);
      glNewList(gllist2, GL_COMPILE);

      if opt_useglpixels then
        glRenderVoxel_Points(fvoxelsize, fvoxelbuffer, OpenGLPanel.Width)
      else
        glRenderVoxel_Boxes(fvoxelsize, fvoxelbuffer, opt_renderwireframe, true);

      glEndList;

      rendredvoxels := vx_rendredvoxels;

      glDeleteLists(gllist3, 1);
      gllist3 := glGenLists(1);
      glNewList(gllist3, GL_COMPILE);
      if opt_renderglgrid then
        if voxelview <> vv_none then
        begin
          GetMem(depthbuf, SizeOf(depthvoxelbuffer2d_t));
          vox_getdepthviewbuffer(fvoxelbuffer, fvoxelsize, depthbuf, voxelview);
          for i := 0 to fvoxelsize - 1 do
            for j := 0 to fvoxelsize - 1 do
              depthbuf[i, j].color := RGB(255, 255, 0);
          vox_clearbuffer(selectionbuffer, fvoxelsize);
          vox_setdepthviewbuffer(selectionbuffer, fvoxelsize, depthbuf, voxelview, false);
          FreeMem(depthbuf, SizeOf(depthvoxelbuffer2d_t));
          glRenderVoxel_Boxes(fvoxelsize, selectionbuffer, true, false);
        end;
      glEndList;

    finally
      Screen.Cursor := crDefault;
    end;
  end;

  glCallList(gllist1);
  glCallList(gllist2);
  if opt_renderglgrid then
    if voxelview <> vv_none then
      glCallList(gllist3);

  glEndScene(dc);

  glneedrecalc := False;
  glneedrefresh := False;
end;

procedure TForm1.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if Msg.message = WM_KEYDOWN then
  begin
    case Msg.wParam of
      VK_RIGHT: keys[VK_RIGHT] := True;
      VK_LEFT: keys[VK_LEFT] := True;
      VK_UP: keys[VK_UP] := True;
      VK_DOWN: keys[VK_DOWN] := True;
      VK_ADD, Ord('+'): Increaselevel1Click(nil);
    end;
  end;
  if Msg.message = WM_KEYUP then
  begin
    case Msg.wParam of
      VK_RIGHT: keys[VK_RIGHT] := False;
      VK_LEFT: keys[VK_LEFT] := False;
      VK_UP: keys[VK_UP] := False;
      VK_DOWN: keys[VK_DOWN] := False;
      VK_SUBTRACT, Ord('-'): Decreaselevel1Click(nil);
    end;
  end;
end;

procedure TForm1.ApplicationEvents1Idle(Sender: TObject;
  var Done: Boolean);
begin
  Idle(Sender, Done);
end;

procedure TForm1.OpenGLPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button in [mbLeft, mbRight] then
  begin
    glpanx := X;
    glpany := Y;
    if Button = mbLeft then
      glmousedown := 1
    else
      glmousedown := 2;
    SetCapture(OpenGLPanel.Handle);
  end;
end;

procedure TForm1.OpenGLPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  glmousedown := 0;
  ReleaseCapture;
end;

procedure TForm1.OpenGLPanelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if glmousedown = 0 then
    Exit;

  if glmousedown = 1 then
  begin
    camera.ay := camera.ay + (glpanx - X);/// OpenGLPanel.Width {* 2 * pi};
    camera.ax := camera.ax + (glpany - Y); // / OpenGLPanel.Height {* 2 * pi};
  end
  else
  begin
    camera.x := camera.x + (glpanx - X) / OpenGLPanel.Width * (camera.z - 1.0);/// OpenGLPanel.Width {* 2 * pi};
    if camera.x < -6.0 then
      camera.x := -6.0
    else if camera.x > 6.0 then
      camera.x := 6.0;

    camera.y := camera.y - (glpany - Y) / OpenGLPanel.Width * (camera.z - 1.0); // / OpenGLPanel.Height {* 2 * pi};
    if camera.y < -6.0 then
      camera.y := -6.0
    else if camera.y > 6.0 then
      camera.y := 6.0;
  end;

  glneedrefresh := True;

  glpanx := X;
  glpany := Y;

end;

procedure TForm1.OpenGLPanelDblClick(Sender: TObject);
begin
  ResetCamera(axis(xpos, ypos, zpos));
  glneedrefresh := True;
end;

procedure TForm1.Importimage1Click(Sender: TObject);
var
  p: TPicture;
  b: TBitmap;
  i, j: integer;
begin
  if OpenPictureDialog1.Execute then
  begin
    p := TPicture.Create;
    b := TBitmap.Create;
    try
      if voxelview = vv_none then
        SaveUndo(0)
      else
        SaveUndo(1);
      p.LoadFromFile(OpenPictureDialog1.FileName);
      b.PixelFormat := pf32bit;
      b.Width := fvoxelsize;
      b.Height := fvoxelsize;
      if p.Graphic.Width <> 0 then
      begin
        if (p.Graphic.Width = fvoxelsize) and (p.Graphic.Height = fvoxelsize) then
          b.Canvas.Draw(0, 0, p.Graphic)
        else
          b.Canvas.StretchDraw(Rect(0, 0, fvoxelsize, fvoxelsize), p.Graphic);
      end
      else
      begin
        if (p.Bitmap.Width = fvoxelsize) and (p.Bitmap.Height = fvoxelsize) then
          b.Canvas.Draw(0, 0, p.Bitmap)
        else
          b.Canvas.StretchDraw(Rect(0, 0, fvoxelsize, fvoxelsize), p.Bitmap);
      end;
      if xpos >= 0 then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            fvoxelbuffer[xpos, i, j] := b.Canvas.Pixels[i, j];
      end
      else if ypos >= 0 then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            fvoxelbuffer[i, ypos, j] := b.Canvas.Pixels[i, j];
      end
      else if zpos >= 0 then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            fvoxelbuffer[i, j, zpos] := b.Canvas.Pixels[i, j];
      end
      else if voxelview <> vv_none then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            drawbuffer[i, j] := b.Canvas.Pixels[i, j];
        vox_setviewbuffer(fvoxelbuffer, fvoxelsize, @drawbuffer, voxelview)
      end;
      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    finally
      p.Free;
      b.Free;
    end;
  end;
end;

procedure TForm1.RotateLeftButton1Click(Sender: TObject);
var
  b: TBitmap;
  i, j: integer;
  slice2d: voxelbuffer2d_p;
begin
  b := TBitmap.Create;
  b.PixelFormat := pf32bit;
  b.Width := fvoxelsize;
  b.Height := fvoxelsize;

  if voxelview = vv_none then
    SaveUndo(0)
  else
    SaveUndo(1);

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        b.Canvas.Pixels[i, j] := fvoxelbuffer[xpos, i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        b.Canvas.Pixels[i, j] := fvoxelbuffer[i, ypos, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        b.Canvas.Pixels[i, j] := fvoxelbuffer[i, j, zpos];
  end
  else if voxelview <> vv_none then
  begin
    GetMem(slice2d, SizeOf(voxelbuffer2d_t));
    vox_getviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        b.Canvas.Pixels[i, j] := slice2d[i, j];
    FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
  end;

  RotateBitmap90DegreesCounterClockwise(b);

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[xpos, i, j] := b.Canvas.Pixels[i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, ypos, j] := b.Canvas.Pixels[i, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, j, zpos] := b.Canvas.Pixels[i, j];
  end
  else if voxelview <> vv_none then
  begin
    GetMem(slice2d, SizeOf(voxelbuffer2d_t));
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        slice2d[i, j] := b.Canvas.Pixels[i, j];
    vox_setviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
    FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
  end;

  b.Free;

  fchanged := True;
  PaintBox1.Invalidate;
  glneedrecalc := True;
  UpdateDepthBuffer;
end;

procedure TForm1.RotateRightButton1Click(Sender: TObject);
var
  b: TBitmap;
  i, j: integer;
  slice2d: voxelbuffer2d_p;
begin
  b := TBitmap.Create;
  b.PixelFormat := pf32bit;
  b.Width := fvoxelsize;
  b.Height := fvoxelsize;

  if voxelview = vv_none then
    SaveUndo(0)
  else
    SaveUndo(1);

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        b.Canvas.Pixels[i, j] := fvoxelbuffer[xpos, i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        b.Canvas.Pixels[i, j] := fvoxelbuffer[i, ypos, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        b.Canvas.Pixels[i, j] := fvoxelbuffer[i, j, zpos];
  end
  else if voxelview <> vv_none then
  begin
    GetMem(slice2d, SizeOf(voxelbuffer2d_t));
    vox_getviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        b.Canvas.Pixels[i, j] := slice2d[i, j];
    FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
  end;

  RotateBitmap90DegreesClockwise(b);

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[xpos, i, j] := b.Canvas.Pixels[i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, ypos, j] := b.Canvas.Pixels[i, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, j, zpos] := b.Canvas.Pixels[i, j];
  end
  else if voxelview <> vv_none then
  begin
    GetMem(slice2d, SizeOf(voxelbuffer2d_t));
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        slice2d[i, j] := b.Canvas.Pixels[i, j];
    vox_setviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
    FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
  end;

  b.Free;

  PaintBox1.Invalidate;
  fchanged := True;
  UpdateDepthBuffer;
  glneedrecalc := True;
end;

procedure TForm1.Edit1Click(Sender: TObject);
var
  bb: boolean;
begin
  Undo1.Enabled := undoManager.CanUndo;
  Redo1.Enabled := undoManager.CanRedo;
  bb := Clipboard.HasFormat(CF_BITMAP);
  Paste3D1.Enabled := bb;
  Paste1.Enabled := bb;
  PasteFrontView1.Enabled := bb;
  PasteBackView1.Enabled := bb;
  PasteLeftView1.Enabled := bb;
  PasteRightView1.Enabled := bb;
  PasteTopView1.Enabled := bb;
  PasteDownView1.Enabled := bb;
end;

procedure TForm1.Undo1Click(Sender: TObject);
begin
  if undoManager.CanUndo then
  begin
    undoManager.Undo;
    glneedrecalc := True;
    PaintBox1.Invalidate;
  end;
end;

procedure TForm1.Redo1Click(Sender: TObject);
begin
  if undoManager.CanRedo then
  begin
    undoManager.Redo;
    glneedrecalc := True;
    PaintBox1.Invalidate;
  end;
end;

procedure TForm1.DoSaveVoxelBinaryUndo(s: TStream);
type
  save_t = packed record
    x, y, z: byte;
    c: voxelitem_t;
  end;
var
  x, y, z: byte;
  it: voxelitem_t;
  ax: Char;
  buf: array[0..8191] of save_t;
  idx: integer;
begin
  if fsaveundomode = 1 then
  begin
    ax := 'a';
    s.Write(fvoxelsize, SizeOf(fvoxelsize));
    s.Write(ax, SizeOf(ax));

    idx := 0;
    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
        if fvoxelbuffer[x, y, z] <> 0 then
        begin
          buf[idx].x := x;
          buf[idx].y := y;
          buf[idx].z := z;
          buf[idx].c := fvoxelbuffer[x, y, z];
          inc(idx);
          if idx = 8192 then
          begin
            s.Write(buf, SizeOf(buf));
            idx := 0;
          end;
        end;

    if idx > 0 then
      s.Write(buf, idx * SizeOf(save_t));

    buf[0].x := 0;
    buf[0].y := 0;
    buf[0].z := 0;
    buf[0].c := 0;
    s.Write(buf[0], SizeOf(save_t));
  end
  else
  begin
    ax := axis(xpos, ypos, zpos);
    s.Write(fvoxelsize, SizeOf(fvoxelsize));
    s.Write(ax, SizeOf(ax));

    if ax = 'x' then
    begin
      x := xpos;
      s.Write(x, SizeOf(x));
      for y := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            s.Write(y, SizeOf(y));
            s.Write(z, SizeOf(z));
            s.Write(fvoxelbuffer[x, y, z], SizeOf(fvoxelbuffer[x, y, z]));
          end;
    end;

    if ax = 'y' then
    begin
      y := ypos;
      s.Write(y, SizeOf(y));
      for x := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            s.Write(x, SizeOf(x));
            s.Write(z, SizeOf(z));
            s.Write(fvoxelbuffer[x, y, z], SizeOf(fvoxelbuffer[x, y, z]));
          end;
    end;

    if ax = 'z' then
    begin
      z := zpos;
      s.Write(z, SizeOf(z));
      for x := 0 to fvoxelsize - 1 do
        for y := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            s.Write(x, SizeOf(y));
            s.Write(y, SizeOf(y));
            s.Write(fvoxelbuffer[x, y, z], SizeOf(fvoxelbuffer[x, y, z]));
          end;
    end;
    x := 0;
    y := 0;
    s.Write(x, SizeOf(x));
    s.Write(y, SizeOf(y));
    it := 0;
    s.Write(it, SizeOf(it));
  end;

//  s.Write(fvoxelbuffer^, SizeOf(voxelbuffer_t));
end;

procedure TForm1.DoLoadVoxelBinaryUndo(s: TStream);
type
  load_t = packed record
    x, y, z: byte;
    c: voxelitem_t;
  end;
var
  x, y, z: byte;
  it: voxelitem_t;
  ax: Char;
  buf: load_t;
begin
  s.Read(fvoxelsize, SizeOf(fvoxelsize));
  s.Read(ax, SizeOf(ax));

  if ax = 'a' then
  begin
    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
          fvoxelbuffer[x, y, z] := 0;
    while True do
    begin
      s.Read(buf, SizeOf(buf));
      if buf.c <> 0 then
        fvoxelbuffer[buf.x, buf.y, buf.z] := buf.c
      else
        break;
    end;
  end;

  if ax = 'x' then
  begin
    s.Read(x, SizeOf(x));
    for y := 0 to fvoxelsize - 1 do
      for z := 0 to fvoxelsize - 1 do
        fvoxelbuffer[x, y, z] := 0;
    while True do
    begin
      s.Read(y, SizeOf(y));
      s.Read(z, SizeOf(z));
      s.Read(it, SizeOf(it));
      if it <> 0 then
        fvoxelbuffer[x, y, z] := it
      else
        break;
    end;
  end;

  if ax = 'y' then
  begin
    s.Read(y, SizeOf(y));
    for x := 0 to fvoxelsize - 1 do
      for z := 0 to fvoxelsize - 1 do
        fvoxelbuffer[x, y, z] := 0;
    while True do
    begin
      s.Read(x, SizeOf(x));
      s.Read(z, SizeOf(z));
      s.Read(it, SizeOf(it));
      if it <> 0 then
        fvoxelbuffer[x, y, z] := it
      else
        break;
    end;
  end;

  if ax = 'z' then
  begin
    s.Read(z, SizeOf(z));
    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
        fvoxelbuffer[x, y, z] := 0;
    while True do
    begin
      s.Read(x, SizeOf(x));
      s.Read(y, SizeOf(y));
      s.Read(it, SizeOf(it));
      if it <> 0 then
        fvoxelbuffer[x, y, z] := it
      else
        break;
    end;
  end;

//  s.Read(fvoxelbuffer^, SizeOf(voxelbuffer_t));
end;

procedure TForm1.SaveUndo(const mode: integer);
begin
  fsaveundomode := mode;
  undoManager.SaveUndo;
end;

procedure TForm1.SaveUndoEditor;
begin
  SaveUndo(1);
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  glneedrecalc := True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  glneedrecalc := True;
end;

procedure TForm1.UpdateStausbar;
begin
  StatusBar1.Panels[1].Text := Format('Camera(x=%2.2f, y=%2.2f, z=%2.2f)', [camera.x, camera.y, camera.z]);
  StatusBar1.Panels[2].Text := Format('Rendered voxels = %d', [rendredvoxels]);
end;

procedure TForm1.Options1Click(Sender: TObject);
var
  frm: TOptionsForm;
begin
  frm := TOptionsForm.Create(self);
  try
    frm.ShowModal;
    if frm.ModalResult = mrOK then
      glneedrecalc := True;
  finally
    frm.Free;
  end;
end;

procedure TForm1.ExportCurrentLevelAsBitmap1Click(Sender: TObject);
var
  b: TBitmap;
  i, j: integer;
begin
  if SavePictureDialog1.Execute then
  begin
    b := TBitmap.Create;
    try
      b.PixelFormat := pf24bit;
      b.Width := fvoxelsize;
      b.Height := fvoxelsize;

      if xpos >= 0 then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            b.Canvas.Pixels[i, j] := fvoxelbuffer[xpos, i, j];
      end;

      if ypos >= 0 then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            b.Canvas.Pixels[i, j] := fvoxelbuffer[i, ypos, j];
      end;

      if zpos >= 0 then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            b.Canvas.Pixels[i, j] := fvoxelbuffer[i, j, zpos];
      end;

      BackupFile(SavePictureDialog1.FileName);
      b.SaveToFile(SavePictureDialog1.FileName);
    finally
      b.Free;
    end;
  end;
end;

procedure TForm1.KVXVoxel1Click(Sender: TObject);
begin
  if not CheckCanClose then
    Exit;

  if OpenDialog2.Execute then
  begin
    DoLoadKVX(OpenDialog2.FileName);
    ResetCamera(axis(xpos, ypos, zpos));
  end;
end;

procedure TForm1.Importslab6VOX1Click(Sender: TObject);
begin
  if not CheckCanClose then
    Exit;

  if OpenDialog6.Execute then
  begin
    DoLoadVOX(OpenDialog6.FileName);
    ResetCamera(axis(xpos, ypos, zpos));
  end;
end;

procedure TForm1.Optimizedmesh1Click(Sender: TObject);
var
  vmo: TVoxelMeshOptimizer;
begin
  if SaveDialog2.Execute then
  begin
    Screen.Cursor := crHourGlass;
    vmo := TVoxelMeshOptimizer.Create;
    vmo.LoadVoxel(fvoxelsize, fvoxelbuffer);
    vmo.Optimize;
    BackupFile(SaveDialog2.FileName);
    vmo.SaveToFile(SaveDialog2.FileName);
    if vmo.Message <> '' then
      InfoMessage(vmo.Message);
    vmo.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.BatchConvertKVX2DDMESH1Click(Sender: TObject);
var
  i: integer;
  sf, st: string;
  frm: TProgressForm;
begin
  if OpenDialog3.Execute then
  begin
    Screen.Cursor := crHourGlass;
    frm := TProgressForm.Create(nil);
    try
      frm.ProgressBar1.Max := OpenDialog3.Files.Count;
      frm.ProgressBar1.Position := 0;
      frm.Show;
      for i := 0 to OpenDialog3.Files.Count - 1 do
      begin
        frm.BringToFront;
        sf := OpenDialog3.Files.Strings[i];
        frm.Label1.Caption := 'Converting ' + MkShortName(sf);
        frm.Refresh;
        st := ChangeFileExt(sf, '.ddmesh');
        BackupFile(st);
        ConvertKVF2DDMESH(sf, st);
        frm.ProgressBar1.Position := frm.ProgressBar1.Position + 1;
        frm.Refresh;
      end;
    finally
      frm.Free;
    end;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.BatchConvertDDVOX2DDMESH1Click(Sender: TObject);
var
  i: integer;
  sf, st: string;
  frm: TProgressForm;
begin
  if OpenDialog4.Execute then
  begin
    Screen.Cursor := crHourGlass;
    frm := TProgressForm.Create(nil);
    try
      frm.ProgressBar1.Max := OpenDialog4.Files.Count;
      frm.ProgressBar1.Position := 0;
      frm.Show;
      for i := 0 to OpenDialog4.Files.Count - 1 do
      begin
        frm.BringToFront;
        sf := OpenDialog4.Files.Strings[i];
        frm.Label1.Caption := 'Converting ' + MkShortName(sf);
        frm.Refresh;
        st := ChangeFileExt(sf, '.ddmesh');
        BackupFile(st);
        ConvertDDVOX2DDMESH(sf, st);
        frm.ProgressBar1.Position := frm.ProgressBar1.Position + 1;
        frm.Refresh;
      end;
    finally
      frm.Free;
    end;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.DDMESH1Click(Sender: TObject);
begin
  if not CheckCanClose then
    Exit;

  if OpenDialog5.Execute then
  begin
    DoLoadDDMESH(OpenDialog5.FileName);
    ResetCamera(axis(xpos, ypos, zpos));
  end;
end;

function TForm1.DoLoadHeightmap(const fname: string): boolean;
var
  xsiz, ysiz: integer;
  size: integer;
  p: TPicture;
  b: TBitmap;
  i, j, k: integer;
  hmap: array[0..255, 0..255] of integer;
  vmap: array[0..255, 0..255] of integer;
  s: string;
  c: LongWord;
  fscale1: Extended;
begin
  if not FileExists(fname) then
  begin
    s := Format('File %s does not exist!', [MkShortName(fname)]);
    ErrorMessage(s);
    Result := False;
    Exit;
  end;

  Screen.Cursor := crHourglass;
  p := TPicture.Create;
  b := TBitmap.Create;

  try
    p.LoadFromFile(OpenPictureDialog1.FileName);

    xsiz := p.Graphic.Width;
    ysiz := p.Graphic.Height;

    size := 1;
    while xsiz > size do
      size := size * 2;
    while ysiz > size do
      size := size * 2;

    if size > 256 then
      size := 256;

    DoNewVoxel(size);

    b.Width := fvoxelsize;
    b.Height := fvoxelsize;
    b.PixelFormat := pf32bit;
    b.Canvas.StretchDraw(Rect(0, 0, fvoxelsize, fvoxelsize), p.Graphic);
    FlipBitmapVertically(b);

    if fvoxelsize = 256 then
    begin
      for i := 0 to 255 do
        for j := 0 to 255 do
        begin
          k := GetGray256Color(b.Canvas.Pixels[i, j]);
          hmap[i, j] := k;
          vmap[i, j] := k;
        end;
    end
    else
    begin
      fscale1 := fvoxelsize / 256;
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
        begin
          k := GetGray256Color(b.Canvas.Pixels[i, j]);
          hmap[i, j] := k;
          vmap[i, j] := round(k * fscale1);
          if vmap[i, j] >= fvoxelsize then
            vmap[i, j] := fvoxelsize - 1
          else if vmap[i, j] < 0 then
            vmap[i, j] := 0;
        end;
    end;

    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
      begin
        c := RGB(hmap[i, j], hmap[i, j], hmap[i, j]);
          if c = 0 then
            c := $1;
        for k := 0 to vmap[i, j] do
          fvoxelbuffer[i, fvoxelsize - k - 1, j] := c
      end;

    vox_removenonvisiblecells(fvoxelbuffer, fvoxelsize);

    fchanged := True;
    UpdateDepthBuffer;

  finally
    p.Free;
    b.Free;
    Screen.Cursor := crDefault;
  end;

  PaintBox1.Invalidate;
  glneedrecalc := True;
  Result := True;
end;


procedure TForm1.Heightmap1Click(Sender: TObject);
begin
  if not CheckCanClose then
    Exit;

  if OpenPictureDialog1.Execute then
  begin
    DoLoadHeightmap(OpenPictureDialog1.FileName);
    ResetCamera(axis(xpos, ypos, zpos));
  end;
end;

procedure TForm1.ApplyTerrainTexture11Click(Sender: TObject);
var
  p: TPicture;
  b: TBitmap;
  i, j, k: integer;
begin
  if OpenPictureDialog2.Execute then
  begin
    p := TPicture.Create;
    b := TBitmap.Create;
    Screen.Cursor := crHourglass;
    try
      SaveUndo(1);
      p.LoadFromFile(OpenPictureDialog2.FileName);
      b.Width := fvoxelsize;
      b.Height := fvoxelsize;
      b.PixelFormat := pf32bit;
      b.Canvas.StretchDraw(Rect(0, 0, fvoxelsize, fvoxelsize), p.Graphic);
      FlipBitmapVertically(b);
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
          for k := 0 to fvoxelsize - 1 do
            if fvoxelbuffer[i, k, j] <> 0 then
            begin
              fvoxelbuffer[i, k, j] := b.Canvas.Pixels[i, j];
              if fvoxelbuffer[i, k, j] = 0 then
                fvoxelbuffer[i, k, j] := $1;
            end;
      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    finally
      p.Free;
      b.Free;
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TForm1.Copy1Click(Sender: TObject);
var
  b: TBitmap;
  i, j: integer;
  slice2d: voxelbuffer2d_p;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    if voxelview = vv_none then
    begin
      if xpos >= 0 then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            b.Canvas.Pixels[i, j] := fvoxelbuffer[xpos, i, j];
      end;

      if ypos >= 0 then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            b.Canvas.Pixels[i, j] := fvoxelbuffer[i, ypos, j];
      end;

      if zpos >= 0 then
      begin
        for i := 0 to fvoxelsize - 1 do
          for j := 0 to fvoxelsize - 1 do
            b.Canvas.Pixels[i, j] := fvoxelbuffer[i, j, zpos];
      end;
    end
    else
    begin
      GetMem(slice2d, SizeOf(voxelbuffer2d_t));
      vox_getviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
          b.Canvas.Pixels[i, j] := slice2d[i, j];
      FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
    end;

    Clipboard.Assign(b);

  finally
    b.Free;
  end;
end;

procedure TForm1.Paste1Click(Sender: TObject);
var
  b: TBitmap;
  i, j: integer;
  tempBitmap: TBitmap;
  slice2d: voxelbuffer2d_p;
begin
  // if there is an image on clipboard
  if Clipboard.HasFormat(CF_BITMAP) then
  begin
    if voxelview = vv_none then
      SaveUndo(0)
    else
      SaveUndo(1);

    tempBitmap := TBitmap.Create;
    tempBitmap.PixelFormat := pf24bit;

    tempBitmap.LoadFromClipboardFormat(CF_BITMAP, ClipBoard.GetAsHandle(cf_Bitmap), 0);

    b := TBitmap.Create;
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    if (tempBitmap.Width = fvoxelsize) and (tempBitmap.Height = fvoxelsize) then
      b.Canvas.Draw(0, 0, tempBitmap)
    else
      b.Canvas.StretchDraw(Rect(0, 0, fvoxelsize, fvoxelsize), tempBitmap);

    tempBitmap.Free;

    if xpos >= 0 then
    begin
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
          fvoxelbuffer[xpos, i, j] := b.Canvas.Pixels[i, j];
    end
    else if ypos >= 0 then
    begin
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
          fvoxelbuffer[i, ypos, j] := b.Canvas.Pixels[i, j];
    end
    else if zpos >= 0 then
    begin
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
          fvoxelbuffer[i, j, zpos] := b.Canvas.Pixels[i, j];
    end
    else if voxelview <> vv_none then
    begin
      GetMem(slice2d, SizeOf(voxelbuffer2d_t));
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
          slice2d[i, j] := b.Canvas.Pixels[i, j];
      vox_setviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
      FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
    end;
    b.Free;
    fchanged := True;
    glneedrecalc := True;
    UpdateDepthBuffer;
    PaintBox1.Invalidate;
  end;

end;

procedure TForm1.UpdateEnable;
begin
  Undo1.Enabled := undoManager.CanUndo;
  Redo1.Enabled := undoManager.CanRedo;
  UndoButton1.Enabled := undoManager.CanUndo;
  RedoButton1.Enabled := undoManager.CanRedo;
  GridButton1.Down := opt_renderglgrid;
  ShowScriptButton1.Down := EditorForm.Visible;
end;

procedure TForm1.UpdateDepthBuffer;
begin
  vox_getdepthviewbuffer(fvoxelbuffer, fvoxelsize, @depthbuffer, voxelview);
end;

procedure TForm1.FlipHorzButton1Click(Sender: TObject);
var
  i, j: integer;
  fPixels: voxelbuffer2d_t;
  c: voxelitem_t;
begin
  if voxelview = vv_none then
    SaveUndo(0)
  else
    SaveUndo(1);

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fPixels[i, j] := fvoxelbuffer[xpos, i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fPixels[i, j] := fvoxelbuffer[i, ypos, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fPixels[i, j] := fvoxelbuffer[i, j, zpos];
  end
  else if voxelview <> vv_none then
  begin
    vox_getviewbuffer(fvoxelbuffer, fvoxelsize, @fPixels, voxelview);
  end;

  for i := 0 to (fvoxelsize div 2) - 1 do
    for j := 0 to fvoxelsize - 1 do
    begin
      c := fPixels[fvoxelsize - i - 1, j];
      fPixels[fvoxelsize - i - 1, j] := fPixels[i, j];
      fPixels[i, j] := c;
    end;

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[xpos, i, j] := fPixels[i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, ypos, j] := fPixels[i, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, j, zpos] := fPixels[i, j];
  end
  else if voxelview <> vv_none then
  begin
    vox_setviewbuffer(fvoxelbuffer, fvoxelsize, @fpixels, voxelview);
  end;

  PaintBox1.Invalidate;
  fchanged := True;
  glneedrecalc := True;
  UpdateDepthBuffer;
end;

procedure TForm1.FlipVertButton1Click(Sender: TObject);
var
  i, j: integer;
  fPixels: voxelbuffer2d_t;
  c: voxelitem_t;
begin
  if voxelview = vv_none then
    SaveUndo(0)
  else
    SaveUndo(1);

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fPixels[i, j] := fvoxelbuffer[xpos, i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fPixels[i, j] := fvoxelbuffer[i, ypos, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fPixels[i, j] := fvoxelbuffer[i, j, zpos];
  end
  else if voxelview <> vv_none then
  begin
    vox_getviewbuffer(fvoxelbuffer, fvoxelsize, @fpixels, voxelview);
  end;

  for i := 0 to fvoxelsize - 1 do
    for j := 0 to (fvoxelsize div 2) - 1 do
    begin
      c := fPixels[i, fvoxelsize - j - 1];
      fPixels[i, fvoxelsize - j - 1] := fPixels[i, j];
      fPixels[i, j] := c;
    end;

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[xpos, i, j] := fPixels[i, j];
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, ypos, j] := fPixels[i, j];
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, j, zpos] := fPixels[i, j];
  end
  else if voxelview <> vv_none then
  begin
    vox_setviewbuffer(fvoxelbuffer, fvoxelsize, @fPixels, voxelview);
  end;

  PaintBox1.Invalidate;
  fchanged := True;
  glneedrecalc := True;
  UpdateDepthBuffer;
end;

procedure TForm1.Removenonvisiblevoxels1Click(Sender: TObject);
begin
  SaveUndo(1);
  Screen.Cursor := crHourglass;
  vox_removenonvisiblecells(fvoxelbuffer, fvoxelsize);
  Screen.Cursor := crDefault;

  PaintBox1.Invalidate;
  fchanged := True;
  glneedrecalc := True;
  UpdateDepthBuffer;
  UpdateStausbar;
end;

procedure TForm1.ExportFrontViewAsBitmap1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for z := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[x, y] := c;
      end;

    Screen.Cursor := crDefault;

    if PreviewBitmapForSaving('Export Front View', b) then
      if SavePictureDialog2.Execute then
      begin
        BackupFile(SavePictureDialog2.FileName);
        b.SaveToFile(SavePictureDialog2.FileName);
      end;
  finally
    b.Free;
  end;
end;

procedure TForm1.Splitter1Moved(Sender: TObject);
begin
  glneedrecalc := True;
end;

procedure TForm1.Cut1Click(Sender: TObject);
var
  b: TBitmap;
  i, j: integer;
  slice2d: voxelbuffer2d_p;
begin
  if voxelview = vv_none then
    SaveUndo(0)
  else
    SaveUndo(1);

  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    if xpos >= 0 then
    begin
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
        begin
          b.Canvas.Pixels[i, j] := fvoxelbuffer[xpos, i, j];
          fvoxelbuffer[xpos, i, j] := 0;
        end;
    end
    else if ypos >= 0 then
    begin
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
        begin
          b.Canvas.Pixels[i, j] := fvoxelbuffer[i, ypos, j];
          fvoxelbuffer[i, ypos, j] := 0;
        end;
    end
    else if zpos >= 0 then
    begin
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
        begin
          b.Canvas.Pixels[i, j] := fvoxelbuffer[i, j, zpos];
          fvoxelbuffer[i, j, zpos] := 0;
        end;
    end
    else if voxelview <> vv_none then
    begin
      GetMem(slice2d, SizeOf(voxelbuffer2d_t));
      vox_getviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
      for i := 0 to fvoxelsize - 1 do
        for j := 0 to fvoxelsize - 1 do
        begin
          b.Canvas.Pixels[i, j] := slice2d[i, j];
          slice2d[i, j] := 0;
        end;
      vox_setviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
      FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
    end;

    Clipboard.Assign(b);

    PaintBox1.Invalidate;
    glneedrecalc := True;
    fchanged := true;
    UpdateDepthBuffer;
  finally
    b.Free;
  end;

end;

procedure TForm1.Clear1Click(Sender: TObject);
var
  i, j: integer;
  slice2d: voxelbuffer2d_p;
begin
  if voxelview = vv_none then
    SaveUndo(0)
  else
    SaveUndo(1);

  if xpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
          fvoxelbuffer[xpos, i, j] := 0;
  end
  else if ypos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, ypos, j] := 0;
  end
  else if zpos >= 0 then
  begin
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        fvoxelbuffer[i, j, zpos] := 0;
  end
  else if voxelview <> vv_none then
  begin
    GetMem(slice2d, SizeOf(voxelbuffer2d_t));
    for i := 0 to fvoxelsize - 1 do
      for j := 0 to fvoxelsize - 1 do
        slice2d[i, j] := 0;
    vox_setviewbuffer(fvoxelbuffer, fvoxelsize, slice2d, voxelview);
    FreeMem(slice2d, SizeOf(voxelbuffer2d_t));
  end;

  PaintBox1.Invalidate;
  glneedrecalc := True;
  fchanged := true;
  UpdateDepthBuffer;
end;

procedure TForm1.ExportBackViewAsBitmap1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for z := fvoxelsize - 1 downto 0 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[x, y] := c;
      end;

    Screen.Cursor := crDefault;

    if PreviewBitmapForSaving('Export Back View', b) then
      if SavePictureDialog2.Execute then
      begin
        BackupFile(SavePictureDialog2.FileName);
        b.SaveToFile(SavePictureDialog2.FileName);
      end;
  finally
    b.Free;
  end;
end;

procedure TForm1.ExportLeftViewAsBitmap1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for z := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for x := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[fvoxelsize - 1 - z, y] := c;
      end;

    Screen.Cursor := crDefault;

    if PreviewBitmapForSaving('Export Left View', b) then
      if SavePictureDialog2.Execute then
      begin
        BackupFile(SavePictureDialog2.FileName);
        b.SaveToFile(SavePictureDialog2.FileName);
      end;
  finally
    b.Free;
  end;
end;

procedure TForm1.ExportRightViewAsBitmap1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for z := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for x := fvoxelsize - 1 downto 0 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[z, y] := c;
      end;

    Screen.Cursor := crDefault;

    if PreviewBitmapForSaving('Export Right View', b) then
      if SavePictureDialog2.Execute then
      begin
        BackupFile(SavePictureDialog2.FileName);
        b.SaveToFile(SavePictureDialog2.FileName);
      end;
  finally
    b.Free;
  end;
end;

procedure TForm1.ExportTopViewAsBitmap1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for z := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for y := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[x, fvoxelsize - 1 - z] := c;
      end;

    Screen.Cursor := crDefault;

    if PreviewBitmapForSaving('Export Top View', b) then
      if SavePictureDialog2.Execute then
      begin
        BackupFile(SavePictureDialog2.FileName);
        b.SaveToFile(SavePictureDialog2.FileName);
      end;
  finally
    b.Free;
  end;
end;

procedure TForm1.ExportDownViewAsBiitmap1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for z := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for y := fvoxelsize - 1 downto 0 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[x, z] := c;
      end;

    Screen.Cursor := crDefault;

    if PreviewBitmapForSaving('Export Bottom View', b) then
      if SavePictureDialog2.Execute then
      begin
        BackupFile(SavePictureDialog2.FileName);
        b.SaveToFile(SavePictureDialog2.FileName);
      end;
  finally
    b.Free;
  end;
end;

procedure TForm1.CopyFrontView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for z := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[x, y] := c;
      end;

    Clipboard.Assign(b);
    
    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.CopyBackView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for z := fvoxelsize - 1 downto 0 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[fvoxelsize - 1 - x, y] := c;
      end;

    Clipboard.Assign(b);
    
    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.CopyLeftView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for z := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for x := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[fvoxelsize - 1 - z, y] := c;
      end;

    Clipboard.Assign(b);
    
    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.CopyRightView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for z := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for x := fvoxelsize - 1 downto 0 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[z, y] := c;
      end;

    Clipboard.Assign(b);

    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.CopyTopView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for z := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for y := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[x, fvoxelsize - 1 - z] := c;
      end;

    Clipboard.Assign(b);
    
    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.CopyDownView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf24bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for z := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for y := fvoxelsize - 1 downto 0 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[x, z] := c;
      end;

    Clipboard.Assign(b);

    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.PasteFrontView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  if not Clipboard.HasFormat(CF_BITMAP) then
    Exit;

  b := TBitmap.Create;
  try
    b.PixelFormat := pf32bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    if StretchClipboardToBitmap(b) then
    begin
      SaveUndo(1);

      for x := 0 to fvoxelsize - 1 do
        for y := 0 to fvoxelsize - 1 do
          for z := 0 to fvoxelsize - 1 do
            if fvoxelbuffer[x, y, z] <> 0 then
            begin
              c := b.Canvas.Pixels[x, y];
              if c <> 0 then
                fvoxelbuffer[x, y, z] := c
              else
                fvoxelbuffer[x, y, z] := $1;
              Break;
            end;

      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;

    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.PasteBackView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  if not Clipboard.HasFormat(CF_BITMAP) then
    Exit;

  b := TBitmap.Create;
  try
    b.PixelFormat := pf32bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    if StretchClipboardToBitmap(b) then
    begin
      SaveUndo(1);

      for x := 0 to fvoxelsize - 1 do
        for y := 0 to fvoxelsize - 1 do
          for z := fvoxelsize - 1 downto 0 do
            if fvoxelbuffer[x, y, z] <> 0 then
            begin
              c := b.Canvas.Pixels[fvoxelsize - 1 - x, y];
              if c <> 0 then
                fvoxelbuffer[x, y, z] := c
              else
                fvoxelbuffer[x, y, z] := $1;
              Break;
            end;

      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;

    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.PasteLeftView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  if not Clipboard.HasFormat(CF_BITMAP) then
    Exit;

  b := TBitmap.Create;
  try
    b.PixelFormat := pf32bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    if StretchClipboardToBitmap(b) then
    begin
      SaveUndo(1);

      for z := 0 to fvoxelsize - 1 do
        for y := 0 to fvoxelsize - 1 do
          for x := 0 to fvoxelsize - 1 do
            if fvoxelbuffer[x, y, z] <> 0 then
            begin
              c := b.Canvas.Pixels[fvoxelsize - 1 - z, y];
              if c <> 0 then
                fvoxelbuffer[x, y, z] := c
              else
                fvoxelbuffer[x, y, z] := $1;
              Break;
            end;

      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;

    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.PasteRightView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  if not Clipboard.HasFormat(CF_BITMAP) then
    Exit;

  b := TBitmap.Create;
  try
    b.PixelFormat := pf32bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    if StretchClipboardToBitmap(b) then
    begin
      SaveUndo(1);

      for z := 0 to fvoxelsize - 1 do
        for y := 0 to fvoxelsize - 1 do
          for x := fvoxelsize - 1 downto 0 do
            if fvoxelbuffer[x, y, z] <> 0 then
            begin
              c := b.Canvas.Pixels[z, y];
              if c <> 0 then
                fvoxelbuffer[x, y, z] := c
              else
                fvoxelbuffer[x, y, z] := $1;
              Break;
            end;

      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;

    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.PasteTopView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  if not Clipboard.HasFormat(CF_BITMAP) then
    Exit;

  b := TBitmap.Create;
  try
    b.PixelFormat := pf32bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    if StretchClipboardToBitmap(b) then
    begin
      SaveUndo(1);

      for x := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
          for y := 0 to fvoxelsize - 1 do
            if fvoxelbuffer[x, y, z] <> 0 then
            begin
              c := b.Canvas.Pixels[x, fvoxelsize - 1 - z];
              if c <> 0 then
                fvoxelbuffer[x, y, z] := c
              else
                fvoxelbuffer[x, y, z] := $1;
              Break;
            end;

      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;

    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.PasteDownView1Click(Sender: TObject);
var
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  if not Clipboard.HasFormat(CF_BITMAP) then
    Exit;

  b := TBitmap.Create;
  try
    b.PixelFormat := pf32bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    if StretchClipboardToBitmap(b) then
    begin
      SaveUndo(1);

      for x := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
          for y := fvoxelsize - 1 downto 0 do
            if fvoxelbuffer[x, y, z] <> 0 then
            begin
              c := b.Canvas.Pixels[x, z];
              if c <> 0 then
                fvoxelbuffer[x, y, z] := c
              else
                fvoxelbuffer[x, y, z] := $1;
              Break;
            end;

      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;

    Screen.Cursor := crDefault;
  finally
    b.Free;
  end;
end;

procedure TForm1.Paste3D1Click(Sender: TObject);
var
  hb: boolean;
begin
  hb := Clipboard.HasFormat(CF_BITMAP);
  PasteFrontView1.Enabled := hb;
  PasteBackView1.Enabled := hb;
  PasteLeftView1.Enabled := hb;
  PasteRightView1.Enabled := hb;
  PasteTopView1.Enabled := hb;
  PasteDownView1.Enabled := hb;
end;

procedure TForm1.GridButton1Click(Sender: TObject);
begin
  opt_renderglgrid := not opt_renderglgrid;
  GridButton1.Down := opt_renderglgrid;
  glneedrecalc := True;
end;

procedure TForm1.SrinkHeightmap1Click(Sender: TObject);
var
  hmin, hmax: integer;
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf32bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for z := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[x, y] := c;
      end;

    Screen.Cursor := crDefault;

    hmin := 0;
    hmax := 255;
    if SrinkHeightmapGetInfo(hmin, hmax, b) then
    begin
      Screen.Cursor := crHourGlass;
      SaveUndo(1);
      vox_shrinkyaxis(fvoxelbuffer, fvoxelsize, hmin, hmax);
      Screen.Cursor := crDefault;
      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;
  finally
    b.Free;
  end;
end;

procedure TForm1.CropHeightmap1Click(Sender: TObject);
var
  hmin, hmax: integer;
  x, y, z: integer;
  b: TBitmap;
  c: voxelitem_t;
begin
  b := TBitmap.Create;
  try
    b.PixelFormat := pf32bit;
    b.Width := fvoxelsize;
    b.Height := fvoxelsize;

    Screen.Cursor := crHourGlass;

    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
      begin
        c := 0;
        for z := 0 to fvoxelsize - 1 do
          if fvoxelbuffer[x, y, z] <> 0 then
          begin
            c := fvoxelbuffer[x, y, z];
            Break;
          end;
        b.Canvas.Pixels[x, y] := c;
      end;

    Screen.Cursor := crDefault;

    hmin := 0;
    hmax := 255;
    if CropHeightmapGetInfo(hmin, hmax, b) then
    begin
      Screen.Cursor := crHourGlass;
      SaveUndo(1);
      vox_cropyaxis(fvoxelbuffer, fvoxelsize, hmin, hmax);
      Screen.Cursor := crDefault;
      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;
  finally
    b.Free;
  end;
end;

procedure TForm1.File1Click(Sender: TObject);
begin
  filemenuhistory.RefreshMenuItems;
end;

procedure TForm1.Get3dPreviewBitmap(const b: TBitmap);
type
  long_a = array[0..$FFFF] of LongWord;
  Plong_a = ^long_a;
var
  L, buf: Plong_a;
  w, h: integer;
  i, j: integer;
  idx: integer;
begin
  w := OpenGLPanel.Width;
  h := OpenGLPanel.Height;
  b.Width := w;
  b.Height := h;
  b.PixelFormat := pf32bit;

  GetMem(L, w * h * SizeOf(LongWord));
  glReadPixels(0, 0, w, h, GL_BGRA, GL_UNSIGNED_BYTE, L);

  idx := 0;
  for j := 0 to h - 1 do
  begin
    buf := b.ScanLine[h - j - 1];
    for i := 0 to w - 1 do
    begin
      buf[i] := L[idx];
      Inc(idx);
    end;
  end;

  FreeMem(L, w * h * SizeOf(LongWord));
end;

procedure TForm1.Copy3dButtonClick(Sender: TObject);
var
  b: TBitmap;
begin
  b := TBitmap.Create;
  try
    DoRenderGL; // JVAL: For some unknown reason this must be called before glReadPixels
    Get3dPreviewBitmap(b);
    Clipboard.Assign(b);
  finally
    b.Free;
  end;
end;

procedure TForm1.Save3dButtonClick(Sender: TObject);
var
  b: TBitmap;
begin
  if SavePictureDialog3.Execute then
  begin
    b := TBitmap.Create;
    try
      DoRenderGL; // JVAL: For some unknown reason this must be called before glReadPixels
      Get3dPreviewBitmap(b);
      b.SaveToFile(SavePictureDialog3.FileName);
    finally
      b.Free;
    end;
  end;
end;

procedure TForm1.Rotate1Click(Sender: TObject);
var
  tmpbuffer: voxelbuffer_p;
  x, y, z: integer;
begin
  if GetRotationInput(thetarotatey) then
  begin
    SaveUndo(1);
    Screen.Cursor := crHourglass;

    tmpbuffer := vox_getbuffer;
    VXE_RotateVoxelBuffer(fvoxelbuffer, fvoxelsize, thetarotatey / 360 * (2 * pi), tmpbuffer);
    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
          fvoxelbuffer[x, y, z] := tmpbuffer[x, y, z];
    vox_freebuffer(tmpbuffer);

    vox_removenonvisiblecells(fvoxelbuffer, fvoxelsize);
    Screen.Cursor := crDefault;

    PaintBox1.Invalidate;
    fchanged := True;
    glneedrecalc := True;
    UpdateDepthBuffer;
    UpdateStausbar;
  end;
end;

procedure TForm1.RotateHighQuality1Click(Sender: TObject);
var
  tmpbuffer: voxelbuffer_p;
  x, y, z: integer;
begin
  if GetRotationInput(thetarotatey) then
  begin
    SaveUndo(1);
    Screen.Cursor := crHourglass;

    tmpbuffer := vox_getbuffer;
    VXE_RotateVoxelBufferHQ(fvoxelbuffer, fvoxelsize, thetarotatey / 360 * (2 * pi), tmpbuffer);
    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
          fvoxelbuffer[x, y, z] := tmpbuffer[x, y, z];
    vox_freebuffer(tmpbuffer);

    vox_removenonvisiblecells(fvoxelbuffer, fvoxelsize);
    Screen.Cursor := crDefault;

    PaintBox1.Invalidate;
    fchanged := True;
    glneedrecalc := True;
    UpdateDepthBuffer;
    UpdateStausbar;
  end;
end;

procedure TForm1.Sprite1Click(Sender: TObject);
begin
  if GetExportSpriteInfo(fvoxelbuffer, fvoxelsize, spritefilename, spriteprefix,
    spritesavetype, spriteangles, spritequality, spriteformat, spritesavepalette,
    spritesaveperspective, spriteviewheight, spritedistance) then
  begin
    Screen.Cursor := crHourGlass;
    try
      if spritesaveperspective then
      begin
        if spriteangles = 1 then
          VXE_ExportVoxelToSpritePerspective1(
            fvoxelbuffer, fvoxelsize, spritefilename, spritesavetype, spritequality,
            spriteformat, spriteprefix, spritesavepalette, spritedistance, spriteviewheight)
        else
          VXE_ExportVoxelToSpritePerspective(
            fvoxelbuffer, fvoxelsize, spritefilename, spritesavetype, spritequality,
            spriteformat, spriteprefix, spritesavepalette, spriteangles, spritedistance, spriteviewheight);
      end
      else
      begin 
        case spriteangles of
          1: VXE_ExportVoxelToSprite1(fvoxelbuffer, fvoxelsize, spritefilename, spritesavetype, spritequality, spriteformat, spriteprefix, spritesavepalette);
          8: VXE_ExportVoxelToSprite8(fvoxelbuffer, fvoxelsize, spritefilename, spritesavetype, spritequality, spriteformat, spriteprefix, spritesavepalette);
         16: VXE_ExportVoxelToSprite16(fvoxelbuffer, fvoxelsize, spritefilename, spritesavetype, spritequality, spriteformat, spriteprefix, spritesavepalette);
         32: VXE_ExportVoxelToSprite32(fvoxelbuffer, fvoxelsize, spritefilename, spritesavetype, spritequality, spriteformat, spriteprefix, spritesavepalette);
        end;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TForm1.ShowScriptButton1Click(Sender: TObject);
begin
  EditorForm.Visible := not EditorForm.Visible;
  ShowScriptButton1.Down := EditorForm.Visible;
end;

procedure TForm1.Load1Click(Sender: TObject);
begin
  EditorForm.Visible := True;
  ShowScriptButton1.Down := True;
  EditorForm.OpenScriptButton1Click(Sender);
end;

procedure TForm1.Compile1Click(Sender: TObject);
begin
  EditorForm.Visible := True;
  ShowScriptButton1.Down := True;
  EditorForm.CompileButton1Click(Sender);
end;

procedure TForm1.Run1Click(Sender: TObject);
begin
  EditorForm.Visible := True;
  ShowScriptButton1.Down := True;
  EditorForm.CompileAndRunButton1Click(Sender);
end;

procedure TForm1.Script1Click(Sender: TObject);
begin
  ScriptEditor1.Checked := EditorForm.Visible;
end;

procedure TForm1.ScriptEditor1Click(Sender: TObject);
begin
  EditorForm.Visible := not EditorForm.Visible;
  ShowScriptButton1.Down := EditorForm.Visible;
end;

procedure TForm1.Exportslab6VOX1Click(Sender: TObject);
begin
  if SaveDialog3.Execute then
  begin
    Screen.Cursor := crHourGlass;
    BackupFile(SaveDialog3.FileName);
    try
      VXE_ExportVoxelToSlab6VOX(fvoxelbuffer, fvoxelsize, SaveDialog3.FileName);
    except
      InfoMessage(Format('Can not save file %s', [SaveDialog3.FileName]));
    end;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.Countcolorsused1Click(Sender: TObject);
var
  A: array[0..255] of TDNumberList;
  x, y, z: integer;
  c: LongWord;
  r: byte;
  tot: integer;
begin
  Screen.Cursor := crHourGlass;
  try
    for x := 0 to 255 do
      A[x] := TDNumberList.Create;
    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
        begin
          c := fvoxelbuffer[x, y, z];
          if c <> 0 then
          begin
            r := GetRValue(c);
            if A[r].IndexOf(c) < 0 then
              A[r].Add(c);
          end;
        end;
    tot := 0;
    for x := 0 to 255 do
    begin
      tot := tot + A[x].Count;
      A[x].Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
  InfoMessage(Format('The number of unique colors is %d', [tot]));
end;

procedure TForm1.Greyscale1Click(Sender: TObject);
var
  x, y, z: integer;
  c, cn: LongWord;
  r, g, b: byte;
  grey: integer;
  cchanged: boolean;
  pal: TPaletteArray;
begin
  Screen.Cursor := crHourGlass;
  try
    cchanged := False;
    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
        begin
          c := fvoxelbuffer[x, y, z];
          if c <> 0 then
          begin
            r := GetRValue(c);
            g := GetRValue(c);
            b := GetRValue(c);
            grey := GetIntegerInRange(Round(0.3 * r + 0.59 * g + 0.11 * b), 0, 255);
            if grey = 0 then
              grey := 1;
            cn := RGB(grey, grey, grey);
            if cn <> c then
            begin
              if not cchanged then
              begin
                cchanged := True;
                SaveUndo(1);
              end;
              fvoxelbuffer[x, y, z] := cn;
            end;
          end;
        end;

    for x := 0 to 255 do
      pal[x] := RGB(x, x, x);
    UpdatePaletteBitmap(pal);
    
    if cchanged then
    begin
      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.Convertto256colorspalette1Click(Sender: TObject);
var
  ans: integer;
  pname: string;
  rpal: pointer;
  pal: TPaletteArray;
  x, y, z: integer;
  cchanged: boolean;
  c, cn: LongWord;
begin
  ans := SelectPaletteDlg;
  if ans < 0 then
    Exit;

  pname := '';
  case ans of
    0: pname := 'DOOM';
    1: pname := 'HERETIC';
    2: pname := 'HEXEN';
    3: pname := 'STRIFE';
    4: pname := 'RADIX';
    5:  // Optimized Octree
      begin
        Screen.Cursor := crHourglass;
        try
          SaveUndo(1);
          vxe_quantizevoxeldata(fvoxelbuffer, fvoxelsize, 255);
          fchanged := True;
          glneedrecalc := True;
          PaintBox1.Invalidate;
          UpdateDepthBuffer;
        finally
          Screen.Cursor := crDefault;
        end;
        Exit;
      end;
    6:  // Disk file (*.pal)
      begin
        if not OpenPaletteDialog.Execute then
          Exit;
        pname := OpenPaletteDialog.Filename;
      end;
  end;

  if pname = '' then
    Exit;

  rpal := VXE_GetRowPalette(pname);
  if rpal = nil then
    Exit;

  Screen.Cursor := crHourglass;
  try
    VXE_RawPalette2PaletteArray(rpal, pal);
    UpdatePaletteBitmap(pal);

    cchanged := False;
    for x := 0 to fvoxelsize - 1 do
      for y := 0 to fvoxelsize - 1 do
        for z := 0 to fvoxelsize - 1 do
        begin
          c := voxelbuffer[x, y, z];
          if c <> 0 then
          begin
            cn := pal[VXE_FindAproxColorIndex(@pal, c, 0, 255)];
            if cn = 0 then
              cn := $1;
            if cn <> c then
            begin
              if not cchanged then
              begin
                cchanged := True;
                SaveUndo(1);
              end;
              fvoxelbuffer[x, y, z] := cn;
            end;
          end;
        end;

    if cchanged then
    begin
      fchanged := True;
      glneedrecalc := True;
      PaintBox1.Invalidate;
      UpdateDepthBuffer;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TForm1.CreatePaletteBitmap(const pal: TPaletteArray): TBitmap;
var
  bm: TBitmap;
  i: integer;
  idx: integer;
  npal: TPaletteArray;
  x, y: integer;
  ncolors: TDNumberList;

  function colors2list: integer;
  var
    ii: integer;
  begin
    ncolors.Clear;
    if npal[0] = 0 then
    begin
      for ii := 1 to 255 do
        ncolors.Add(npal[ii]);
    end
    else
    begin
      for ii := 0 to 255 do
        if npal[ii] <> 0 then
          if ncolors.IndexOf(npal[ii]) < 0 then
            ncolors.Add(npal[ii]);
    end;
    Result := ncolors.Count;
  end;

  procedure drawblock(const xx, yy: integer; const cc: LongWord);
  var
    ii, jj: integer;
  begin
    for ii := xx *  8 to xx * 8 + 7 do
      for jj := yy *  8 to yy * 8 + 7 do
        bm.Canvas.Pixels[ii, jj] := cc;
    if cc = 0 then
    begin
      for ii := xx *  8 to xx * 8 + 7 do
      begin
        bm.Canvas.Pixels[ii, yy * 8] := RGB(255, 255, 255);
        bm.Canvas.Pixels[ii, yy * 8 + 7] := RGB(255, 255, 255);
      end;
      for jj := yy *  8 + 1 to yy * 8 + 6 do
      begin
        bm.Canvas.Pixels[xx * 8, jj] := RGB(255, 255, 255);
        bm.Canvas.Pixels[xx * 8 + 7, jj] := RGB(255, 255, 255);
      end;
      bm.Canvas.Pixels[xx * 8 + 2, yy * 8 + 2] := RGB(255, 255, 255);
      bm.Canvas.Pixels[xx * 8 + 2, yy * 8 + 5] := RGB(255, 255, 255);
      bm.Canvas.Pixels[xx * 8 + 5, yy * 8 + 2] := RGB(255, 255, 255);
      bm.Canvas.Pixels[xx * 8 + 5, yy * 8 + 5] := RGB(255, 255, 255);
      for ii := xx *  8 + 3 to xx * 8 + 4 do
        for jj := yy *  8 + 3 to yy * 8 + 4 do
          bm.Canvas.Pixels[ii, jj] := RGB(255, 255, 255);
    end;
  end;

begin
  for i := 0 to 255 do
    npal[i] := pal[i];

  ncolors := TDNumberList.Create;
  if colors2list = 256 then
  begin
    idx := VXE_FindAproxColorIndex(@npal, 0);
    npal[idx] := 0;
    colors2list;
  end;
  ZeroMemory(@npal, SizeOf(TPaletteArray));
  for i := 0 to ncolors.Count - 1 do
    npal[i + 1] := ncolors.Numbers[i];
  ncolors.Free;

  bm := TBitmap.Create;
  bm.PixelFormat := pf32bit;
  bm.Width := 32;
  bm.Height := 512;
  idx := 0;
  for x := 0 to 3 do
    for y := 0 to 63 do
    begin
      drawblock(x, y, npal[idx]);
      inc(idx);
    end;
  Result := bm;
end;

procedure TForm1.UpdatePaletteBitmap(const pal: TPaletteArray);
var
  bm: TBitmap;
begin
  bm := CreatePaletteBitmap(pal);
  palette.Canvas.Draw(0, 0, bm);
  bm.Free;
  palette.Invalidate;
end;

procedure TForm1.PaletteSpeedButton1Click(Sender: TObject);
var
  p: TPoint;
begin
  p := PaletteSpeedButton1.ClientToScreen(Point(0, PaletteSpeedButton1.Height));
  PalettePopupMenu1.Popup(p.X, p.Y);
  PaletteSpeedButton1.Down := False;
end;

procedure TForm1.SetDefaultPalette(const palname: string);
var
  rpal: pointer;
  pal: TPaletteArray;
begin
  rpal := VXE_GetRowPalette(palname);
  if rpal = nil then
    Exit;

  Screen.Cursor := crHourglass;
  try
    VXE_RawPalette2PaletteArray(rpal, pal);
    UpdatePaletteBitmap(pal);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.PaletteDoomClick(Sender: TObject);
begin
  SetDefaultPalette('DOOM');
end;

procedure TForm1.PaletteHereticClick(Sender: TObject);
begin
  SetDefaultPalette('HERETIC');
end;

procedure TForm1.PaletteHexenClick(Sender: TObject);
begin
  SetDefaultPalette('HEXEN');
end;

procedure TForm1.PaletteStrifeClick(Sender: TObject);
begin
  SetDefaultPalette('STRIFE');
end;

procedure TForm1.PaletteRadixClick(Sender: TObject);
begin
  SetDefaultPalette('RADIX');
end;

procedure TForm1.PaletteGreyScaleClick(Sender: TObject);
var
  i: integer;
  pal: TPaletteArray;
begin
  Screen.Cursor := crHourglass;
  try
    for i := 0 to 255 do
      pal[i] := RGB(i, i, i);
    UpdatePaletteBitmap(pal);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.DDVOXtoslab6VOX1Click(Sender: TObject);
var
  i: integer;
  sf, st: string;
  frm: TProgressForm;
begin
  if OpenDialog4.Execute then
  begin
    Screen.Cursor := crHourGlass;
    frm := TProgressForm.Create(nil);
    try
      frm.ProgressBar1.Max := OpenDialog4.Files.Count;
      frm.ProgressBar1.Position := 0;
      frm.Show;
      for i := 0 to OpenDialog4.Files.Count - 1 do
      begin
        frm.BringToFront;
        sf := OpenDialog4.Files.Strings[i];
        frm.Label1.Caption := 'Converting ' + MkShortName(sf);
        frm.Refresh;
        st := ChangeFileExt(sf, '.vox');
        BackupFile(st);
        ConvertDDVOX2VOX(sf, st);
        frm.ProgressBar1.Position := frm.ProgressBar1.Position + 1;
        frm.Refresh;
      end;
    finally
      frm.Free;
    end;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.Front1Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('front');

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  voxelview := vv_front;
  xpos := -1;
  ypos := -1;
  zpos := -1;
  UpdateDepthBuffer;
  ElevateSpeedButton.Enabled := True;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

procedure TForm1.Back1Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('back');

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  voxelview := vv_back;
  xpos := -1;
  ypos := -1;
  zpos := -1;
  UpdateDepthBuffer;
  ElevateSpeedButton.Enabled := True;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

procedure TForm1.Left1Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('left');

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  voxelview := vv_left;
  xpos := -1;
  ypos := -1;
  zpos := -1;
  UpdateDepthBuffer;
  ElevateSpeedButton.Enabled := True;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

procedure TForm1.Right1Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('right');

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  voxelview := vv_right;
  xpos := -1;
  ypos := -1;
  zpos := -1;
  UpdateDepthBuffer;
  ElevateSpeedButton.Enabled := True;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

procedure TForm1.Top1Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('top');

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  voxelview := vv_top;
  xpos := -1;
  ypos := -1;
  zpos := -1;
  UpdateDepthBuffer;
  ElevateSpeedButton.Enabled := True;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

procedure TForm1.Down1Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('down');

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  voxelview := vv_down;
  xpos := -1;
  ypos := -1;
  zpos := -1;
  UpdateDepthBuffer;
  ElevateSpeedButton.Enabled := True;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

procedure TForm1.Xaxis1Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('x' + IntToStr(xlevel));

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  voxelview := vv_none;
  if ElevateSpeedButton.Down then
    FreeDrawSpeedButton.Down := True;
  ElevateSpeedButton.Enabled := False;
  xpos := xlevel;
  ypos := -1;
  zpos := -1;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

procedure TForm1.Yaxis1Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('y' + IntToStr(ylevel));

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  voxelview := vv_none;
  if ElevateSpeedButton.Down then
    FreeDrawSpeedButton.Down := True;
  ElevateSpeedButton.Enabled := False;
  xpos := -1;
  ypos := ylevel;
  zpos := -1;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

procedure TForm1.Zaxis1Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('z' + IntToStr(zlevel));

  try ActiveControl := PalettePanel; SetFocusedControl(PalettePanel); PalettePanel.SetFocus; except end;
  voxelview := vv_none;
  if ElevateSpeedButton.Down then
    FreeDrawSpeedButton.Down := True;
  ElevateSpeedButton.Enabled := False;
  xpos := -1;
  ypos := -1;
  zpos := zlevel;
  PaintBox1.Invalidate;
  glneedrecalc := True;
end;

procedure TForm1.Increaselevel1Click(Sender: TObject);
begin
  if voxelview = vv_none then
  begin
    if (xpos >= 0) and (xlevel < fvoxelsize - 1) then
    begin
      inc(xlevel);
      ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('x' + IntToStr(xlevel));
      xpos := xlevel;
      PaintBox1.Invalidate;
      glneedrecalc := True;
    end
    else if (ypos >= 0) and (ylevel < fvoxelsize - 1) then
    begin
      inc(ylevel);
      ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('y' + IntToStr(ylevel));
      ypos := ylevel;
      PaintBox1.Invalidate;
      glneedrecalc := True;
    end
    else if (zpos >= 0) and (zlevel < fvoxelsize - 1) then
    begin
      inc(zlevel);
      ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('z' + IntToStr(zlevel));
      zpos := zlevel;
      PaintBox1.Invalidate;
      glneedrecalc := True;
    end
  end;
end;

procedure TForm1.Decreaselevel1Click(Sender: TObject);
begin
  if voxelview = vv_none then
  begin
    if (xpos >= 0) and (xlevel > 0) then
    begin
      dec(xlevel);
      ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('x' + IntToStr(xlevel));
      xpos := xlevel;
      PaintBox1.Invalidate;
      glneedrecalc := True;
    end
    else if (ypos >= 0) and (ylevel > 0) then
    begin
      dec(ylevel);
      ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('y' + IntToStr(ylevel));
      ypos := ylevel;
      PaintBox1.Invalidate;
      glneedrecalc := True;
    end
    else if (zpos >= 0) and (zlevel > 0) then
    begin
      dec(zlevel);
      ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('z' + IntToStr(zlevel));
      zpos := zlevel;
      PaintBox1.Invalidate;
      glneedrecalc := True;
    end
  end;
end;

procedure TForm1.View1Click(Sender: TObject);
var
  idx: integer;
  s: string;
begin
  Increaselevel1.Enabled := voxelview = vv_none;
  Decreaselevel1.Enabled := voxelview = vv_none;

  idx := ComboBox1.ItemIndex;
  if idx < 0 then
    Exit;

  s := ComboBox1.Items.Strings[idx];

  Front1.Checked := voxelview = vv_front;
  Back1.Checked := voxelview = vv_back;
  Left1.Checked := voxelview = vv_left;
  Right1.Checked := voxelview = vv_right;
  Top1.Checked := voxelview = vv_top;
  Down1.Checked := voxelview = vv_down;

  Xaxis1.Checked := (voxelview = vv_none) and (Pos('x', s) = 1);
  Yaxis1.Checked := (voxelview = vv_none) and (Pos('y', s) = 1);
  Zaxis1.Checked := (voxelview = vv_none) and (Pos('z', s) = 1);

end;

end.

