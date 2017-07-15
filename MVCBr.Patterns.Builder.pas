{ *************************************************************************** }
{ }
{ MVCBr � o resultado de esfor�os de um grupo }
{ }
{ Copyright (C) 2017 MVCBr }
{ }
{ amarildo lacerda }
{ http://www.tireideletra.com.br }
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
unit MVCBr.Patterns.Builder;

interface

uses
  System.Classes, System.SysUtils,
  System.RTTI.Helper,
  System.RTTI, System.Generics.Collections;

type

  TMVCBrBuilderItem<T, TResult> = class;

  IMVCBrBuilderItem<T, TResult> = interface
    ['{0EA84140-4B56-494B-8C09-B39A3E7F400F}']
    procedure Release;
    function This: TObject;
    function Execute(AParam: T): IMVCBrBuilderItem<T, TResult>;
    function Response: TResult;
    function Delegate: TFunc<T, TResult>;
    function Command: TValue;
    procedure SetDelegate(AValue: TFunc<T, TResult>);
  end;

  TMVCBrBuilder<T, TResult> = class
  private
    [weak]
    FList: TThreadList<IMVCBrBuilderItem<T, TResult>>;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    class function New: TMVCBrBuilder<T, TResult>; overload;
    class function New(ACommand: TValue; ABuilderFunc: TFunc<T, TResult>)
      : TMVCBrBuilder<T, TResult>; overload;
    function LockList: TList<IMVCBrBuilderItem<T, TResult>>; virtual;
    procedure UnlockList; virtual;
    function Add(ACommand: TValue; ABuilderFunc: TFunc<T, TResult>)
      : TMVCBrBuilderItem<T, TResult>; overload; virtual;
    function Add(ACommand: TValue; AItem: TMVCBrBuilderItem<T, TResult>)
      : TMVCBrBuilderItem<T, TResult>; overload; virtual;
    [weak]
    function Execute(ACommand: TValue; AParam: T)
      : IMVCBrBuilderItem<T, TResult>; virtual;
    [weak]
    function Query(ACommand: TValue): IMVCBrBuilderItem<T, TResult>; virtual;
    procedure Release; virtual;
    procedure Clear; virtual;
    function Count: Integer; virtual;
    function IndexOf(ACommand: TValue): Integer;
    procedure Remove(AItem: TMVCBrBuilderItem<T, TResult>); overload; virtual;
    procedure Remove(ACommand: TValue); overload; virtual;
    function Contains(ACommand: TValue): Boolean; virtual;
    function This: TObject; virtual;
    function isValid(idx: Integer): Boolean;
  end;

  IMVCBrBuilder<T, TResult> = interface
    ['{1C86D407-8F67-411F-AEA8-D90BBC6AA91A}']
    procedure Release;
    function This: TObject;
    function Add(ACommand: TValue; ABuilderFunc: TFunc<T, TResult>)
      : IMVCBrBuilderItem<T, TResult>;
    function Query(ACommand: TValue): IMVCBrBuilderItem<T, TResult>;
    function Execute(ACommand: TValue; AParam: T)
      : IMVCBrBuilderItem<T, TResult>;
    function Contains(ACommand: TValue): Boolean;
    procedure Remove(ACommand: TValue);
  end;

  TMVCBrBuilderItem<T, TResult> = Class(TInterfacedObject,
    IMVCBrBuilderItem<T, TResult>)
  public
  private
    FCommand: TValue;
    FDelegate: TFunc<T, TResult>;
    FResult: TResult;
    [weak]
    FBuilder: TMVCBrBuilder<T, TResult>;
  public
    constructor Create(ABuilder: TMVCBrBuilder<T, TResult>; ACommand: TValue;
      ADelegate: TFunc<T, TResult>); overload; virtual;
    destructor Destroy; override;
    class function New(ABuilder: TMVCBrBuilder<T, TResult>; ACommand: TValue;
      ADelegate: TFunc<T, TResult>): TMVCBrBuilderItem<T, TResult>; overload;
    class function New(ABuilder: TMVCBrBuilder<T, TResult>; ACommand: TValue)
      : TMVCBrBuilderItem<T, TResult>; overload;
    [weak]
    function Execute(AParam: T): IMVCBrBuilderItem<T, TResult>; virtual;
    function Response: TResult; virtual;
    function Delegate: TFunc<T, TResult>; virtual;
    function Command: TValue; virtual;
    procedure SetDelegate(AValue: TFunc<T, TResult>); virtual;
    procedure Release; virtual;
    function This: TObject; virtual;
    function ThisAs: TMVCBrBuilderItem<T, TResult>; virtual;
    property DefaultBuilder: TMVCBrBuilder<T, TResult> read FBuilder;
    function LockList: TList<IMVCBrBuilderItem<T, TResult>>; virtual;
    procedure UnlockList;
  end;

  TMVCBrBuilderFactory<T, TResult> = class(TInterfacedObject,
    IMVCBrBuilder<T, TResult>)
  private
    [weak]
    FWrapper: TMVCBrBuilder<T, TResult>;
  public
    constructor Create(AClass: TMVCBrBuilder<T, TResult>); virtual;
    destructor Destroy; override;
    class function New: IMVCBrBuilder<T, TResult>; virtual;
    property Builder: TMVCBrBuilder<T, TResult> read FWrapper;
    function This: TObject; virtual;
    procedure Release; virtual;
    function Count: Integer; virtual;
    [weak]
    function Add(ACommand: TValue; ABuilderFunc: TFunc<T, TResult>)
      : IMVCBrBuilderItem<T, TResult>; overload; virtual;
    [weak]
    function Execute(ACommand: TValue; AParam: T)
      : IMVCBrBuilderItem<T, TResult>; virtual;
    [weak]
    function Query(ACommand: TValue): IMVCBrBuilderItem<T, TResult>; virtual;
    procedure Remove(ACommand: TValue); overload; virtual;
    function Contains(ACommand: TValue): Boolean; virtual;
    function LockList: TList<IMVCBrBuilderItem<T, TResult>>; virtual;
    procedure UnlockList; virtual;

  end;

  /// Lazy Builder Object
  ///
  IMVCBrBuilderObject = interface
    ['{EA4D8260-900F-4627-A7C8-B58CBAB26463}']
    function Execute(AParam: TValue): TValue;
    procedure SetResponse(const Value: TValue);
    function GetResponse: TValue;
    property Response: TValue read GetResponse write SetResponse;
  end;

  TMVCBrBuilderObject = class(TInterfacedObject, IMVCBrBuilderObject)
  private
    FResponse: TValue;
  protected
    procedure SetResponse(const Value: TValue); virtual;
    function GetResponse: TValue; virtual;
  public
    function Execute(AParam: TValue): TValue; virtual;
    property Response: TValue read GetResponse write SetResponse;
  end;

  TMVCBrBuilderObjectClass = class of TMVCBrBuilderObject;

  /// Lazy Builder Item
  TMVCBrBuilderLazyItem = class(TMVCBrBuilderItem<TValue, TValue>)
  private
    FClass: TMVCBrBuilderObjectClass;
    [weak]
    FInstance: TMVCBrBuilderObject;
  protected
  public
    constructor Create; Overload;
    destructor Destroy; override;
    class Function New(ABuilder: TMVCBrBuilder<TValue, TValue>;
      ACommand: string): TMVCBrBuilderLazyItem;
    function Default: TMVCBrBuilderObject;
    [weak]
    function Execute(AParam: TValue)
      : IMVCBrBuilderItem<TValue, TValue>; override;
    function Response: TValue; Override;
  end;

  /// Lazy Builder Factory
  ///
  TMVCBrBuilderLazyFactory = class(TMVCBrBuilder<TValue, TValue>)
  private
  public
    class function New: TMVCBrBuilderLazyFactory; virtual;
    function Add(ACommand: String; AClass: TMVCBrBuilderObjectClass)
      : TMVCBrBuilderLazyItem; virtual;
    [weak]
    function Query<T: Class>(ACommand: TValue): T; overload;
  end;

implementation

{ TMVCBrBuilderFactory<T> }
uses MVCBr.Interf;

function TMVCBrBuilder<T, TResult>.Add(ACommand: TValue;
  ABuilderFunc: TFunc<T, TResult>): TMVCBrBuilderItem<T, TResult>;
begin
  result := TMVCBrBuilderItem<T, TResult>.New(self, ACommand, ABuilderFunc);
  FList.Add(result);
end;

function TMVCBrBuilder<T, TResult>.Add(ACommand: TValue;
  AItem: TMVCBrBuilderItem<T, TResult>): TMVCBrBuilderItem<T, TResult>;
begin
  result := AItem;
  FList.Add(result);
end;

procedure TMVCBrBuilder<T, TResult>.Clear;
begin
  Release;
  FList.Clear;
end;

constructor TMVCBrBuilder<T, TResult>.Create();
begin
  FList := TThreadList < IMVCBrBuilderItem < T, TResult >>.Create;
end;

destructor TMVCBrBuilder<T, TResult>.Destroy;
var
  i: Integer;
begin
  FList.free;
  FList := nil;
  inherited;
end;

function TMVCBrBuilder<T, TResult>.Contains(ACommand: TValue): Boolean;
var
  i: Integer;
begin

  try
    i := IndexOf(ACommand);
    result := isValid(i);
  except
    /// workaround early freed interface
    result := false;
  end;
end;

function TMVCBrBuilder<T, TResult>.Count: Integer;
begin
  with FList.LockList do
    try
      result := Count;
    finally
      FList.UnlockList;
    end;
end;

class function TMVCBrBuilder<T, TResult>.New(ACommand: TValue;
  ABuilderFunc: TFunc<T, TResult>): TMVCBrBuilder<T, TResult>;
begin
  result := TMVCBrBuilder<T, TResult>.New;
  result.Add(ACommand, ABuilderFunc);
end;

function TMVCBrBuilder<T, TResult>.Query(ACommand: TValue)
  : IMVCBrBuilderItem<T, TResult>;
var
  i: Integer;
begin
  result := nil;
  i := IndexOf(ACommand);
  with FList.LockList do
    try
      if (i >= 0) and (i < FList.LockList.Count) then
        result := items[i];
    finally
      FList.UnlockList;
    end;
end;

function TMVCBrBuilder<T, TResult>.Execute(ACommand: TValue; AParam: T)
  : IMVCBrBuilderItem<T, TResult>;
begin
  result := Query(ACommand);
  Assert(assigned(result), 'Builder Command not found');
  result.Execute(AParam)
end;

function TMVCBrBuilder<T, TResult>.IndexOf(ACommand: TValue): Integer;
var
  i: Integer;
begin
  i := -1;
  with FList.LockList do
    try
      for i := Count - 1 downto 0 do
      begin
        if TMVCBrBuilderItem<T, TResult>(items[i].This).FCommand.Equals(ACommand)
        then
        begin
          result := i;
          exit;
        end;
      end;
    finally
      FList.UnlockList;
    end;
end;

function TMVCBrBuilder<T, TResult>.isValid(idx: Integer): Boolean;
begin
  result := (idx >= 0) and (idx < Count);
end;

function TMVCBrBuilder<T, TResult>.LockList
  : TList<IMVCBrBuilderItem<T, TResult>>;
begin
  result := FList.LockList;
end;

class function TMVCBrBuilder<T, TResult>.New: TMVCBrBuilder<T, TResult>;
begin
  result := TMVCBrBuilder<T, TResult>.Create;
end;

procedure TMVCBrBuilder<T, TResult>.Release;
var
  i: Integer;
begin
  {
    with FList.LockList do
    try
    for i := count - 1 downto 0 do
    try
    items[i].Release;
    except
    /// workaround;
    end;
    finally
    FList.UnlockList;
    end;
  }
end;

procedure TMVCBrBuilder<T, TResult>.Remove(ACommand: TValue);
var
  i: Integer;
begin
  i := IndexOf(ACommand);
  if isValid(i) then
    with FList.LockList do
      try
        Delete(i);
      finally
        FList.UnlockList;
      end;
end;

procedure TMVCBrBuilder<T, TResult>.Remove
  (AItem: TMVCBrBuilderItem<T, TResult>);
begin
  try
    if Contains(AItem.FCommand) then
    begin
      AItem.Release;
      Remove(AItem.FCommand);
    end;
  except
    /// workaroud for early freed
  end;
end;

function TMVCBrBuilder<T, TResult>.This: TObject;
begin
  result := self;
end;

procedure TMVCBrBuilder<T, TResult>.UnlockList;
begin
  FList.UnlockList;
end;

{ TMVCBrBuilderItem<T> }

function TMVCBrBuilderItem<T, TResult>.Delegate: TFunc<T, TResult>;
begin
  result := FDelegate;
end;

destructor TMVCBrBuilderItem<T, TResult>.Destroy;
begin
  inherited;
end;

function TMVCBrBuilderItem<T, TResult>.Execute(AParam: T)
  : IMVCBrBuilderItem<T, TResult>;
begin
  result := self;
  if assigned(FDelegate) then
    FResult := FDelegate(AParam);
end;

function TMVCBrBuilderItem<T, TResult>.LockList
  : TList<IMVCBrBuilderItem<T, TResult>>;
begin
  result := FBuilder.LockList;
end;

class function TMVCBrBuilderItem<T, TResult>.New
  (ABuilder: TMVCBrBuilder<T, TResult>; ACommand: TValue)
  : TMVCBrBuilderItem<T, TResult>;
begin
  result := New(ABuilder, ACommand, nil);
end;

class function TMVCBrBuilderItem<T, TResult>.New
  (ABuilder: TMVCBrBuilder<T, TResult>; ACommand: TValue;
  ADelegate: TFunc<T, TResult>): TMVCBrBuilderItem<T, TResult>;
begin
  result := TMVCBrBuilderItem<T, TResult>.Create(ABuilder, ACommand, ADelegate);
end;

function TMVCBrBuilderItem<T, TResult>.Command: TValue;
begin
  result := FCommand;
end;

constructor TMVCBrBuilderItem<T, TResult>.Create
  (ABuilder: TMVCBrBuilder<T, TResult>; ACommand: TValue;
  ADelegate: TFunc<T, TResult>);
begin
  inherited Create;
  FCommand := ACommand;
  FDelegate := ADelegate;
  FBuilder := ABuilder;
end;

procedure TMVCBrBuilderItem<T, TResult>.Release;
begin
  if assigned(FBuilder) then
    FBuilder.Remove(self);
  FBuilder := nil;

end;

function TMVCBrBuilderItem<T, TResult>.Response: TResult;
begin
  result := FResult;
end;

procedure TMVCBrBuilderItem<T, TResult>.SetDelegate(AValue: TFunc<T, TResult>);
begin
  FDelegate := AValue;
end;

function TMVCBrBuilderItem<T, TResult>.This: TObject;
begin
  result := self;
end;

function TMVCBrBuilderItem<T, TResult>.ThisAs: TMVCBrBuilderItem<T, TResult>;
begin
  result := self;
end;

procedure TMVCBrBuilderItem<T, TResult>.UnlockList;
begin
  FBuilder.UnlockList;
end;

{ TMVCBrBuilderFactory<T, TResult> }

function TMVCBrBuilderFactory<T, TResult>.Add(ACommand: TValue;
  ABuilderFunc: TFunc<T, TResult>): IMVCBrBuilderItem<T, TResult>;
begin
  result := FWrapper.Add(ACommand, ABuilderFunc);
end;

function TMVCBrBuilderFactory<T, TResult>.Contains(ACommand: TValue): Boolean;
begin
  result := FWrapper.Contains(ACommand);
end;

function TMVCBrBuilderFactory<T, TResult>.Count: Integer;
begin
  result := FWrapper.Count;
end;

constructor TMVCBrBuilderFactory<T, TResult>.Create
  (AClass: TMVCBrBuilder<T, TResult>);
begin
  inherited Create;
  FWrapper := AClass;
end;

destructor TMVCBrBuilderFactory<T, TResult>.Destroy;
begin
  if assigned(FWrapper) then
    FWrapper.free;
  inherited;
end;

function TMVCBrBuilderFactory<T, TResult>.Execute(ACommand: TValue; AParam: T)
  : IMVCBrBuilderItem<T, TResult>;
begin
  result := FWrapper.Execute(ACommand, AParam);
end;

function TMVCBrBuilderFactory<T, TResult>.LockList
  : TList<IMVCBrBuilderItem<T, TResult>>;
begin
  result := FWrapper.LockList;
end;

class function TMVCBrBuilderFactory<T, TResult>.New: IMVCBrBuilder<T, TResult>;
begin
  result := TMVCBrBuilderFactory<T, TResult>.Create
    (TMVCBrBuilder<T, TResult>.Create);
end;

function TMVCBrBuilderFactory<T, TResult>.Query(ACommand: TValue)
  : IMVCBrBuilderItem<T, TResult>;
begin
  result := FWrapper.Query(ACommand);
end;

procedure TMVCBrBuilderFactory<T, TResult>.Release;
begin
  if assigned(FWrapper) then
    FWrapper.Release;
end;

procedure TMVCBrBuilderFactory<T, TResult>.Remove(ACommand: TValue);
begin
  FWrapper.Remove(ACommand);
end;

function TMVCBrBuilderFactory<T, TResult>.This: TObject;
begin
  result := self;
end;

procedure TMVCBrBuilderFactory<T, TResult>.UnlockList;
begin
  FWrapper.UnlockList;
end;

{ TMVCBBuilderLazyItem<T, TResult> }

constructor TMVCBrBuilderLazyItem.Create;
begin
  raise Exception.Create('Use NEW instead of create');
end;

function TMVCBrBuilderLazyItem.Default: TMVCBrBuilderObject;
begin
  if not assigned(FInstance) then
    FInstance := FClass.Create;
  result := FInstance;
end;

destructor TMVCBrBuilderLazyItem.Destroy;
var interf:IInterface;
begin
   try
    interf := FInstance;
    interf := nil; /// workaround - with Free blow Exception Error
   except
   end;
  inherited;
end;

function TMVCBrBuilderLazyItem.Execute(AParam: TValue)
  : IMVCBrBuilderItem<TValue, TValue>;
begin
  result := self;
  Default.Execute(AParam);
end;

class function TMVCBrBuilderLazyItem.New
  (ABuilder: TMVCBrBuilder<TValue, TValue>; ACommand: string)
  : TMVCBrBuilderLazyItem;
begin
  result := inherited Create();
  result.FBuilder := ABuilder;
  result.FCommand := ACommand;
end;

function TMVCBrBuilderLazyItem.Response: TValue;
begin
  result := Default.Response;
end;

{ TMVCBBuilderObject }

function TMVCBrBuilderObject.Execute(AParam: TValue): TValue;
begin
end;

function TMVCBrBuilderObject.GetResponse: TValue;
begin
  result := FResponse
end;

procedure TMVCBrBuilderObject.SetResponse(const Value: TValue);
begin
  FResponse := Value;
end;

{ TMVCBBuilderLazyFactory }

function TMVCBrBuilderLazyFactory.Add(ACommand: String;
  AClass: TMVCBrBuilderObjectClass): TMVCBrBuilderLazyItem;
begin
  result := TMVCBrBuilderLazyItem.New(self, ACommand);
  result.FClass := AClass;
  result.FInstance := nil;
  inherited Add(ACommand, result);
end;

class function TMVCBrBuilderLazyFactory.New: TMVCBrBuilderLazyFactory;
begin
  result := TMVCBrBuilderLazyFactory.Create;
end;

function TMVCBrBuilderLazyFactory.Query<T>(ACommand: TValue): T;
var
  ret: IMVCBrBuilderItem<TValue, TValue>;
  AGuid: TGuid;
  AItem: TMVCBrBuilderLazyItem;
begin
  ret := inherited Query(ACommand);
  AItem := TMVCBrBuilderLazyItem(ret.This);
  result := T(AItem.Default);
  ret := nil;
end;

end.
