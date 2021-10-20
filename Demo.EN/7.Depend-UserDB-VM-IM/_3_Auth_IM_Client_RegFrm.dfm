object _3_Auth_IM_Client_RegForm: T_3_Auth_IM_Client_RegForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Registered user'
  ClientHeight = 270
  ClientWidth = 299
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  PopupMode = pmExplicit
  PopupParent = _3_Auth_IM_Client_LoginForm.Owner
  Position = poMainFormCenter
  OnClose = FormClose
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object UserEdit: TLabeledEdit
    Left = 104
    Top = 40
    Width = 81
    Height = 21
    EditLabel.Width = 54
    EditLabel.Height = 13
    EditLabel.Caption = 'user name:'
    LabelPosition = lpLeft
    TabOrder = 0
    Text = 'test_user'
  end
  object Passwd1Edit: TLabeledEdit
    Left = 104
    Top = 85
    Width = 81
    Height = 21
    EditLabel.Width = 50
    EditLabel.Height = 13
    EditLabel.Caption = 'password:'
    LabelPosition = lpLeft
    PasswordChar = '*'
    TabOrder = 1
    Text = 'test_user'
  end
  object Passwd2Edit: TLabeledEdit
    Left = 104
    Top = 112
    Width = 81
    Height = 21
    EditLabel.Width = 97
    EditLabel.Height = 13
    EditLabel.Caption = 'Duplicate password:'
    LabelPosition = lpLeft
    PasswordChar = '*'
    TabOrder = 2
    Text = 'test_user'
  end
  object AliasNameEdit: TLabeledEdit
    Left = 104
    Top = 152
    Width = 81
    Height = 21
    EditLabel.Width = 50
    EditLabel.Height = 13
    EditLabel.Caption = 'User alias:'
    LabelPosition = lpLeft
    TabOrder = 3
    Text = 'im auther'
  end
  object cancelButton: TButton
    Left = 159
    Top = 200
    Width = 58
    Height = 25
    Caption = 'cancel'
    TabOrder = 5
    OnClick = cancelButtonClick
  end
  object regButton: TButton
    Left = 96
    Top = 200
    Width = 58
    Height = 25
    Caption = 'register'
    TabOrder = 4
    OnClick = regButtonClick
  end
end
