{******************************************************************************}
{                                                                              }
{       WiRL: RESTful Library for Delphi                                       }
{                                                                              }
{       Copyright (c) 2015-2019 WiRL Team                                      }
{                                                                              }
{       https://github.com/delphi-blocks/WiRL                                  }
{                                                                              }
{******************************************************************************}
unit Server.Forms.Main;

{$I WiRL.inc}

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.ActnList,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Diagnostics, System.Actions,

  JOSE.Core.JWA,
  WiRL.Configuration.Auth,
  WiRL.Configuration.JWT,
  WiRL.http.Server,
  WiRL.http.Server.Indy,
  WiRL.Core.Engine,
  WiRL.Core.Application, WiRL.Core.MessageBodyReader,
  WiRL.Core.MessageBodyWriter, WiRL.http.Filters, WiRL.Core.Registry;

type
  TMainForm = class(TForm)
    TopPanel: TPanel;
    StartButton: TButton;
    StopButton: TButton;
    MainActionList: TActionList;
    StartServerAction: TAction;
    StopServerAction: TAction;
    PortNumberEdit: TEdit;
    Label1: TLabel;
    edtSecret: TEdit;
    Label2: TLabel;
    procedure StartServerActionExecute(Sender: TObject);
    procedure StartServerActionUpdate(Sender: TObject);
    procedure StopServerActionExecute(Sender: TObject);
    procedure StopServerActionUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FServer: TWiRLServer;
  public
  end;

var
  MainForm: TMainForm;

implementation

uses
  Server.Claims;

{$R *.dfm}

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopServerAction.Execute;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  StartServerAction.Execute;
end;

procedure TMainForm.StartServerActionExecute(Sender: TObject);
begin
  // Create http server
  FServer := TWiRLServer.Create(nil);

  // Server & Apps configuration
  FServer
    .SetPort(StrToIntDef(PortNumberEdit.Text, 8080))

    // Engine configuration
    .AddEngine<TWiRLEngine>('/rest')
      .SetEngineName('WiRL Auth Demo')

      // App base configuration
      .AddApplication('/app')
        .SetAppName('Auth Application')
        .SetResources([
          'Server.Resources.TFormAuthResource',
          'Server.Resources.TBasicAuthResource',
          'Server.Resources.TBodyAuthResource',
          'Server.Resources.TUserResource'
        ])

    // Auth configuration
      .Plugin.Configure<IWiRLConfigurationAuth>
        .SetTokenType(TAuthTokenType.JWT)
        .SetTokenLocation(TAuthTokenLocation.Bearer)
        .BackToApp

    // JWT configuration (App plugin configuration)
      .Plugin.Configure<IWiRLConfigurationJWT>
        .SetClaimClass(TServerClaims)
        .SetAlgorithm(TJOSEAlgorithmId.HS256)
        .SetSecret(TEncoding.UTF8.GetBytes(edtSecret.Text));

  if not FServer.Active then
    FServer.Active := True;
end;

procedure TMainForm.StartServerActionUpdate(Sender: TObject);
begin
  StartServerAction.Enabled := (FServer = nil) or (FServer.Active = False);
end;

procedure TMainForm.StopServerActionExecute(Sender: TObject);
begin
  FServer.Active := False;
  FServer.Free;
end;

procedure TMainForm.StopServerActionUpdate(Sender: TObject);
begin
  StopServerAction.Enabled := Assigned(FServer) and (FServer.Active = True);
end;

end.
