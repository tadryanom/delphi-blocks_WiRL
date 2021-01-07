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

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.ActnList,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Diagnostics, System.Actions, IdContext,

  WiRL.Configuration.Neon,
  WiRL.Configuration.OpenAPI,
  Neon.Core.Types,
  WiRL.Core.Application,
  WiRL.Core.Engine,
  WiRL.http.Server,
  WiRL.http.Server.Indy;

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
    procedure FormDestroy(Sender: TObject);
    procedure StartServerActionExecute(Sender: TObject);
    procedure StartServerActionUpdate(Sender: TObject);
    procedure StopServerActionExecute(Sender: TObject);
    procedure StopServerActionUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FRESTServer: TWiRLServer;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  WiRL.Core.OpenAPI.Resource;

{$R *.dfm}

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FRESTServer.Free;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopServerAction.Execute;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FRESTServer := TWiRLServer.Create(Self);

  FRESTServer.AddEngine<TWiRLEngine>('/rest')
    .SetEngineName('RESTEngine')

    .AddApplication('/app')

      // Test for namespaces
      .SetResources('Server.Resources.Demo.*')
      .SetResources('Server.Resources.Swagger.*')
      .SetFilters('*')

      .Plugin.Configure<IWiRLConfigurationNeon>
        .SetUseUTCDate(True)
        .SetMemberCase(TNeonCase.SnakeCase)
        .BackToApp

      .Plugin.Configure<IWiRLConfigurationOpenAPI>
        .SetXMLDocFolder('.\XMLDoc')
        .SetDocumentationFolder('.\Documentation')
        .BackToApp
  ;

  StartServerAction.Execute;
end;

procedure TMainForm.StartServerActionExecute(Sender: TObject);
begin
  FRESTServer.Port := StrToIntDef(PortNumberEdit.Text, 8080);
  if not FRESTServer.Active then
    FRESTServer.Active := True;
end;

procedure TMainForm.StartServerActionUpdate(Sender: TObject);
begin
  StartServerAction.Enabled := not Assigned(FRESTServer) or not FRESTServer.Active;
end;

procedure TMainForm.StopServerActionExecute(Sender: TObject);
begin
  FRESTServer.Active := False;
end;

procedure TMainForm.StopServerActionUpdate(Sender: TObject);
begin
  StopServerAction.Enabled := Assigned(FRESTServer) and FRESTServer.Active;
end;

end.
