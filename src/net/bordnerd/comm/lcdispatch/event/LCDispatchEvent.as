package net.bordnerd.comm.lcdispatch.event {
	/**
	 * @author michael.bordner
	 */
	import flash.events.*; 
	 
	public class LCDispatchEvent
		extends
			Event
	{
		public static const INCOMING_MSG:String = "incomingMsg";
		public static const OUTGOING_CALL_TIMEOUT:String = "outgoingCallTimeout";
		public static const REMOTE_CALL_INVOCATION:String = "remoteCallInvocation";
				
		public function LCDispatchEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ) {
			super( type, bubbles, cancelable );
		}
		
		public override function clone():Event {
			return new LCDispatchEvent( type, bubbles, cancelable );	
		}
		
		public override function toString():String {
			return formatToString( "LCDispatchEvent", "type", "bubbles", "cancelable", "eventPhase" );	
		}
		
	}

}
