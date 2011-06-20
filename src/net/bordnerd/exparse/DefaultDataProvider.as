package net.bordnerd.exparse {
	import net.bordnerd.exparse.*;
	import flash.events.*;
	import net.bordnerd.exparse.functiontable.*;
	import net.bordnerd.exparse.event.DataChangeEvent;

	public class DefaultDataProvider
		extends
			EventDispatcher 
		implements
			DataProvider
	{
		protected var objDataSource:Object = null;
		
		public function DefaultDataProvider( objDataSource:Object = null ) {
			super();
			if( objDataSource != null && objDataSource is Object ) {
				this.objDataSource = objDataSource;	
			} else {
				this.objDataSource = new Object();	
			}		 	
		}
		
		public function getDataValue( strIdentifier:String ):Object {
			if( strIdentifier != null && strIdentifier.length > 0 ) {
				if( this.objDataSource[ strIdentifier ] != undefined ) {
					return this.objDataSource[ strIdentifier ];
				}
			}
			return null;
		}
		
		public function setDataValue( strIdentifier:String, varValue:* ):void {
			if( strIdentifier != null && strIdentifier.length > 0  ) {
				
				var oldValue:* = null;
				if( this.objDataSource[ strIdentifier ] != undefined ) {
					oldValue = this.objDataSource[ strIdentifier ];
				}
				
				if( varValue != null ) {
					this.objDataSource[ strIdentifier ] = varValue;
				} else {
					if( this.objDataSource[ strIdentifier ] != undefined ) {
						this.objDataSource[ strIdentifier ] = null;
						delete this.objDataSource[ strIdentifier ];	
					}	
				}
				
				if( this.willTrigger( DataChangeEvent.DATA_CHANGE ) ) {
					this.dispatchEvent( new DataChangeEvent( strIdentifier, 
						oldValue,
						varValue ) );	
				}
				
			}
		}
		
		public function getTableFunction( strIdentifier:String ):TableFunction {
			return FunctionTable.getInstance().getTableFunction( strIdentifier );
		}
		
		public function serialize():String {
			if( this.objDataSource != null ) {
				return serializeObject( this.objDataSource );
			}
			return null;	
		}
		
		public function deserialize( s:String ):void {
			if( s != null && s.length > 0 ) {
				this.objDataSource = new ExpressionParser( s ).evaluate();	
			}
		}
		
		private function serializeObject( o:Object ):String {
			var arrValues:Array = new Array();
			
			var numberIndexesHandled:Boolean = false;
			if( o is Array ) {
				numberIndexesHandled = true;
				var a:Array = o as Array;
				for( var i:uint = 0; i < a.length; ++i ) {
					if( a[i] != undefined ) {
						var value:String = ""; 
						if( i > 0 && a[i-1] == undefined ) {
							value += i + ":";	
						}
						if( a[i] != undefined && a[i] != null ) {
							if( a[i] is Number || a[i] is Boolean || a[i] is String || a[i] is int || a[i] is uint ) {
								value += serializeValue( a[i] );	
							} else {
								value += serializeObject( a[i] );
							}
						}
						arrValues.push( value );
					}
				}
			}
			
			for( var p:Object in o ) {
				var identifier:String = null;
				if( p is String ) {
					identifier = "'" + p + "'";	
				} else {
					if( numberIndexesHandled ) {
						continue;	
					} else {
						identifier = p.toString();
					}
				}
				if( o[p] == null ) {
					arrValues.push( identifier + ":" );
				} else if( o[p] is Number || o[p] is Boolean || o[p] is String || o[p] is int || o[p] is uint ) {
					arrValues.push( identifier + ":" + serializeValue(o[p]) );	
				} else {
					arrValues.push( identifier + ":" + serializeObject(o[p]) );	
				}
			}
			
			return "[" + arrValues.join(",") + "]";
		}
		
		private function serializeValue( o:* ):String {
			if( o is String ) {
				return "'" + ExpressionParser.escapeString( o as String ) + "'";	
			}
			return o.toString();	
		}
		
	}
}