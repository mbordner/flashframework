package net.bordnerd.activity.event {

	import flash.events.Event;
	import net.bordnerd.activity.event.ActivityFWEvent;

	/**
	 * @author michael.bordner
	 */
	public class ViewButtonClickEvent extends ActivityFWEvent 
	{
		private var _id:String;
		
		public function ViewButtonClickEvent( id:String ) {
			super( ActivityFWEvent.VIEW_BUTTON_CLICK );
			_id = id;
		}
		
		public function get id():String {
			return _id;	
		}
		
		public override function clone():Event {
			return new ViewButtonClickEvent( id );	
		}
		
		public override function toString():String {
			return formatToString( "ViewButtonClickEvent", "type", "bubbles", "cancelable", "eventPhase", "id" );	
		}
	}
}
