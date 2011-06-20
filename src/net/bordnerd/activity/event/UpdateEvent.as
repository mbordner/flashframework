package net.bordnerd.activity.event {
	
	import flash.events.Event;
	import net.bordnerd.activity.event.ActivityFWEvent;
	
	/**
	 * @author michael.bordner
	 */
	public class UpdateEvent extends ActivityFWEvent
	{
		
		private var _name:String;
		private var _args:*;
		
		public function UpdateEvent( name:String, args:* = null ) {
			super( ActivityFWEvent.UPDATE_EVENT );
			_name = name;
			_args = args;	
		}
		
		public function get name():String {
			return _name;	
		}
		
		public function get args():* {
			return _args;	
		}
		
		public override function clone():Event {
			return new UpdateEvent( name, args );	
		}
		
		public override function toString():String {
			return formatToString( "UpdateEvent", "type", "bubbles", "cancelable", "eventPhase", "name", "args" );	
		}
		
	}
}
