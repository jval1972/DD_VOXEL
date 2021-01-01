object OptionsForm: TOptionsForm
  Left = 934
  Top = 96
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 205
  ClientWidth = 223
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 24
    Top = 152
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 120
    Top = 152
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object CheckBox1: TCheckBox
    Left = 16
    Top = 16
    Width = 185
    Height = 17
    Caption = 'Render voxel using GL_PIXELS'
    TabOrder = 2
  end
  object CheckBox2: TCheckBox
    Left = 16
    Top = 40
    Width = 185
    Height = 17
    Caption = 'Render GL Axes'
    TabOrder = 3
  end
  object CheckBox3: TCheckBox
    Left = 16
    Top = 64
    Width = 185
    Height = 17
    Caption = 'Render GL Grid'
    TabOrder = 4
  end
  object CheckBox4: TCheckBox
    Left = 16
    Top = 88
    Width = 185
    Height = 17
    Caption = 'Render Wireframe'
    TabOrder = 5
  end
  object CheckBox5: TCheckBox
    Left = 16
    Top = 112
    Width = 97
    Height = 17
    Caption = 'Silent Macros'
    TabOrder = 6
  end
end
