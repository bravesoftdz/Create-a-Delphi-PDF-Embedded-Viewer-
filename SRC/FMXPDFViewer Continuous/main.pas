unit main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.WebBrowser, FMX.Controls.Presentation ,System.Threading,system.netencoding,
   IdCoder3to4, ICoderMIME, FMX.ScrollBox, FMX.Memo, IDGLobal,
  FMX.Edit, FMX.Layouts,IdBaseComponent, IdCoder
   {$IFDEF MSWINDOWS}
  ,System.Win.Registry

  {$ENDIF}
  ;

  Var
   ConvertedFile:string ;
   SendFileinfo:string ;
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
    CheckBox1: TCheckBox;
    Timer2: TTimer;
    WebBrowser1: TWebBrowser;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure OpenDialog1Show(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    private
    Datajs:string;
    procedure eval(Sender:TObject;js:string);
    function Embeddedfile:string;
    procedure LoadBrowser(Sender:TObject);
    procedure Base64encode(Sender:Tobject);
         {$IFDEF MSWINDOWS}
    procedure SetPermissions;
    {$ENDIF}
    public
    procedure settimer(T:boolean);
     { Public declarations }
    end;

var
  fmPDFview: TfmPDFview;

 implementation

 {$R *.fmx}

procedure TfmPDFview.LoadBrowser(Sender: TObject);
var
js:string;
begin
 js:= 'externalPDF("' +Convertedfile+ '",1);';

 webbrowser1.EvaluateJavaScript(js);
 end;

procedure TfmPDFview.OpenDialog1Show(Sender: TObject);
begin
   Timer1.Enabled:= true;;
end;

procedure TfmPDFview.Base64encode(Sender: Tobject);
var
MIMEEncoder:TidEncoderMime;
begin
try
  MimeEncoder:= TIdEncoderMime.Create(nil);
Convertedfile:= MimeEncoder.encodestring(Sendfileinfo,IDGlobal.IndyTextEncoding_OSDefault);
  finally
   MimeEncoder.free;
  end;
end;

 procedure TfmPDFview.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  SetPermissions;
{$ENDIF}
sendfileinfo:= '';
//load the javascript pdfviewer
WebBrowser1.URL := 'file://' + GetCurrentDir +
  '/../../binarypdf/PDFjsindex.html';
  SetTimer(false);
  aniindicator1.Enabled:=false;
  aniIndicator1.Visible:= false;

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
    if Reg.OpenKey(cFeatureBrowserEmulation, True) and
      not(TRegistry(Reg).KeyExists(sKey) and (TRegistry(Reg).ReadInteger(sKey)
      = cIE11)) then
      TRegistry(Reg).WriteInteger(sKey, cIE11);
  finally
    Reg.Free;
  end;
 {$ENDIF}
end;

 procedure TfmPDFview.SetTimer(T:Boolean);
begin
 aniIndicator1.style:= TAniindicatorstyle.aiCircular;
if T = True then
begin
  aniindicator1.Enabled:=true;
   aniIndicator1.Visible:= true;
   aniindicator1.StartTriggerAnimation(self,'');
  end;
if T = false then
begin
 aniindicator1.Enabled:=false;
   aniIndicator1.Visible:= false;
  end;
end;

procedure TfmPDFview.SpeedButton1Click(Sender: TObject);
 var
    flength,flength1:integer;
    value: Integer;
    i:integer;
   StStream: TStringStream;
ConvertedFile:string;
MIMEEncoder:TidEncoderMime;

begin
 webbrowser1.Reload;  //reload to free Ram

 if not checkbox1.ischecked then
 begin
      if opendialog1.Execute then   // will not like large files

     try
   edit1.Text:= opendialog1.FileName;
   //StringStream works faster than Filestream  or Bufferedfilestream
   //TStringStream will not open files with a size close to a gigabyte and greater
   // A third party library replacement will be required to perform this
  StStream := TStringStream.Create('');
  StStream.LoadFromFile(opendialog1.filename);
  sendfileinfo:= StStream.DataString;
  flength:= 0;
  flength1:=0;
  if Length(StStream.Datastring) <> 0 then
   repeat
   flength1:= flength;
   flength:=  Length(StStream.datastring);
    until
   flength = flength1;
     finally
   if length(sendfileinfo) = Length(Ststream.DataString) then
   StStream.free;
  end;

   Base64encode(Self);
   if timer1.Enabled then
   timer1.Enabled:= false;
   setTimer(false);

  LoadBrowser(Self);
 end

 else
 begin
   edit1.Text:= 'Embedded Base64 encoded File ';
   DataJs:= '';
  DataJS:= Embeddedfile ;
   Timer2.Enabled:= true;
   end;

end;

function TfmPDFview.Embeddedfile:string;
var
js:string;
begin

 js:=
     'var pdfData = atob("'+
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

    'dCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G'+
    '");'+

 // 'alert(pdfData);'+

  ' PDFJS.workerSrc = "pdf.worker.js"; '+
  '  PDFJS.getDocument({data: pdfData}).then(function getPageDelphiEmbed(pdf) {  '+
        // Fetch the first page.
      ' pdf.getPage(1).then(function getPageDelphiEmbed(page) {  '+
     // ' document.getElementById("page_num").textContent = 1;    '  +
       ' document.getElementById("page_count").textContent = 1;'+
          '  var scale = 4.8;' +
       ' var viewport = page.getViewport(scale); '+
          // Prepare canvas using PDF page dimensions.
       '   var canvas = document.getElementById("the-canvas"); '+
       '   var context = canvas.getContext("2d");'+
       '   canvas.height = viewport.height;'+
       '   canvas.width = viewport.width;'+
          // Render PDF page into canvas context.
        '   var renderContext = {      '+
         '    canvasContext: context,'+
         '   viewport: viewport'+
        ' }; '+
        ' page.render(renderContext); '+
       ' }); '+
    ' }); ';

   result:= js;
 end;

procedure TfmPDFview.eval(Sender:Tobject;js:string);
begin
 webbrowser1.EvaluateJavaScript(js);
end;

procedure TfmPDFview.Timer1Timer(Sender: TObject);
begin
timer1.Enabled:= false;
      Settimer(true);
end;

procedure TfmPDFview.Timer2Timer(Sender: TObject);
begin
timer2.Enabled:= false;
    eval(self,Datajs);
end;

end.
