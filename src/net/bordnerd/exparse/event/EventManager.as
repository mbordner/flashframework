package net.bordnerd.exparse.event {
	import net.bordnerd.exparse.functiontable.FunctionTable;
	import net.bordnerd.exparse.functiontable.TableFunction;
	/**
	 * @author michael.bordner
	 */
	public class EventManager 
	{
		private static var instance:EventManager = null;
		
		private var objTypeHandlersMap:Object;
		
		public function EventManager(){
			this.objTypeHandlersMap = new Object();	
		}
		
		///////////////////////////////////////////////////////
		// Public Functions
		///////////////////////////////////////////////////////
		
		public static function getInstance():EventManager {
			if( instance == null ) {
				instance = new EventManager();	
			}	
			return instance;
		}
		
		public function dispatchScriptEvent( objEvent:Object ):void {
			if( objEvent["type"] != undefined && (objEvent["type"] is String) && objEvent["type"].length > 0 ) {
				var strType:String = String(objEvent["type"]);
				var arrHandlers:Array = this.objTypeHandlersMap[ strType ] as Array;
				if( arrHandlers != null && arrHandlers.length > 0 ) {
					for( var i:uint = 0; i < arrHandlers.length; ++i ) {
						var strHandlerFunctionName:String = String(arrHandlers[i]);
						if( strHandlerFunctionName != null && strHandlerFunctionName.length > 0 ) {
							var objTableFunction:TableFunction = FunctionTable.getInstance().getTableFunction( strHandlerFunctionName );
							if( objTableFunction != null ) {
								objTableFunction.call( objEvent );	
							}
						}	
					}	
				}
			}	
		}
		
		public function addScriptEventListener( strType:String, strHandlerFunctionName:String ):void {
			if( strType != null && strType.length > 0 && strHandlerFunctionName != null && strHandlerFunctionName.length > 0 ) {
				if( this.objTypeHandlersMap[ strType ] == undefined ) {
					this.objTypeHandlersMap[ strType ] = new Array();	
				}
				var boolExists:Boolean = false;
				for( var i:uint = 0; i < this.objTypeHandlersMap[ strType ].length; ++i ) {
					if( this.objTypeHandlersMap[ strType ][i] == strHandlerFunctionName ) {
						boolExists = true;
						break;	
					}	
				}
				if( !boolExists ) {
					this.objTypeHandlersMap[ strType ].push( strHandlerFunctionName );
				}
			}
		}
		
		public function removeScriptEventListener( strType:String, strHandlerFunctionName:String ):void {
			if( strType != null && strType.length > 0 && strHandlerFunctionName != null && strHandlerFunctionName.length > 0 ) {
				if( this.objTypeHandlersMap[ strType ] != undefined ) {
					for( var i:uint = 0; i < this.objTypeHandlersMap[ strType ].length; ++i ) {
						if( this.objTypeHandlersMap[ strType ][i] == strHandlerFunctionName ) {
							this.objTypeHandlersMap[ strType ].splice( i, 1 );
							return;		
						}
					}
				}
			}
		}
		
		
	}
}