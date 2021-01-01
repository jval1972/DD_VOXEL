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
//  Main Programm
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

program DD_VOXEL;

uses
  FastMM4 in 'FastMM4.pas',
  FastMM4Messages in 'FastMM4Messages.pas',
  Forms,
  main in 'main.pas' {Form1},
  newfrm in 'newfrm.pas' {NewForm},
  voxels in 'voxels.pas',
  vxe_gl in 'vxe_gl.pas',
  vxe_system in 'vxe_system.pas',
  vxe_script in 'vxe_script.pas',
  vxe_rotate in 'vxe_rotate.pas',
  vxe_undo in 'vxe_undo.pas',
  vxe_binary in 'vxe_binary.pas',
  vxe_defs in 'vxe_defs.pas',
  optionsfrm in 'optionsfrm.pas' {OptionsForm},
  vxe_mesh in 'vxe_mesh.pas',
  kvx2mesh in 'kvx2mesh.pas',
  vxe_kvx in 'vxe_kvx.pas',
  progressfrm in 'progressfrm.pas' {ProgressForm},
  ddvox2mesh in 'ddvox2mesh.pas',
  vxe_threads in 'vxe_threads.pas',
  dglOpenGL in 'dglOpenGL.pas',
  pngextra in 'pngextra.pas',
  pngimage in 'pngimage.pas',
  pnglang in 'pnglang.pas',
  xTGA in 'xTGA.pas',
  zBitmap in 'zBitmap.pas',
  zlibpas in 'zlibpas.pas',
  frm_previewbitmap in 'frm_previewbitmap.pas' {PreviewBitmapForm},
  vxe_utils in 'vxe_utils.pas',
  frm_srinkheightmap in 'frm_srinkheightmap.pas' {SrinkHeightmapForm},
  vxe_multithreading in 'vxe_multithreading.pas',
  vxe_filemenuhistory in 'vxe_filemenuhistory.pas',
  vxe_export in 'vxe_export.pas',
  frm_rotate in 'frm_rotate.pas' {RotateVoxelForm},
  vxe_zipfile in 'vxe_zipfile.pas',
  frm_exportsprite in 'frm_exportsprite.pas' {ExportSpriteForm},
  vxe_wadwriter in 'vxe_wadwriter.pas',
  frm_spriteprefix in 'frm_spriteprefix.pas' {SpritePrefixForm},
  frm_ConfirmReplace in 'frm_ConfirmReplace.pas' {ConfirmReplaceDialog},
  frm_editor in 'frm_editor.pas' {EditorForm},
  frm_GotoLine in 'frm_GotoLine.pas' {frmGotoLine},
  frm_ReplaceText in 'frm_ReplaceText.pas',
  frm_SearchText in 'frm_SearchText.pas' {TextSearchDialog},
  psv_script in 'psv_script.pas',
  psv_script_functions in 'psv_script_functions.pas',
  psv_script_proclist in 'psv_script_proclist.pas',
  psv_voxel in 'psv_voxel.pas',
  uPSCompiler in 'uPSCompiler.pas',
  uPSRuntime in 'uPSRuntime.pas',
  uPSUtils in 'uPSUtils.pas',
  SynEdit in 'SynEdit\SynEdit.pas',
  SynEditHighlighter in 'SynEdit\SynEditHighlighter.pas',
  SynEditHighlighterOptions in 'SynEdit\SynEditHighlighterOptions.pas',
  SynEditKbdHandler in 'SynEdit\SynEditKbdHandler.pas',
  SynEditKeyCmds in 'SynEdit\SynEditKeyCmds.pas',
  SynEditKeyConst in 'SynEdit\SynEditKeyConst.pas',
  SynEditMiscClasses in 'SynEdit\SynEditMiscClasses.pas',
  SynEditMiscProcs in 'SynEdit\SynEditMiscProcs.pas',
  SynEditRegexSearch in 'SynEdit\SynEditRegexSearch.pas',
  SynEditSearch in 'SynEdit\SynEditSearch.pas',
  SynEditStrConst in 'SynEdit\SynEditStrConst.pas',
  SynEditTextBuffer in 'SynEdit\SynEditTextBuffer.pas',
  SynEditTypes in 'SynEdit\SynEditTypes.pas',
  SynEditWordWrap in 'SynEdit\SynEditWordWrap.pas',
  SynHighlighterDDVoxelScript in 'SynEdit\SynHighlighterDDVoxelScript.pas',
  SynHighlighterMulti in 'SynEdit\SynHighlighterMulti.pas',
  SynRegExpr in 'SynEdit\SynRegExpr.pas',
  SynTextDrawer in 'SynEdit\SynTextDrawer.pas',
  SynUnicode in 'SynEdit\SynUnicode.pas',
  psv_voxelbuffer in 'psv_voxelbuffer.pas',
  psv_VXTextures in 'psv_VXTextures.pas',
  psv_VXVoxels in 'psv_VXVoxels.pas',
  vxe_tmp in 'vxe_tmp.pas',
  pcximage in 'pcximage.pas',
  xGif in 'xGIF.pas',
  xPPM in 'xPPM.pas',
  xDIB in 'xDIB.pas',
  psv_temp in 'psv_temp.pas',
  vxe_quantize in 'vxe_quantize.pas',
  vxe_palette in 'vxe_palette.pas',
  frm_selectpalette in 'frm_selectpalette.pas' {SelectPaletteForm},
  ddvox2vox in 'ddvox2vox.pas',
  uPSC_buttons in 'uPSC_buttons.pas',
  uPSC_classes in 'uPSC_classes.pas',
  uPSC_comobj in 'uPSC_comobj.pas',
  uPSC_controls in 'uPSC_controls.pas',
  uPSC_dateutils in 'uPSC_dateutils.pas',
  uPSC_DB in 'uPSC_DB.pas',
  uPSC_extctrls in 'uPSC_extctrls.pas',
  uPSC_forms in 'uPSC_forms.pas',
  uPSC_graphics in 'uPSC_graphics.pas',
  uPSC_menus in 'uPSC_menus.pas',
  uPSC_std in 'uPSC_std.pas',
  uPSC_stdctrls in 'uPSC_stdctrls.pas',
  uPSR_buttons in 'uPSR_buttons.pas',
  uPSR_classes in 'uPSR_classes.pas',
  uPSR_comobj in 'uPSR_comobj.pas',
  uPSR_controls in 'uPSR_controls.pas',
  uPSR_dateutils in 'uPSR_dateutils.pas',
  uPSR_DB in 'uPSR_DB.pas',
  uPSR_extctrls in 'uPSR_extctrls.pas',
  uPSR_forms in 'uPSR_forms.pas',
  uPSR_graphics in 'uPSR_graphics.pas',
  uPSR_menus in 'uPSR_menus.pas',
  uPSR_std in 'uPSR_std.pas',
  uPSR_stdctrls in 'uPSR_stdctrls.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'DD_VOXEL';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TProgressForm, ProgressForm);
  Application.CreateForm(TConfirmReplaceDialog, ConfirmReplaceDialog);
  Application.CreateForm(TEditorForm, EditorForm);
  Application.Run;
end.
