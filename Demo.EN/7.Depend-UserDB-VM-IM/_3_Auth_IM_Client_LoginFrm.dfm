﻿object _3_Auth_IM_Client_LoginForm: T_3_Auth_IM_Client_LoginForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Sign in'
  ClientHeight = 225
  ClientWidth = 407
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  PopupMode = pmExplicit
  PopupParent = _3_Auth_IM_Client_Form.Owner
  Position = poMainFormCenter
  OnClose = FormClose
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object UserEdit: TLabeledEdit
    Left = 104
    Top = 80
    Width = 81
    Height = 21
    EditLabel.Width = 40
    EditLabel.Height = 13
    EditLabel.Caption = 'user name:'
    LabelPosition = lpLeft
    TabOrder = 2
    Text = 'test_user'
  end
  object PasswdEdit: TLabeledEdit
    Left = 104
    Top = 109
    Width = 81
    Height = 21
    EditLabel.Width = 28
    EditLabel.Height = 13
    EditLabel.Caption = 'password:'
    LabelPosition = lpLeft
    PasswordChar = '*'
    TabOrder = 3
    Text = 'test_user'
  end
  object loginButton: TButton
    Left = 104
    Top = 152
    Width = 58
    Height = 25
    Caption = 'Sign in'
    TabOrder = 4
    OnClick = loginButtonClick
  end
  object cancelButton: TButton
    Left = 232
    Top = 152
    Width = 58
    Height = 25
    Caption = 'cancel'
    TabOrder = 6
    OnClick = cancelButtonClick
  end
  object regButton: TButton
    Left = 168
    Top = 152
    Width = 58
    Height = 25
    Caption = 'register'
    TabOrder = 5
    OnClick = regButtonClick
  end
  object HostEdit: TLabeledEdit
    Left = 104
    Top = 32
    Width = 121
    Height = 21
    EditLabel.Width = 54
    EditLabel.Height = 13
    EditLabel.Caption = 'SaaS network:'
    LabelPosition = lpLeft
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object PortEdit: TLabeledEdit
    Left = 264
    Top = 32
    Width = 41
    Height = 21
    EditLabel.Width = 28
    EditLabel.Height = 13
    EditLabel.Caption = 'Port:'
    LabelPosition = lpLeft
    TabOrder = 1
    Text = '8387'
  end
end
