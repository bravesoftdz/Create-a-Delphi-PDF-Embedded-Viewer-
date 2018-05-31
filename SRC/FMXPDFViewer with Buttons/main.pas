unit main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.WebBrowser, FMX.Controls.Presentation, System.Threading,
  System.netencoding,
  IdCoder3to4, IdCoderMIME, FMX.ScrollBox, FMX.Memo, IDGLobal,
  FMX.Edit, FMX.Layouts, IdBaseComponent, IdCoder, System.IOUtils
{$IFDEF MSWINDOWS}
    , System.Win.Registry
{$ENDIF}
    ;

Var
  ConvertedFile: string;
  SendFileinfo: string;

type
  TfmPDFview = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    Layout1: TLayout;
    OpenDialog1: TOpenDialog;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    StyleBook1: TStyleBook;
    AniIndicator1: TAniIndicator;
    Timer1: TTimer;
    Timer2: TTimer;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    CheckBox1: TCheckBox;
    WebBrowser1: TWebBrowser;
    Timer3: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure OpenDialog1Show(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
  private
    Datajs: string;
    PageNum: integer;
    procedure eval(Sender: TObject; js: string);
    function Embeddedfile: string;
    procedure LoadBrowser(Sender: TObject);
    procedure Base64encode(Sender: TObject);
{$IFDEF MSWINDOWS}
    procedure SetPermissions;
{$ENDIF}
  public
    procedure settimer(T: boolean);
    { Public declarations }
  end;

var
  fmPDFview: TfmPDFview;

implementation

{$R *.fmx}

procedure TfmPDFview.LoadBrowser(Sender: TObject);
var
  js: string;
begin
  SpeedButton2.Enabled := true;
  SpeedButton3.Enabled := true;
  js := 'externalPDF("' + ConvertedFile + '",1); ';

  WebBrowser1.EvaluateJavaScript(js);
end;

procedure TfmPDFview.OpenDialog1Show(Sender: TObject);
begin
  Timer1.Enabled := true;;
end;

procedure TfmPDFview.Base64encode(Sender: TObject);
var
  MIMEEncoder: TidEncoderMime;
begin
  try
    MIMEEncoder := TidEncoderMime.Create(nil);
    ConvertedFile := MIMEEncoder.encodestring(SendFileinfo,
      IDGLobal.IndyTextEncoding_OSDefault);
  finally
    MIMEEncoder.free;
  end;
end;

procedure TfmPDFview.FormCreate(Sender: TObject);
begin
  SendFileinfo := '';
{$IFDEF MSWINDOWS}
  SetPermissions;
  // load the javascript pdfviewer
  WebBrowser1.URL := 'file://' + GetCurrentDir +
    '/../../binarypdf/PDFjsindex.html';
{$ENDIF}
{$IFDEF ANDROID}
  WebBrowser1.URL := 'file://' + TPath.Combine(TPath.GetDocumentsPath,
    'PDFjsindex.html');
{$ENDIF}
  settimer(false);
  AniIndicator1.Enabled := false;
  AniIndicator1.Visible := false;
  SpeedButton2.Enabled := false;
  SpeedButton3.Enabled := false;
  ConvertedFile := '';
  SendFileinfo := '';
end;

{$IFDEF MSWINDOWS}

procedure TfmPDFview.SetPermissions;
const
  cHomePath = 'SOFTWARE';
  cFeatureBrowserEmulation =
    'Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\';
  cIE11 = 11001;

var
  Reg: TRegIniFile;
  sKey: string;
begin

  sKey := ExtractFileName(ParamStr(0));
  Reg := TRegIniFile.Create(cHomePath);
  try
    if Reg.OpenKey(cFeatureBrowserEmulation, true) and
      not(TRegistry(Reg).KeyExists(sKey) and (TRegistry(Reg).ReadInteger(sKey)
      = cIE11)) then
      TRegistry(Reg).WriteInteger(sKey, cIE11);
  finally
    Reg.free;
  end;
end;
{$ENDIF}

procedure TfmPDFview.settimer(T: boolean);
begin
  AniIndicator1.style := TAniindicatorstyle.aiCircular;
  if T = true then
  begin
    AniIndicator1.Enabled := true;
    AniIndicator1.Visible := true;
    AniIndicator1.StartTriggerAnimation(self, '');
  end;
  if T = false then
  begin
    AniIndicator1.Enabled := false;
    AniIndicator1.Visible := false;
  end;
end;

procedure TfmPDFview.SpeedButton1Click(Sender: TObject);
var
  flength, flength1: integer;
  i: integer;
  StStream: TStringStream;
  ConvertedFile: string;
  js: string;
  MIMEEncoder: TidEncoderMime;
begin
  WebBrowser1.Reload; // reload to free Ram
  Edit1.text := '';
  OpenDialog1.Filter := 'PDF Files (*.pdf)|*.pdf';
  if not CheckBox1.ischecked then
  begin
    if OpenDialog1.Execute then // will not like large files

      try
        Edit1.text := OpenDialog1.FileName;
        // StringStream works faster than Filestream  or Bufferedfilestream
        // TStringStream will not open files with a size close to a gigabyte and greater
        // A third party library replacement will be required to perform this
        StStream := TStringStream.Create('');
        StStream.LoadFromFile(OpenDialog1.FileName);
        SendFileinfo := StStream.DataString;
        flength := 0;
        flength1 := 0;
        if Length(StStream.DataString) <> 0 then
          repeat
            flength1 := flength;
            flength := Length(StStream.DataString);
          until flength = flength1;
      finally
        if Length(SendFileinfo) = Length(StStream.DataString) then
          StStream.free;
      end;
    Base64encode(self);

    if Timer1.Enabled then
      Timer1.Enabled := false;
    settimer(false);
    LoadBrowser(self);
  end

  else
  begin
    Edit1.text := 'Embedded Base64 encoded File ';
    Datajs := '';
    Datajs := Embeddedfile;
    Timer2.Enabled := true;
  end;
end;

procedure TfmPDFview.SpeedButton2Click(Sender: TObject);
var
  js: string;
begin
  SpeedButton2.Enabled := false;
  SpeedButton3.Enabled := false;
  js := 'PriorPage("' + ConvertedFile + '")';
  WebBrowser1.EvaluateJavaScript(js);
  Timer3.Enabled := true;
end;

procedure TfmPDFview.SpeedButton3Click(Sender: TObject);
var
  js: string;
begin
  SpeedButton2.Enabled := false;
  SpeedButton3.Enabled := false;

  js := 'NextPage("' + ConvertedFile + '")';
  WebBrowser1.EvaluateJavaScript(js);
  Timer3.Enabled := true;
end;

function TfmPDFview.Embeddedfile: string;
var
  js: string;
begin
  SpeedButton2.Enabled := false;
  SpeedButton3.Enabled := false;
  js := 'var pdfData = atob("' +
    'JVBERi0xLjcKCjEgMCBvYmogICUgZW50cnkgcG9pbnQKPDwKICAvVHlwZSAvQ2F0YWxvZwog' +

    'IC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAv' +

    'TWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0K' +

    'Pj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAg' +

    'L1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSIAogICAgPj4KICA+' +

    'PgogIC9Db250ZW50cyA1IDAgUgo+PgplbmRvYmoKCjQgMCBvYmoKPDwKICAvVHlwZSAvRm9u' +

    'dAogIC9TdWJ0eXBlIC9UeXBlMQogIC9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2Jq' +

    'Cgo1IDAgb2JqICAlIHBhZ2UgY29udGVudAo8PAogIC9MZW5ndGggNDQKPj4Kc3RyZWFtCkJU' +

    'CjcwIDUwIFRECi9GMSAxMiBUZgooSGVsbG8sIHdvcmxkISkgVGoKRVQKZW5kc3RyZWFtCmVu' +

    'ZG9iagoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDEwIDAwMDAwIG4g' +

    'CjAwMDAwMDAwNzkgMDAwMDAgbiAKMDAwMDAwMDE3MyAwMDAwMCBuIAowMDAwMDAwMzAxIDAw' +

    'MDAwIG4gCjAwMDAwMDAzODAgMDAwMDAgbiAKdHJhaWxlcgo8PAogIC9TaXplIDYKICAvUm9v' +

    'dCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G' + '");' +

  // 'alert(pdfData);'+

    ' PDFJS.workerSrc = "pdf.worker.js"; ' +
    '  PDFJS.getDocument({data: pdfData}).then(function getPageDelphiEmbed(pdf) {  '
    +
  // Fetch the first page.
    ' pdf.getPage(1).then(function getPageDelphiEmbed(page) {  ' +
    ' document.getElementById("page_num").textContent = 1;    ' +
    ' document.getElementById("page_count").textContent = 1;' +
    '  var scale = 4.8;' + ' var viewport = page.getViewport(scale); ' +
  // Prepare canvas using PDF page dimensions.
    '   var canvas = document.getElementById("the-canvas"); ' +
    '   var context = canvas.getContext("2d");' +
    '   canvas.height = viewport.height;' +
    '   canvas.width = viewport.width;' +
  // Render PDF page into canvas context.
    '   var renderContext = {      ' + '    canvasContext: context,' +
    '   viewport: viewport' + ' }; ' + ' page.render(renderContext); ' + ' }); '
    + ' }); ';

  result := js;
end;

procedure TfmPDFview.eval(Sender: TObject; js: string);
begin
  WebBrowser1.EvaluateJavaScript(js);
end;

procedure TfmPDFview.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  settimer(true);
end;

procedure TfmPDFview.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := false;
  eval(self, Datajs);
end;

procedure TfmPDFview.Timer3Timer(Sender: TObject);
begin
  Timer3.Enabled := false;
  SpeedButton2.Enabled := true;
  SpeedButton3.Enabled := true;
end;

end.
