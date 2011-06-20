package net.bordnerd.activity.event {
	
	import flash.events.Event;
	import net.bordnerd.activity.event.ActivityFWEvent;
	
	/**
	 * @author michael.bordner
	 */
	public class ActivityViewEvent extends ActivityFWEvent
	{
		
		private var _name:String;
		private var _args:*;
		
		public function ActivityViewEvent( name:String, args:* = null ) {
			super( ActivityFWEvent.VIEW_EVENT );
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
			return new ActivityViewEvent( name, args );	
		}
		
		public override function toString():String {
			return formatToString( "ActivityViewEvent", "type", "bubbles", "cancelable", "eventPhase", "name", "args" );	
		}
		
	}
}
