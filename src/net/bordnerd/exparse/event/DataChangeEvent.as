package net.bordnerd.exparse.event {

	import flash.events.*;

	/**
	 * @author michael.bordner
	 */
	public class DataChangeEvent extends Event 
	{
		
		public static const DATA_CHANGE:String = "dataChanged";
		
		private var _id:String;
		private var _old:*;
		private var _new:*;
		
		public function DataChangeEvent( id:String, oldValue:*, newValue:* ) {
			super( DATA_CHANGE, true, false );
			_id = id;
			_old = oldValue;
			_new = newValue;
		}
		
		public function get id():String {
			return _id;	
		}
		
		public function get oldValue():* {
			return _old;	
		}
		
		public function get newValue():* {
			return _new;	
		}
		
		public override function clone():Event {
			return new DataChangeEvent( id, oldValue, newValue );	
		}
		
		public override function toString():String {
			return formatToString( "DataChangeEvent", "type", "bubbles", "cancelable", "eventPhase", "id", "oldValue", "newValue" );	
		}
	}
}
