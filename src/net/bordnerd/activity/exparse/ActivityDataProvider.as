package net.bordnerd.activity.exparse {
	import net.bordnerd.exparse.LocalDataProvider;
	import net.bordnerd.exparse.DataProvider;
	import net.bordnerd.exparse.functiontable.TableFunction;
	import net.bordnerd.exparse.functiontable.FunctionWrapper;
	import net.bordnerd.activity.Activity;
	import net.bordnerd.activity.ActivityGroup;
	import net.bordnerd.exparse.event.DataChangeEvent;
	
	/**
	 * @author michael.bordner
	 */
	public class ActivityDataProvider extends LocalDataProvider implements DataProvider 
	{
		
		private var _activity:Activity;
		
		public function ActivityDataProvider( activity:Activity ) {
			super();
			_activity = activity;
		}
		
		public override function getDataValue( strIdentifier:String ):Object {
			if( strIdentifier.indexOf(".") != -1 ) {
				var tokens:Array = strIdentifier.split(".");
				var obj:Object = this.resolveObject( tokens );
				if( obj != null ) {
					return obj[ tokens[0] ];	
				}
			}
			return super.getDataValue( strIdentifier );										
		}
		
		public override function setDataValue( strIdentifier:String, varValue:* ):void {
			var didSet:Boolean = false;
			
			if( strIdentifier.indexOf(".") != -1 ) {
				var tokens:Array = strIdentifier.split(".");
				var obj:Object = this.resolveObject( tokens );
				if( obj != null ) {
					var oldValue:* = obj[ tokens[0] ];
					
					obj[ tokens[0] ] = varValue;
					didSet = true;
					
					if( this.willTrigger( DataChangeEvent.DATA_CHANGE ) ) {
						this.dispatchEvent( new DataChangeEvent( strIdentifier, 
							oldValue,
							varValue ) );	
					}
					
				}
			}
			
			if( !didSet ) {
				super.setDataValue( strIdentifier, varValue );	
			}	
		}
		
		public override function getTableFunction( strIdentifier:String ):TableFunction {
			if( strIdentifier.indexOf(".") != -1 ) {
				var tokens:Array = strIdentifier.split(".");
				var obj:Object = this.resolveObject( tokens );
				if( obj != null ) {
					if( obj[ tokens[0] ] is Function ) {
						var fw:FunctionWrapper = new FunctionWrapper( obj, obj[ tokens[0] ] );
						return fw;	
					}
				}
			}
			return super.getTableFunction( strIdentifier );
		}
		
		private function resolveObject( tokens:Array ):Object {
			var obj:Object = null;
			
			if( tokens[0] == "this" ) {
				obj = _activity;
				tokens.shift();	
			} else {
				var children:ActivityGroup = _activity.getChildrenActivityGroup();
				
				if( children != null ) {
					var act:Activity = children.getActivityChild( tokens[0] );
					if( act != null ) {
						obj = act;
						tokens.shift();	
					}	
				}	
			}
			
			if( obj != null ) {
				while( tokens.length > 1 ) {
					obj = obj[ tokens[0] ];
					tokens.shift();	
				}
			}
			
			return obj;
			
		}

	}
}
