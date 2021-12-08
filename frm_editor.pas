//------------------------------------------------------------------------------
//
//  DD_VOXEL: DelphiDoom Voxel Editor
//  Copyright (C) 2013-2021 by Jim Valavanis
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
//  Script Editor Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit frm_editor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons, Menus, ToolWin, psv_voxel,
  SynEdit, SynEditRegexSearch, SynEditSearch;

var
  EditorFormCreated: boolean = False;

type
  TEditorForm = class(TForm)
    Panel8: TPanel;
    Splitter3: TSplitter;
    OutputMemo: TMemo;
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    FunctionsMainPanel: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Label1: TLabel;
    Panel6: TPanel;
    FunctionsListBox: TListBox;
    Splitter1: TSplitter;
    FunctionsEdit: TEdit;
    EditorPopupMenu: TPopupMenu;
    EditorCut1: TMenuItem;
    EditorCopy1: TMenuItem;
    EditorPaste1: TMenuItem;
    EditorUndo1: TMenuItem;
    EditorRedo1: TMenuItem;
    N1: TMenuItem;
    EditorSelectall1: TMenuItem;
    N2: TMenuItem;
    Search1: TMenuItem;
    Replace1: TMenuItem;
    SearchAgain1: TMenuItem;
    Gotolinenumber1: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    EditorToolbarPanel: TToolBar;
    CompileAndRunButton1: TSpeedButton;
    CompileButton1: TSpeedButton;
    SaveAsButton1: TSpeedButton;
    SaveButton1: TSpeedButton;
    OpenScriptButton1: TSpeedButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    NewScriptButton1: TSpeedButton;
    SaveDialog2: TSaveDialog;
    CreateMacroButton1: TSpeedButton;
    procedure Splitter3Moved(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SaveButton1Click(Sender: TObject);
    procedure SaveAsButton1Click(Sender: TObject);
    procedure CompileButton1Click(Sender: TObject);
    procedure CompileAndRunButton1Click(Sender: TObject);
    procedure OpenScriptButton1Click(Sender: TObject);
    procedure Panel5Resize(Sender: TObject);
    procedure FunctionsListBoxClick(Sender: TObject);
    procedure EditorPopupMenuPopup(Sender: TObject);
    procedure EditorCut1Click(Sender: TObject);
    procedure EditorCopy1Click(Sender: TObject);
    procedure EditorPaste1Click(Sender: TObject);
    procedure EditorUndo1Click(Sender: TObject);
    procedure EditorRedo1Click(Sender: TObject);
    procedure EditorSelectall1Click(Sender: TObject);
    procedure Search1Click(Sender: TObject);
    procedure Replace1Click(Sender: TObject);
    procedure SearchAgain1Click(Sender: TObject);
    procedure Gotolinenumber1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure NewScriptButton1Click(Sender: TObject);
    procedure CreateMacroButton1Click(Sender: TObject);
  private
    { Private declarations }
    CodeEditor: TSynEdit;
    SynEditRegexSearch1: TSynEditRegexSearch;
    SynEditSearch1: TSynEditSearch;
    changed: boolean;
    ffilename: string;
    procedure ShowSearchReplaceDialog(const SynEdit1: TSynEdit; AReplace: boolean);
    procedure DoSearchReplaceText(const SynEdit1: TSynEdit; AReplace: boolean; ABackwards: boolean);
    procedure ShowSearchDialog(const SynEdit1: TSynEdit);
    procedure SearchAgain(const SynEdit1: TSynEdit);
    procedure ShowReplaceDialog(const SynEdit1: TSynEdit);
    procedure GoToLineNumber(const SynEdit1: TSynEdit);
    procedure OnMoveMessage(var Msg: TWMMove); message WM_MOVE;
    procedure CodeEditorChange(Sender: TObject);
    function DoOpenCodeEditor(const fname: string): boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    function CheckCanClose: boolean;
    property FileName: string read ffilename;
  end;

var
  EditorForm: TEditorForm;

var
  ScriptPath: string = '';

implementation

{$R *.dfm}

uses
  main,
  vxe_utils,
  psv_script_functions,
  psv_script_proclist,
  SynHighlighterDDVoxelScript,
  SynEditTypes,
  SynUnicode,
  frm_ConfirmReplace,
  frm_GotoLine,
  frm_SearchText,
  frm_ReplaceText;

resourcestring
  rsEditorTitle = 'Script Editor';

procedure outprocmemo(const s: string);
begin
  EditorForm.OutputMemo.Lines.Add(s);
end;

procedure TEditorForm.Splitter3Moved(Sender: TObject);
begin
  Form1.needrefresh := True;
end;

procedure eoutproc(const s: string);
begin
  EditorForm.OutputMemo.Lines.Text := EditorForm.OutputMemo.Lines.Text + s;
end;

const
  defscript: string =
    'voxel voxel1;'#13#10 +
    ''#13#10 +
    'var'#13#10 +
    '  i, j, k: integer;'#13#10 +
    'begin'#13#10 +
    '  for i := 0 to voxelsize - 1 do'#13#10 +
    '    for j := 0 to voxelsize - 1 do'#13#10 +
    '      for k := 0 to voxelsize - 1 do'#13#10 +
    '        voxelbuffer[i, j, k] := RGB(0, 0, 0);'#13#10 +
    'end.';

procedure TEditorForm.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;

  Scaled := False;
  changed := False;

  Caption := rsEditorTitle;

  Width := Screen.Width div 2;
  Height := Screen.Height div 2;
  Left := Width div 20;
  Top := Height - Height div 20;

  outproc := eoutproc;
  ffilename := '';

  CodeEditor := TSynEdit.Create(Self);
  CodeEditor.Parent := TabSheet1;
  CodeEditor.Align := alClient;
  CodeEditor.Highlighter := TSynDDVoxelScriptHighlighter.Create(Self);
  CodeEditor.OnChange := CodeEditorChange;
  CodeEditor.Gutter.ShowLineNumbers := True;
  CodeEditor.Gutter.AutoSize := True;
  CodeEditor.MaxScrollWidth := 255;
  CodeEditor.WantTabs := True;
  CodeEditor.ReadOnly := False;
  CodeEditor.PopupMenu := EditorPopupMenu;
  CodeEditor.Text := defscript;

  SynEditRegexSearch1 := TSynEditRegexSearch.Create(Self);
  SynEditSearch1 := TSynEditSearch.Create(Self);

  PageControl1.ActivePageIndex := 0;

  @outproc := @outprocmemo;

  EditorToolbarPanel.PopupMenu := EditorPopupMenu;

  FunctionsListBox.Items.Text := VDL_Procs;
  if FunctionsListBox.Items.Count > 0 then
  begin
    FunctionsListBox.ItemIndex := 0;
    FunctionsEdit.Text := FunctionsListBox.Items.Strings[0];
  end;

  EditorFormCreated := True;
end;

procedure TEditorForm.SaveButton1Click(Sender: TObject);
begin
  if ffilename = '' then
    SaveAsButton1Click(sender)
  else
  begin
    changed := False;
    BackupFile(ffilename);
    CodeEditor.Lines.SaveUnicode := False;
    CodeEditor.Lines.SaveFormat := sfAnsi;
    CodeEditor.Lines.SaveToFile(ffilename);
  end;
end;

procedure TEditorForm.SaveAsButton1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    changed := False;
    ffilename := SaveDialog1.FileName;
    BackupFile(ffilename);
    CodeEditor.Lines.SaveUnicode := False;
    CodeEditor.Lines.SaveFormat := sfAnsi;
    CodeEditor.Lines.SaveToFile(ffilename);
    Caption := rsEditorTitle + ' - ' + MkShortName(ffilename);
  end;
end;

procedure TEditorForm.CompileButton1Click(Sender: TObject);
var
  vdl: TDDVoxelScriptLoader;
  Data: {$IFDEF UNICODE}AnsiString{$ELSE}string{$ENDIF};
begin
  Screen.Cursor := crHourGlass;
  try
    OutputMemo.Lines.Clear;

    vdl := TDDVoxelScriptLoader.Create(Form1.voxelbuffer, Form1.voxelsize);
    vdl.LoadFromScript(CodeEditor.Lines.Text, True, False, Data);

    vdl.Free;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TEditorForm.CompileAndRunButton1Click(Sender: TObject);
var
  vdl: TDDVoxelScriptLoader;
  ret: boolean;
  Data: {$IFDEF UNICODE}AnsiString{$ELSE}string{$ENDIF};
  numpx: integer;
begin
  Screen.Cursor := crHourGlass;
  try
    OutputMemo.Lines.Clear;

    vdl := TDDVoxelScriptLoader.Create(Form1.voxelbuffer, Form1.voxelsize);
    ret := vdl.LoadFromScript(CodeEditor.Lines.Text, True, True, Data);

    if ret then
    begin
      if vdl.NumCmds <> 0 then
        Form1.SaveUndoEditor;
      numpx := vdl.RenderToBuffer;
      if numpx > 0 then
        printf('Voxel buffer updated successfully, ' + IntToStr(numpx) + ' voxel items were updated'#13#10)
      else
        printf('Successful run, no voxel items were updated'#13#10);
      if vdl.NumCmds > 0 then
      begin
        Form1.needrecalc := True;
        Form1.VoxelChanged := True;
        Form1.PaintBox1.Invalidate;
        Form1.UpdateDepthBuffer;
      end;
    end;

    vdl.Free;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TEditorForm.OpenScriptButton1Click(Sender: TObject);
begin
  if not CheckCanClose then
    Exit;

  if OpenDialog1.Execute then
    DoOpenCodeEditor(OpenDialog1.FileName);
end;

procedure TEditorForm.Panel5Resize(Sender: TObject);
begin
  if Panel5.Width > 8 then
    FunctionsEdit.Width := Panel5.Width - 8;
end;

procedure TEditorForm.FunctionsListBoxClick(Sender: TObject);
begin
  if FunctionsListBox.ItemIndex >= 0 then
    FunctionsEdit.Text := FunctionsListBox.Items.Strings[FunctionsListBox.ItemIndex];
end;

procedure TEditorForm.EditorPopupMenuPopup(Sender: TObject);
begin
  EditorUndo1.Enabled := CodeEditor.CanUndo;
  EditorRedo1.Enabled := CodeEditor.CanRedo;
  EditorCut1.Enabled := CodeEditor.SelText <> '';
  EditorCopy1.Enabled := CodeEditor.SelText <> '';
  EditorPaste1.Enabled := CodeEditor.CanPaste;
end;

procedure TEditorForm.EditorCut1Click(Sender: TObject);
begin
  CodeEditor.CutToClipboard;
end;

procedure TEditorForm.EditorCopy1Click(Sender: TObject);
begin
  CodeEditor.CopyToClipboard;
end;

procedure TEditorForm.EditorPaste1Click(Sender: TObject);
begin
  CodeEditor.PasteFromClipboard;
end;

procedure TEditorForm.EditorUndo1Click(Sender: TObject);
begin
  CodeEditor.Undo;
end;

procedure TEditorForm.EditorRedo1Click(Sender: TObject);
begin
  CodeEditor.Redo;
end;

procedure TEditorForm.EditorSelectall1Click(Sender: TObject);
begin
  CodeEditor.SelectAll;
end;

var
  gbSearchBackwards: boolean;
  gbSearchCaseSensitive: boolean;
  gbSearchFromCaret: boolean;
  gbSearchSelectionOnly: boolean;
  gbSearchTextAtCaret: boolean;
  gbSearchWholeWords: boolean;
  gbSearchRegex: boolean;
  gsSearchText: string;
  gsSearchTextHistory: string;
  gsReplaceText: string;
  gsReplaceTextHistory: string;
  fSearchFromCaret: boolean;

procedure TEditorForm.ShowSearchReplaceDialog(const SynEdit1: TSynEdit; AReplace: boolean);
var
  dlg: TTextSearchDialog;
begin
  if AReplace then
    dlg := TTextReplaceDialog.Create(Self)
  else
    dlg := TTextSearchDialog.Create(Self);
  with dlg do
  try
    // assign search options
    SearchBackwards := gbSearchBackwards;
    SearchCaseSensitive := gbSearchCaseSensitive;
    SearchFromCursor := gbSearchFromCaret;
    SearchInSelectionOnly := gbSearchSelectionOnly;
    // start with last search text
    SearchText := gsSearchText;
    if gbSearchTextAtCaret then
    begin
      // if something is selected search for that text
      if SynEdit1.SelAvail and (SynEdit1.BlockBegin.Line = SynEdit1.BlockEnd.Line) //Birb (fix at SynEdit's SearchReplaceDemo)
      then
        SearchText := SynEdit1.SelText
      else
        SearchText := SynEdit1.GetWordAtRowCol(SynEdit1.CaretXY);
    end;
    SearchTextHistory := gsSearchTextHistory;
    if AReplace then with dlg as TTextReplaceDialog do
    begin
      ReplaceText := gsReplaceText;
      ReplaceTextHistory := gsReplaceTextHistory;
    end;
    SearchWholeWords := gbSearchWholeWords;
    if ShowModal = mrOK then
    begin
      gbSearchBackwards := SearchBackwards;
      gbSearchCaseSensitive := SearchCaseSensitive;
      gbSearchFromCaret := SearchFromCursor;
      gbSearchSelectionOnly := SearchInSelectionOnly;
      gbSearchWholeWords := SearchWholeWords;
      gbSearchRegex := SearchRegularExpression;
      gsSearchText := SearchText;
      gsSearchTextHistory := SearchTextHistory;
      if AReplace then
        with dlg as TTextReplaceDialog do
        begin
          gsReplaceText := ReplaceText;
          gsReplaceTextHistory := ReplaceTextHistory;
        end;
      fSearchFromCaret := gbSearchFromCaret;
      if gsSearchText <> '' then
      begin
        DoSearchReplaceText(SynEdit1, AReplace, gbSearchBackwards);
        fSearchFromCaret := True;
      end;
    end;
  finally
    dlg.Free;
  end;
end;

procedure TEditorForm.DoSearchReplaceText(const SynEdit1: TSynEdit; AReplace: boolean; ABackwards: boolean);
var
  Options: TSynSearchOptions;
begin
  if AReplace then
    Options := [ssoPrompt, ssoReplace, ssoReplaceAll]
  else
    Options := [];
  if ABackwards then
    Include(Options, ssoBackwards);
  if gbSearchCaseSensitive then
    Include(Options, ssoMatchCase);
  if not fSearchFromCaret then
    Include(Options, ssoEntireScope);
  if gbSearchSelectionOnly then
    Include(Options, ssoSelectedOnly);
  if gbSearchWholeWords then
    Include(Options, ssoWholeWord);
  if gbSearchRegex then
    SynEdit1.SearchEngine := SynEditRegexSearch1
  else
    SynEdit1.SearchEngine := SynEditSearch1;
  if SynEdit1.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  begin
    MessageBeep(MB_ICONASTERISK);
    if ssoBackwards in Options then
      SynEdit1.BlockEnd := SynEdit1.BlockBegin
    else
      SynEdit1.BlockBegin := SynEdit1.BlockEnd;
    SynEdit1.CaretXY := SynEdit1.BlockBegin;
  end;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

procedure TEditorForm.ShowSearchDialog(const SynEdit1: TSynEdit);
begin
  ShowSearchReplaceDialog(SynEdit1, False);
end;

procedure TEditorForm.SearchAgain(const SynEdit1: TSynEdit);
var
  Options: TSynSearchOptions;
begin
  if gsSearchText = '' then
  begin
    ShowSearchDialog(SynEdit1);
    Exit;
  end;

  Options := [];
  if gbSearchBackwards then
    Include(Options, ssoBackwards);
  if gbSearchCaseSensitive then
    Include(Options, ssoMatchCase);
  if gbSearchSelectionOnly then
    Include(Options, ssoSelectedOnly);
  if gbSearchWholeWords then
    Include(Options, ssoWholeWord);
  if gbSearchRegex then
    SynEdit1.SearchEngine := SynEditRegexSearch1
  else
    SynEdit1.SearchEngine := SynEditSearch1;
  if SynEdit1.SearchReplace(gsSearchText, '', Options) = 0 then
  begin
    MessageBeep(MB_ICONASTERISK);
    if ssoBackwards in Options then
      SynEdit1.BlockEnd := SynEdit1.BlockBegin
    else
      SynEdit1.BlockBegin := SynEdit1.BlockEnd;
    SynEdit1.CaretXY := SynEdit1.BlockBegin;
  end;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

procedure TEditorForm.ShowReplaceDialog(const SynEdit1: TSynEdit);
begin
  ShowSearchReplaceDialog(SynEdit1, True);
end;

procedure TEditorForm.GoToLineNumber(const SynEdit1: TSynEdit);
begin
  with TfrmGotoLine.Create(self) do
  try
    Char := SynEdit1.CaretX;
    Line := SynEdit1.CaretY;
    ShowModal;
    if ModalResult = mrOK then
      SynEdit1.CaretXY := CaretXY;
  finally
    Free;
  end;
  try
    SynEdit1.SetFocus;
  except
  end;
end;

procedure TEditorForm.Search1Click(Sender: TObject);
begin
  ShowSearchDialog(CodeEditor);
end;

procedure TEditorForm.Replace1Click(Sender: TObject);
begin
  ShowReplaceDialog(CodeEditor);
end;

procedure TEditorForm.SearchAgain1Click(Sender: TObject);
begin
  SearchAgain(CodeEditor);
end;

procedure TEditorForm.Gotolinenumber1Click(Sender: TObject);
begin
  GoToLineNumber(CodeEditor);
end;

procedure TEditorForm.OnMoveMessage(var Msg: TWMMove);
begin
  Form1.needrefresh := True;
end;

procedure TEditorForm.FormResize(Sender: TObject);
begin
  Form1.needrefresh := True;
end;

procedure TEditorForm.CodeEditorChange(Sender: TObject);
begin
  changed := True;
end;

function TEditorForm.DoOpenCodeEditor(const fname: string): boolean;
begin
  if not FileExists(fname) then
  begin
    Result := False;
    Exit;
  end;

  CodeEditor.Lines.LoadFromFile(fname);
  ffilename := fname;
  Caption := rsEditorTitle + ' - ' + MkShortName(ffilename);
  changed := False;
  PageControl1.ActivePageIndex := 0;
  OutputMemo.Lines.Clear;
  Result := True;
end;

function TEditorForm.CheckCanClose: boolean;
var
  ret: integer;
begin
  if changed then
  begin
    Visible := True;
    ret := MessageBox(Handle, 'Script has been modified'#13#10'Do you want to save changes?', PChar(rsEditorTitle), MB_YESNOCANCEL or MB_ICONQUESTION or MB_APPLMODAL);
    if ret = idCancel then
    begin
      Result := False;
      Exit;
    end;
    if ret = idNo then
    begin
      Result := True;
      Exit;
    end;
    if ret = idYes then
    begin
      SaveButton1Click(self);
      Result := not changed;
      Exit;
    end;
  end;
  Result := True;
end;

procedure TEditorForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := CheckCanClose;
end;

procedure TEditorForm.CreateParams;
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_PALETTEWINDOW;
end;

procedure TEditorForm.NewScriptButton1Click(Sender: TObject);
begin
  if not CheckCanClose then
    Exit;

  CodeEditor.Lines.Clear;
  ffilename := '';
  Caption := rsEditorTitle;
  changed := False;
  PageControl1.ActivePageIndex := 0;
  OutputMemo.Lines.Clear;
end;

procedure TEditorForm.CreateMacroButton1Click(Sender: TObject);
var
  vdl: TDDVoxelScriptLoader;
  ret: boolean;
  Data: {$IFDEF UNICODE}AnsiString{$ELSE}string{$ENDIF};
  fs: TFileStream;
  i: integer;
begin
  if SaveDialog2.Execute then
  begin
    Screen.Cursor := crHourGlass;
    try
      OutputMemo.Lines.Clear;

      vdl := TDDVoxelScriptLoader.Create(Form1.voxelbuffer, Form1.voxelsize);
      ret := vdl.LoadFromScript(CodeEditor.Lines.Text, True, False, Data);
      vdl.Free;

      if ret then
      begin
        BackupFile(ffilename);
        fs := TFileStream.Create(SaveDialog2.FileName, fmCreate);
        try
          for i := 1 to Length(Data) do
            fs.Write(Byte(Data[i]), SizeOf(Byte));
        finally
          fs.Free;
        end;
      end;

    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

end.
