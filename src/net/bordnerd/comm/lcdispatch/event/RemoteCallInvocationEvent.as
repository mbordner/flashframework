package net.bordnerd.comm.lcdispatch.event {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.lcdispatch.event.*; 
	import net.bordnerd.comm.lcdispatch.call.*;
	import flash.events.*;
	
	public class RemoteCallInvocationEvent 
		extends
			LCDispatchEvent 
	{	
		private var _call:LCIncomingCall;
		private var _return:LCOutgoingReturn;
		
		public function RemoteCallInvocationEvent( incomingCall:LCIncomingCall, outgoingReturn:LCOutgoingReturn ) {
			super( LCDispatchEvent.REMOTE_CALL_INVOCATION );
			_call = incomingCall;
			_return = outgoingReturn;
		}
		
		public function get connectionId():String {
			return _call.connectionId;	
		}
		
		public function get name():String {
			return _call.name;	
		}
		
		public function get args():Array {
			return _call.args;	
		}
		
		public function get handled():Boolean {
			return _return.handled;
		}
		
		public function setReturnValue( value:* ):void {
			_return.setValue( value );	
		}
		
		public override function clone():Event {
			return new RemoteCallInvocationEvent( _call, _return );	
		}
		
		public override function toString():String {
			return formatToString( "RemoteCallInvocationEvent", "type", "bubbles", "cancelable", "eventPhase", "name", "args", "handled" );	
		}
	
	}
	
}