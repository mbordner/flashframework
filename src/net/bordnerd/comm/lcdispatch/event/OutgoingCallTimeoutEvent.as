package net.bordnerd.comm.lcdispatch.event {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.lcdispatch.event.*; 
	import flash.events.*;
	
	public class OutgoingCallTimeoutEvent 
		extends
			LCDispatchEvent 
	{
		
		private var _id:String;
		
		public function OutgoingCallTimeoutEvent( id:String ) {
			super( LCDispatchEvent.OUTGOING_CALL_TIMEOUT );
			_id = id;
		}
		
		public function get id():String {
			return _id;	
		}
		
		public override function clone():Event {
			return new OutgoingCallTimeoutEvent( _id );	
		}
		
		public override function toString():String {
			return formatToString( "OutgoingCallTimeoutEvent", "type", "bubbles", "cancelable", "eventPhase", "id" );	
		}
		
	}

}