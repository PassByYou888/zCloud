unit MyService;

interface

uses
  CoreClasses, PascalStrings, DoStatusIO, UnicodeMixedLib, ListEngine,
  Geometry2DUnit, DataFrameEngine, ZJson,
  NotifyObjectBase, CoreCipher, MemoryStream64,
  zExpression, OpCode, TextParsing,
  CommunicationFramework, PhysicsIO,
  CommunicationFrameworkDoubleTunnelIO,
  CommunicationFrameworkDataStoreService,
  CommunicationFrameworkDoubleTunnelIO_VirtualAuth,
  CommunicationFrameworkDataStoreService_VirtualAuth,
  CommunicationFrameworkDoubleTunnelIO_NoAuth,
  CommunicationFrameworkDataStoreService_NoAuth,
  DTC40, DTC40_Log_DB;

type
  TMyService = class(TDTC40_Base_NoAuth_Service)
  public
  end;

  TMyClient = class(TDTC40_Base_NoAuth_Client)
  end;

  TMyService2 = class(TDTC40_Base_NoAuth_Service)
  public
  end;

  TMyClient2 = class(TDTC40_Base_NoAuth_Client)
  end;

implementation

initialization

RegisterC40('MyCustom', TMyService, TMyClient);
RegisterC40('MyCustom_2', TMyService2, TMyClient2);

end.
