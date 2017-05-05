{ *************************************************************************** }
{ }
{ }
{ Copyright (C) Amarildo Lacerda }
{ }
{ https://github.com/amarildolacerda }
{ }
{ }
{ *************************************************************************** }
{ }
{ Licensed under the Apache License, Version 2.0 (the "License"); }
{ you may not use this file except in compliance with the License. }
{ You may obtain a copy of the License at }
{ }
{ http://www.apache.org/licenses/LICENSE-2.0 }
{ }
{ Unless required by applicable law or agreed to in writing, software }
{ distributed under the License is distributed on an "AS IS" BASIS, }
{ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{ See the License for the specific language governing permissions and }
{ limitations under the License. }
{ }
{ *************************************************************************** }
{  Altera��es:
     05/05/2017 - trocado o objeto TJsonBoolean para compatiblidade com XE8; por: Wolnei Sim�es
}
unit System.Json.Helper;

interface

uses System.Classes, System.Types, System.SysUtils,
  System.TypInfo, System.Json,
  System.Generics.collections, System.Classes.Helper,
  RegularExpressions {$IFNDEF BPL}, DBXJsonReflect{$ENDIF};

type

  TJsonRecord<T: Record > = class
  public
    class function ToJson(O: T): string;
    class procedure FromJson(O: T; AJson: string);
  end;

type

  TJsonType = (jtUnknown, jtObject, jtArray, jtString, jtTrue, jtFalse,
    jtNumber, jtDate, jtDateTime, jtBytes, jtNull);

  TMemberVisibilitySet = set of TMemberVisibility;

  IJsonObject = interface
    ['{62E97901-D27A-460E-B0AF-0640874360D7}']
    function GetValueBase(chave: string): string;
    procedure SetValueBase(chave: string; const Value: string);
    function Parse(AJson: string): IJsonObject;
    function Json: TJsonValue;
    function JSONObject: TJSONObject;
    function JsonValue: TJsonValue;
    function isNull: boolean;
    function AsArray: TJsonArray;
    function addPair(AKey, AValue: string): TJSONObject;overload;
    function addPair(AKey:string; AValue: TJsonValue): TJSONObject;overload;
    function AddChild(AKey, AJson: string): TJSONObject;
    function ToJson: string;
    function Contains(AKey: string): boolean;
    property Value[chave: string]: string read GetValueBase write SetValueBase;
  end;

  TInterfacedJSON = class(TInterfacedObject, IJsonObject)
  private
    FInstanceOwned: boolean;
    function GetValueBase(chave: string): string;
    procedure SetValueBase(chave: string; const Value: string);
  protected
    FJson: TJsonValue;
  public
    constructor create(AJson: string); overload;
    constructor create; overload;
    destructor destroy; override;
    class function New(AJson: string): IJsonObject; overload;
    class function New: IJsonObject; overload;
    class function New(AJson: TJsonValue; AOwned: boolean): IJsonObject;
      overload; static;
    class function GetJsonType(AJsonValue: TJsonPair): TJsonType;
      overload; static;
    class function GetJsonType(AJsonValue: TJsonValue): TJsonType;
      overload; static;
    function Parse(AJson: string): IJsonObject;
    function Json: TJsonValue;
    function JSONObject: TJSONObject;
    function JsonValue: TJsonValue;
    function AsArray: TJsonArray;
    function isNull: boolean;
    function addPair(AKey, AValue: string): TJSONObject;overload;
    function addPair(AKey:string; AValue: TJsonValue): TJSONObject;overload;
    function AddChild(AKey, AJson: string): TJSONObject;
    function ToJson: string;
    function Contains(AKey: string): boolean;
    property Value[chave: string]: string read GetValueBase write SetValueBase;
  end;

  TJSONObjectHelper = class helper for TJSONObject
  private
    function GetValueBase(chave: string): string;
    procedure SetValueBase(chave: string; const Value: string);

  public
{$IFDEF VER270}
    function ToJson: string;
{$ENDIF}
    class function GetTypeAsString(AType: TJsonType): string; static;
    class function GetJsonType(AJsonValue: TJsonValue): TJsonType; static;
    class function Stringify(so: TJSONObject): string;
    class function Parse(const dados: string): TJSONObject;
    constructor create(AKey, AValue: String); overload;
    function V(chave: String): variant;
    function S(chave: string): string;
    function I(chave: string): integer;
    function O(chave: string): TJSONObject; overload;
    function O(index: integer): TJSONObject; overload;
    function F(chave: string): Extended;
    function B(chave: string): boolean;
    function A(chave: string): TJsonArray;
    function AsArray: TJsonArray;
    function Contains(chave: string): boolean;
    function Find(chave: string): TJsonValue; virtual;

{$IFNDEF BPL}
    function asObject: System.TObject;
    class function FromRecord<T>(rec: T): TJSONObject;
{$ENDIF}
    class function FromObject<T>(AObject: T;
      AVisibility: TMemberVisibilitySet = [mvPublic, mvPublished])
      : TJSONObject; overload;
{$IFDEF CompilerVersion<=30}
    function addPair(chave: string; Value: string): TJSONObject; overload;
{$ENDIF}
    function addPair(chave: string; Value: integer): TJSONObject; overload;
    function addPair(chave: string; Value: Double): TJSONObject; overload;
    function addPair(chave: string; Value: TDatetime): TJSONObject; overload;
    property Value[chave: string]: string read GetValueBase write SetValueBase;
    function Coalesce(chave: string; Value: string): TJsonPair;
    // procedure FromRecord<T :record>(rec:T);
  end;

  TJSONArrayHelper = class helper for TJsonArray
  public
    function Length: integer;
    function Find(AJson: string): TJSONObject;
  end;

  TJsonValuesList = class(TObjectList<TJsonPair>)
  private
    function GetNames(AName: string): TJsonPair;
    procedure SetNames(AName: string; const Value: TJsonPair);
  public
    property Names[AName: string]: TJsonPair read GetNames write SetNames;
  end;

  TJSONValueHelper = class helper for TJsonValue
  private
  public
{$IFDEF VER270}
    function ToJson: string;
{$ENDIF}
    class Function New(AKey, AValue: String): TJsonValue;
    procedure addPair(AKey, AValue: string);
    function ToRecord<T>: T; overload;
    function ToRecord<T: Record >(var ARec: T): T; overload;
    class function ToRecord<T: record >(AJson: string): T; overload; static;
    class procedure GetRecordList<T: record >(AList: TJsonValuesList; ARec: T);
    function AsArray: TJsonArray;
    function AsPair: TJsonPair;
    function Datatype: TJsonType;
    function asObject: TJSONObject;
    function AsInteger: integer;
    function AsString: string;
  end;

  TJSONPairHelper = class helper for TJsonPair
  public
    function asObject: TJSONObject;
  end;

  IJson = TJSONObject;
  IJSONArray = TJsonArray;

  TJson = TJSONObject;

function ReadJsonString(const dados: string; chave: string): string;
function ReadJsonInteger(const dados: string; chave: string): integer;
function ReadJsonFloat(const dados: string; chave: string): Extended;
// function ReadJsonObject(const dados: string): IJson;
function JSONstringify(so: IJson): string;
function JSONParse(const dados: string): IJson;

function ISODateTimeToString(ADateTime: TDatetime): string;
function ISODateToString(ADate: TDatetime): string;
function ISOTimeToString(ATime: TTime): string;

function ISOStrToDateTime(DateTimeAsString: string): TDatetime;
function ISOStrToDate(DateAsString: string): TDate;
function ISOStrToTime(TimeAsString: string): TTime;
function JSONStoreError(msg: string): TJsonValue;

implementation

uses db, System.Rtti, System.DateUtils (*{$ifndef BPL}, Rest.JSON{$endif}*);

class procedure TJsonRecord<T>.FromJson(O: T; AJson: string);
var
  js: TJSONObject;
  AContext: TRttiContext;
  AField: TRttiField;
  ARecord: TRttiRecordType;
  AFldName: String;
  AValue: TValue;
begin
  js := TJSONObject.ParseJSONValue(AJson) as TJSONObject;
  try
    AContext := TRttiContext.create;
    try
      ARecord := AContext.GetType(TypeInfo(T)).AsRecord;
      for AField in ARecord.GetFields do
      begin
        AFldName := AField.Name;
        AValue := js.GetValue(AFldName);
        AField.SetValue(@O, AValue);
      end;

    finally
      AContext.free;
    end;

  finally
    js.free;
  end;
end;

class function TJsonRecord<T>.ToJson(O: T): string;
var
  AContext: TRttiContext;
  AField: TRttiField;
  ARecord: TRttiRecordType;
  AFldName: String;
  AValue: TValue;
  ArrFields: TArray<TRttiField>;
  I: integer;
  js: TJSONObject;
begin
  js := TJSONObject.create;
  AContext := TRttiContext.create;
  try
    ARecord := AContext.GetType(TypeInfo(T)).AsRecord;
    ArrFields := ARecord.GetFields;
    I := 0;
    for AField in ArrFields do
    begin
      AFldName := AField.Name;
      AValue := AField.GetValue(@O);
      try
        if AValue.IsEmpty then
          js.addPair(AFldName, 'NULL')
        else
          case AField.FieldType.TypeKind of
            tkInteger, tkInt64:
              try
                js.addPair(AFldName, TJSONNumber.create(AValue.AsInt64));
              except
                js.addPair(AFldName, TJSONNumber.create(0));
              end;
            tkEnumeration:
              js.addPair(AFldName, TJSONNumber.create(AValue.AsInteger));
            tkFloat:
              begin
                if AField.FieldType.ToString.Equals('TDateTime') then
                  js.addPair(AFldName, FormatDateTime('yyyy-mm-dd HH:nn:ss',
                    AValue.AsExtended))
                else if AField.FieldType.ToString.Equals('TDate') then
                  js.addPair(AFldName, FormatDateTime('yyyy-mm-dd',
                    AValue.AsExtended))
                else if AField.FieldType.ToString.Equals('TTime') then
                  js.addPair(AFldName, FormatDateTime('HH:nn:ss',
                    AValue.AsExtended))
                else
                  try
                    js.addPair(AFldName, TJSONNumber.create(AValue.AsExtended));
                  except
                    js.addPair(AFldName, TJSONNumber.create(0));
                  end;
              end
          else
            js.addPair(AFldName, AValue.AsString)
          end;
      except
        js.addPair(AFldName, 'NULL')
      end;

    end;
    result := js.ToString;
  finally
    js.free;
    AContext.free;
  end;

end;

var
  LJson: TJson;

type
  TValueHelper = record helper for TValue
  private
    function IsNumeric: boolean;
    function IsFloat: boolean;
    function IsBoolean: boolean;
    function IsDate: boolean;
    function IsDateTime: boolean;
    function IsDouble: boolean;
    function IsInteger: boolean;
  end;

function TValueHelper.IsNumeric: boolean;
begin
  result := Kind in [tkInteger, tkChar, tkEnumeration, tkFloat,
    tkWChar, tkInt64];
end;

function TValueHelper.IsFloat: boolean;
begin
  result := Kind = tkFloat;
end;

function TValueHelper.IsBoolean: boolean;
begin
  result := TypeInfo = System.TypeInfo(boolean);
end;

function TValueHelper.IsDate: boolean;
begin
  result := TypeInfo = System.TypeInfo(TDate);
end;

function TValueHelper.IsDateTime: boolean;
begin
  result := TypeInfo = System.TypeInfo(TDatetime);
end;

function TValueHelper.IsDouble: boolean;
begin
  result := TypeInfo = System.TypeInfo(Double);
end;

function TValueHelper.IsInteger: boolean;
begin
  result := TypeInfo = System.TypeInfo(integer);
end;

class function TJSONObjectHelper.GetTypeAsString(AType: TJsonType): string;
begin
  case AType of
    jtUnknown:
      result := 'Unknown';
    jtString:
      result := 'String';
    jtTrue, jtFalse:
      result := 'Boolean';
    jtNumber:
      result := 'Extended';
    jtDate:
      result := 'TDate';
    jtDateTime:
      result := 'TDateTime';
    jtBytes:
      result := 'Byte';
  end;
end;

function TJSONObjectHelper.GetValueBase(chave: string): string;
begin
  result := S(chave);
end;

class function TJSONObjectHelper.GetJsonType(AJsonValue: TJsonValue): TJsonType;
var
  LJsonString: TJSONString;
begin
  if AJsonValue is TJSONNull then
    result := jtNull
  else if AJsonValue is TJSONObject then
    result := jtObject
  else if AJsonValue is TJsonArray then
    result := jtArray
  else if (AJsonValue is TJSONNumber) then
    result := jtNumber
  else if AJsonValue is TJSONTrue then
    result := jtTrue
  else if AJsonValue is TJSONFalse then
    result := jtFalse
  else if AJsonValue is TJSONString then
  begin
    LJsonString := (AJsonValue as TJSONString);
    if TRegEx.IsMatch(LJsonString.Value,
      '^([0-9]{4})-?(1[0-2]|0[1-9])-?(3[01]|0[1-9]|[12][0-9])(T| )(2[0-3]|[01][0-9]):?([0-5][0-9]):?([0-5][0-9])$')
    then
      result := jtDateTime
    else if TRegEx.IsMatch(LJsonString.Value,
      '^([0-9]{4})(-?)(1[0-2]|0[1-9])\2(3[01]|0[1-9]|[12][0-9])$') then
      result := jtDate
    else
      result := jtString
  end
  else
    result := jtUnknown;
end;

function JSONParse(const dados: string): IJson;
begin
  result := TJSONObject.ParseJSONValue(dados) as IJson;
end;

function JSONstringify(so: IJson): string;
begin
  result := so.ToJson;
end;

function ReadJsonFloat(const dados: string; chave: string): Extended;
var
  I: IJson;
begin
  I := JSONParse(dados);
  try
    I.TryGetValue<Extended>(chave, result);
  finally
    I.free;
  end;
end;

function ReadJsonString(const dados: string; chave: string): string;
var
  j: TJson;
  I: IJson;
  V: string;
begin
  j := JSONParse(dados);
  // usar variavel local para n�o gerar conflito com Multi_threaded application
  try
    j.TryGetValue<string>(chave, V);
    result := V;
    { case VarTypeToDataType of
      varString: Result := I.S[chave];
      varInt64: Result := IntToStr(I.I[chave]);
      varDouble,varCurrency: Result := FloatToStr(I.F[chave]);
      varBoolean: Result := BoolToStr(  I.B[chave] );
      varDate: Result := DateToStr(I.D[chave]);
      else
      result :=  I.V[chave];
      end; }
  finally
    j.free;
  end;
end;

(* function ReadJsonObject(const dados: string; chave: string): IJson;
  var
  j: TJson;
  begin
  result := JSONParse(dados);
  { // usar variavel local para n�o gerar conflito com Multi_threaded application
  try
  result := j.parse(dados);
  finally
  j.Free;
  end;}
  end;
*)
function ReadJsonInteger(const dados: string; chave: string): integer;
var
  j: TJson;
  I: IJson;
begin
  j := JSONParse(dados);
  // usar variavel local para n�o gerar conflito com Multi_threaded application
  try
    j.TryGetValue<integer>(chave, result);
  finally
    j.free;
  end;
end;

{$IFNDEF MULTI_THREADED}

function Json: TJson;
begin
  if not assigned(LJson) then
    LJson := TJson.create;
  result := LJson;
end;

procedure JSONFree;
begin
  if assigned(LJson) then
    FreeAndNil(LJson);
end;
{$ENDIF}
{ TJSONObjectHelper }

function TJSONObjectHelper.A(chave: string): TJsonArray;
begin
  // result := TJsonArray.Create;
  TryGetValue<TJsonArray>(chave, result);
end;

{$IFDEF CompilerVersion<=30}

function TJSONObjectHelper.addPair(chave: string; Value: string)
  : TJSONObject; overload;
var
  pair: TJsonPair;
begin
  pair := TJsonPair.create(chave, Value);
  self.add(pair);
end;
{$ENDIF}

function TJSONObjectHelper.addPair(chave: string; Value: integer): TJSONObject;
begin
  result := addPair(chave, TJSONNumber.create(Value));
end;

function TJSONObjectHelper.addPair(chave: string; Value: Double): TJSONObject;
begin
  result := addPair(chave, TJSONNumber.create(Value));
end;

function TJSONObjectHelper.addPair(chave: string; Value: TDatetime)
  : TJSONObject;
var
  S: string;
begin
  if trunc(Value) <> Value then
    S := ISODateTimeToString(Value)
  else
    S := ISODateToString(Value);
  result := addPair(chave, S);
end;

function TJSONObjectHelper.AsArray: TJsonArray;
begin
  result := TJSONObject.ParseJSONValue(self.ToJson) as TJsonArray;
end;

function TJSONObjectHelper.B(chave: string): boolean;
begin
  TryGetValue<boolean>(chave, result);
end;

function TJSONObjectHelper.Coalesce(chave, Value: string): TJsonPair;
begin
  if not Contains(chave) then
    addPair(chave, Value); // se nao existe, adiciona;
  result := Get(chave);
end;

function TJSONObjectHelper.Contains(chave: string): boolean;
var
  LJSONValue: TJsonValue;
begin
  LJSONValue := FindValue(chave);
  result := LJSONValue <> nil;
end;

constructor TJSONObjectHelper.create(AKey, AValue: String);
begin
  inherited create(TJsonPair.create(AKey, AValue));
end;

function TJSONObjectHelper.F(chave: string): Extended;
begin
  result := 0;
  if FindValue(chave) <> nil then
    TryGetValue<Extended>(chave, result);
end;

function TJSONObjectHelper.Find(chave: string): TJsonValue;
begin
  result := inherited FindValue(chave);
end;

function TJSONObjectHelper.I(chave: string): integer;
begin
  result := 0;
  if FindValue(chave) <> nil then
    TryGetValue<integer>(chave, result);
end;

function TJSONObjectHelper.O(index: integer): TJSONObject;
var
  pair: TJsonPair;
begin
  result := TJSONObject(Get(index));
end;

function TJSONObjectHelper.O(chave: string): TJSONObject;
var
  V: TJsonValue;
begin
  V := GetValue(chave);
  result := V as TJSONObject;
  // TryGetValue<TJSONObject>(chave, result);
end;

class function TJSONObjectHelper.Parse(const dados: string): TJSONObject;
begin
  result := TJSONObject.ParseJSONValue(dados) as TJSONObject;
end;

{$IFNDEF BPL}

class function TJSONObjectHelper.FromRecord<T>(rec: T): TJSONObject;
var
  m: TJSONMarshal;
  js: TJsonValue;
begin
  result := TJSONObject.FromObject<T>(rec);
end;
{$ENDIF}

class function TJSONObjectHelper.FromObject<T>(AObject: T;
  AVisibility: TMemberVisibilitySet): TJSONObject;
var
  typ: TRttiType;
  ctx: TRttiContext;
  field: TRttiField;
  tk: TTypeKind;
  P: Pointer;
  key: String;
  FRecord: TRttiRecordType;
  FMethod: TRttiMethod;
  LAttr: TCustomAttribute;
  LContinue: boolean;
begin
  result := TJSONObject.create;
  ctx := TRttiContext.create;
  typ := ctx.GetType(TypeInfo(T));
  P := @AObject;
  for field in typ.GetFields do
  begin
    try
      LContinue := true;
      for LAttr in field.GetAttributes do
      begin
        if LAttr is HideAttribute then
          LContinue := false;
      end;
      if not LContinue then
        continue;

      key := field.Name.ToLower;
      if not(field.Visibility in AVisibility) then
        continue;

      tk := field.FieldType.TypeKind;
      case tk of
        tkRecord:
          begin
            (* FRecord := ctx.GetType(field.GetValue(P).TypeInfo).AsRecord ;
              FMethod := FRecord.GetMethod('asJson');
              if assigned(FMethod) then
              begin
              result.AddPair(key,fMethod.asJson );
              end; *)
          end;
        tkInteger:
          result.addPair(key, TJSONNumber.create(field.GetValue(P).AsInteger));
        tkFloat:
          begin // System.Classes.Helper
            if sametext(field.FieldType.Name, 'TDateTime') then
              result.addPair(TJsonPair.create(key,
                ISODateTimeToString(field.GetValue(P).AsExtended)))
            else if sametext(field.FieldType.Name, 'TDate') then
              result.addPair(TJsonPair.create(key,
                ISODateToString(field.GetValue(P).AsExtended)))
            else if sametext(field.FieldType.Name, 'TTime') then
              result.addPair(TJsonPair.create(key,
                ISOTimeToString(field.GetValue(P).AsExtended)))
            else if sametext(field.FieldType.Name, 'TTimeStamp') then
              result.addPair(TJsonPair.create(key,
                ISODateTimeToString(field.GetValue(P).AsExtended)))
            else
              result.addPair(key,
                TJSONNumber.create(field.GetValue(P).AsExtended));
          end
      else
        result.addPair(TJsonPair.create(key, field.GetValue(P).ToString));
      end;
    except
    end;
  end;

end;

function TJSONObjectHelper.S(chave: string): string;
begin
  TryGetValue<string>(chave, result);
end;

procedure TJSONObjectHelper.SetValueBase(chave: string; const Value: string);
var
  V: TJsonPair;
begin
  V := Get(chave);
  if not assigned(V) then
    addPair(chave, Value)
  else
  begin
    V.JsonValue := TJSONString.create(Value);
  end;
end;

class function TJSONObjectHelper.Stringify(so: TJSONObject): string;
begin
  result := so.ToJson;
end;

class function TJSONValueHelper.ToRecord<T>(AJson: string): T;
var
  j: TJsonValue;
begin
  j := TJSONObject.ParseJSONValue(AJson);
  try
    result := (j).ToRecord<T>;
  finally
    j.free;
  end;
end;

function TJSONValueHelper.ToRecord<T>(var ARec: T): T;
var
  AContext: TRttiContext;
  ARecord: TRttiRecordType;
  AField: TRttiField;
  AJsonValue: TJsonPair;
  AValue: TValue;
  AFieldName: String;
  j: TJSONObject;
begin
  AContext := TRttiContext.create;
  try

    ARecord := AContext.GetType(TypeInfo(T)).AsRecord;
    j := self as TJSONObject;
    for AField in ARecord.GetFields do
    begin
      try
        AFieldName := lowercase(AField.Name);
        if FindValue(AFieldName) = nil then
          continue;
        AJsonValue := j.Get(AFieldName);

        case AField.FieldType.TypeKind of
          tkFloat: // Also for TDateTime !
            begin
              if sametext(AField.FieldType.Name, 'TDateTime') then
                AValue := ISOStrToDateTime(AJsonValue.JsonValue.Value)
              else if sametext(AField.FieldType.Name, 'TTime') then
                AValue := ISOStrToTime(AJsonValue.JsonValue.Value)
              else
                AValue := StrToFloatDef(AJsonValue.JsonValue.Value, 0);
              AField.SetValue(@ARec, AValue);
            end;
          tkInteger:
            begin
              AValue := AJsonValue.JsonValue.Value;
              AField.SetValue(@ARec, AValue);
            end;
          tkUString, tkLString:
            begin
              AValue := AJsonValue.JsonValue.Value;
              AField.SetValue(@ARec, AValue);
            end;
        else
          if sametext(AField.FieldType.Name, 'Boolean') then
          begin
            AValue := sametext(AJsonValue.JsonValue.Value, 'true');
            AField.SetValue(@ARec, AValue);
          end;
          // You should add other types as well
        end;
      except
      end;
    end;
  finally
    AContext.free;
  end;
  result := ARec;

end;

function TJSONValueHelper.ToRecord<T>(): T;
var
  AContext: TRttiContext;
  ARecord: TRttiRecordType;
  AField: TRttiField;
  AJsonValue: TJsonPair;
  AValue: TValue;
  AFieldName: String;
  j: TJSONObject;
begin
  AContext := TRttiContext.create;
  try
    ARecord := AContext.GetType(TypeInfo(T)).AsRecord;
    j := self as TJSONObject;
    for AField in ARecord.GetFields do
    begin
      try
        AFieldName := lowercase(AField.Name);
        if FindValue(AFieldName) = nil then
          continue;
        AJsonValue := j.Get(AFieldName);

        case AField.FieldType.TypeKind of
          tkFloat: // Also for TDateTime !
            begin
              if sametext(AField.FieldType.Name, 'TDateTime') then
                AValue := ISOStrToDateTime(AJsonValue.JsonValue.Value)
              else if sametext(AField.FieldType.Name, 'TTime') then
                AValue := ISOStrToTime(AJsonValue.JsonValue.Value)
              else
                AValue := StrToFloatDef(AJsonValue.JsonValue.Value, 0);
              AField.SetValue(@result, AValue);
            end;
          tkInteger:
            begin
              AValue := AJsonValue.JsonValue.Value;
              AField.SetValue(@result, AValue);
            end;
          tkUString, tkLString:
            begin
              AValue := AJsonValue.JsonValue.Value;
              AField.SetValue(@result, AValue);
            end;
        else
          if sametext(AField.FieldType.Name, 'Boolean') then
          begin
            AValue := sametext(AJsonValue.JsonValue.Value, 'true');
            AField.SetValue(@result, AValue);
          end;
          // You should add other types as well
        end;
      except
      end;
    end;
  finally
    AContext.free;
  end;
end;

function TJSONObjectHelper.V(chave: String): variant;
var
  V: string;
begin
  TryGetValue<string>(chave, V);
  result := V;
end;

{$IFNDEF BPL}

function TJSONObjectHelper.asObject: System.TObject;
var
  m: TJSONunMarshal;
begin
  m := TJSONunMarshal.create;
  try
    result := m.Unmarshal(self);
  finally
    m.free;
  end;
end;
{$ENDIF}
{$IFDEF VER270}

function TJSONObjectHelper.ToJson: string;
begin
  result := ToString;
end;
{$ENDIF}
{ TJSONArrayHelper }

function TJSONArrayHelper.Find(AJson: string): TJSONObject;
var
  j: TJSONObject;
  it: TJsonValue;
  P: TJsonPair;
  r: boolean;
  tmp: TJSONObject;
begin
  result := nil;
  j := TJSONObject.ParseJSONValue(AJson) as TJSONObject;
  for it in self do
  begin
    tmp := it as TJSONObject;
    r := true;
    for P in j do
    begin
      if not tmp.Contains(P.JsonString.Value) then
      begin
        r := false;
        exit;
      end;
      r := r and sametext(tmp.GetValue<string>(P.JsonString.Value),
        it.GetValue<string>(P.JsonString.Value));
    end;
    if r then
    begin
      result := tmp;
      exit;
    end;
  end;
end;

function TJSONArrayHelper.Length: integer;
begin
  result := Count;
end;

{ TJSONValueHelper }
{$IFDEF VER270}

function TJSONValueHelper.ToJson: string;
begin
  result := ToString;
end;
{$ENDIF}
{ TJSONValueHelper }

procedure TJSONValueHelper.addPair(AKey, AValue: string);
begin
  (self as TJSONObject).addPair(AKey, AValue);
end;

function TJSONValueHelper.AsArray: TJsonArray;
begin
  result := self as TJsonArray;
end;

function TJSONValueHelper.AsInteger: integer;
begin
  TryGetValue<integer>(result);
end;

function TJSONValueHelper.asObject: TJSONObject;
begin
  result := self as TJSONObject;
end;

function TJSONValueHelper.AsPair: TJsonPair;
begin
  result := TJsonPair(self);
end;

function TJSONValueHelper.AsString: string;
var
  P: TJsonPair;
begin
  result := '';
  for P in (self as TJSONObject) do
  begin
    if result > '' then
      result := result + ';';
    result := result + P.JsonString.Value + '=' + P.JsonValue.Value;
  end;
end;

function TJSONValueHelper.Datatype: TJsonType;
begin
  result := TJSONObject.GetJsonType(self);
end;

class procedure TJSONValueHelper.GetRecordList<T>
  (AList: TJsonValuesList; ARec: T);
var
  AContext: TRttiContext;
  ARecord: TRttiRecordType;
  AField: TRttiField;
  AJsonValue: TJsonPair;
  AValue: TValue;
  AFieldName: String;
  j: TJSONObject;
  APair: TJsonPair;
begin
  AContext := TRttiContext.create;
  try
    ARecord := AContext.GetType(TypeInfo(T)).AsRecord;
    for AField in ARecord.GetFields do
    begin
      AFieldName := lowercase(AField.Name);
      AValue := AField.GetValue(@ARec);
      APair := nil;
      case AField.FieldType.TypeKind of
        tkInteger, tkFloat, tkInt64:
          APair := TJsonPair.create(AFieldName,
            TJSONNumber.create(AValue.AsExtended));
        tkString, tkWString, tkLString, tkChar, tkWChar, tkUString:
          APair := TJsonPair.create(AFieldName, AValue.AsString);
      else
        if sametext(AField.FieldType.Name, 'Boolean') then
        begin
          if AValue.AsBoolean then
               APair := TJsonPair.create(AFieldName, TJSONTrue.create() )
          else APair := TJsonPair.create(AFieldName, TJSONFalse.create() );
        end;
      end;
      if assigned(APair) then
        AList.add(APair);
    end;
  finally
    AContext.free;
  end;

end;

class function TJSONValueHelper.New(AKey, AValue: String): TJsonValue;
var
  APair: TJsonPair;
begin
  APair := TJsonPair.create(AKey, AValue);
  result := TJSONObject.create(APair);
end;

{ TJSONPairHelper }

function TJSONPairHelper.asObject: TJSONObject;
begin
  result := (self.JsonValue) as TJSONObject;
end;

function ISOTimeToString(ATime: TTime): string;
var
  fs: TFormatSettings;
begin
  fs.TimeSeparator := ':';
  result := FormatDateTime('hh:nn:ss', ATime, fs);
end;

function ISODateToString(ADate: TDatetime): string;
begin
  result := FormatDateTime('YYYY-MM-DD', ADate);
end;

function ISODateTimeToString(ADateTime: TDatetime): string;
begin
  result := System.DateUtils.DateToISO8601(ADateTime, false);
end;

function ISOStrToDateTime(DateTimeAsString: string): TDatetime;
begin
  if DateTimeAsString.Contains('T') then
    result := System.DateUtils.ISO8601ToDate(DateTimeAsString)
  else
    result := StrToDateTime(DateTimeAsString);
end;

function ISOStrToTime(TimeAsString: string): TTime;
begin
  result := EncodeTime(StrToInt(Copy(TimeAsString, 1, 2)),
    StrToInt(Copy(TimeAsString, 4, 2)), StrToInt(Copy(TimeAsString, 7, 2)), 0);
end;

function ISOStrToDate(DateAsString: string): TDate;
begin
  result := System.DateUtils.ISO8601ToDate(DateAsString);
end;

function JSONStoreError(msg: string): TJsonValue;
var
  js: TJSONObject;
begin
  js := TJSONObject.create;
  js.addPair('error', msg);
  js.addPair('ok', 'false');
  result := js;
end;

{ TJsonValuesList }

function TJsonValuesList.GetNames(AName: string): TJsonPair;
var
  I: integer;
  fld: string;
begin
  result := nil;
  fld := lowercase(AName);
  for I := 0 to Count - 1 do
    if sametext(Items[I].JsonString.Value, fld) then
    begin
      result := Items[I];
      exit;
    end;
end;

procedure TJsonValuesList.SetNames(AName: string; const Value: TJsonPair);
var
  I: integer;
  fld: string;
begin
  fld := lowercase(AName);
  for I := 0 to Count - 1 do
    if sametext(Items[I].JsonString.Value, fld) then
    begin
      Items[I] := Value;
      exit;
    end;
end;

{ TInterfacedJSON }

function TInterfacedJSON.AddChild(AKey, AJson: string): TJSONObject;
begin
  result := TJSONObject.ParseJSONValue(AJson) as TJSONObject;
  (FJson as TJSONObject).addPair(AKey, result);
end;

function TInterfacedJSON.addPair(AKey, AValue: string): TJSONObject;
begin
  result := (FJson as TJSONObject).addPair(AKey, AValue);
end;

constructor TInterfacedJSON.create;
begin
  inherited create;
end;

constructor TInterfacedJSON.create(AJson: string);
begin
  inherited create;
  Parse(AJson);
end;

destructor TInterfacedJSON.destroy;
begin
  if FInstanceOwned then
    FreeAndNil(FJson);
  inherited;
end;

function TInterfacedJSON.Json: TJsonValue;
begin
  result := FJson;
end;

class function TInterfacedJSON.New(AJson: TJsonValue; AOwned: boolean)
  : IJsonObject;
var
  jo: TInterfacedJSON;
begin
  jo := TInterfacedJSON.create;
  jo.FJson := AJson;
  jo.FInstanceOwned := AOwned;
  result := jo;
end;

function TInterfacedJSON.addPair(AKey:string; AValue: TJsonValue): TJSONObject;
begin
  result := JSONObject.addPair(AKey,AValue);
end;

function TInterfacedJSON.AsArray: TJsonArray;
begin
  Json.TryGetValue<TJsonArray>(result);
end;

function TInterfacedJSON.Contains(AKey: string): boolean;
begin
  result := JSONObject.Contains(AKey);
end;

class function TInterfacedJSON.GetJsonType(AJsonValue: TJsonValue): TJsonType;
begin
  result := TJSONObject.GetJsonType(AJsonValue);
end;

function TInterfacedJSON.GetValueBase(chave: string): string;
begin
  result := JSONObject.Value[chave];
end;

function TInterfacedJSON.JsonValue: TJsonValue;
begin
  result := FJson;
end;

class function TInterfacedJSON.GetJsonType(AJsonValue: TJsonPair): TJsonType;
var
  j: TJsonValue;
begin
  result := GetJsonType(AJsonValue.JsonValue);
end;

function TInterfacedJSON.isNull: boolean;
begin
  result := not assigned(FJson);
end;

function TInterfacedJSON.JSONObject: TJSONObject;
begin
  result := FJson as TJSONObject;
end;

class function TInterfacedJSON.New: IJsonObject;
begin
  result := TInterfacedJSON.create('{}');
end;

class function TInterfacedJSON.New(AJson: string): IJsonObject;
begin
  result := TInterfacedJSON.create(AJson);
end;

function TInterfacedJSON.Parse(AJson: string): IJsonObject;
var
  O: TJSONObject;
begin
  result := self;
  if not assigned(FJson) then
  begin
    FJson := TJSONObject.ParseJSONValue(AJson);
    FInstanceOwned := false;
    exit;
  end;
  O := FJson As TJSONObject;
  O.ParseJSONValue(AJson);
end;

procedure TInterfacedJSON.SetValueBase(chave: string; const Value: string);
begin
  JSONObject.Value[chave] := Value;
end;

function TInterfacedJSON.ToJson: string;
begin
  result := FJson.ToJson;
end;

initialization

finalization

{$IFNDEF MULTI_THREADED}
  JSONFree;
{$ENDIF}

end.
