unit Config;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Variants, Vcl.Forms, IniFiles,
  System.Rtti,
  MyUtils, Migration;

type
  TConfig = class
  private
    class procedure CreateFile(Path: string);
    class function Source: string;
  public
    class function GetConfig(const Section, Name: string; Default: string = ''): string;
    class procedure SetConfig(const Section, Name: string; Value: string = '');

    class procedure SetGeral(Config: TMigrationConfig);
    class procedure GetGeral(var Config: TMigrationConfig);
  end;

implementation

{ TConfigs }

class procedure TConfig.CreateFile(Path: string);
var
  Arq: TIniFile;
begin
  Arq := TIniFile.Create(Path);
  try
    Arq.WriteString('SOURCE', 'User', 'SYSDBA');
    Arq.WriteString('SOURCE', 'Password', 'masterkey');
    Arq.WriteString('SOURCE', 'Database', '');
    Arq.WriteString('SOURCE', 'Version', '0');

    Arq.WriteString('DEST', 'Database', '');
    Arq.WriteString('DEST', 'Version', '0');
  finally
    FreeAndNil(Arq);
  end;
end;

//Caminho das configura��es
class function TConfig.Source: string;
begin
  Result := TUtils.Temp + 'FirebirdMigrator\' + 'Config.ini';

  if not FileExists(Result) then
  begin
    if not DirectoryExists(ExtractFileDir(Result)) then
    begin
      CreateDir(ExtractFileDir(Result));
    end;

    CreateFile(Result);
  end;
end;

//Busca uma configura��o espec�fica
class function TConfig.GetConfig(const Section, Name: string; Default: string = ''): string;
var
  Arq: TIniFile;
begin
  Arq := TIniFile.Create(Source);

  try
    Result := Arq.ReadString(Section, Name, Default);
  finally
    FreeAndNil(Arq);
  end;
end;

//Define uma configura��o espec�fica
class procedure TConfig.SetConfig(const Section, Name: string; Value: string = '');
var
  Arq: TIniFile;
begin
  Arq := TIniFile.Create(Source);
  try
    Arq.WriteString(Section, Name, Value);
  finally
    FreeAndNil(Arq);
  end;
end;

class procedure TConfig.SetGeral(Config: TMigrationConfig);
begin
  with Config.Source do
  begin
    SetConfig('SOURCE', 'User', User);
    SetConfig('SOURCE', 'Password', Password);
    SetConfig('SOURCE', 'Database', Database);
    SetConfig('SOURCE', 'Version', Integer(Version).ToString);
  end;

  with Config.Dest do
  begin
    SetConfig('DEST', 'Database', Database);
    SetConfig('DEST', 'Version', Integer(Version).ToString);
  end;
end;

class procedure TConfig.GetGeral(var Config: TMigrationConfig);
begin
  with Config.Source do
  begin
    User := GetConfig('SOURCE', 'User', 'SYSDBA');
    Password := GetConfig('SOURCE', 'Password', 'masterkey');
    Database := GetConfig('SOURCE', 'Database', '');
    Version := TVersion(GetConfig('SOURCE', 'Version', '0').ToInteger);
  end;

  with Config.Dest do
  begin
    Database := GetConfig('DEST', 'Database', '');
    Version := TVersion(GetConfig('DEST', 'Version', '0').ToInteger);
  end;
end;

end.
