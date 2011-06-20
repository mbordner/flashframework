package net.bordnerd.comm.lcdispatch.event {
		
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.lcdispatch.event.*; 
	import flash.events.*;
	
	public class IncomingMsgEvent 
		extends
			LCDispatchEvent 
	{
		
		private var _connId:String;
		private var _id:String;
		private var _msg:String;
		
		public function IncomingMsgEvent( connId:String, id:String, msg:String ) {
			super( LCDispatchEvent.INCOMING_MSG );
			_connId = connId;
			_id = id;
			_msg = msg;
		}
		
		public function get connId():String {
			return _connId;	
		}
		
		public function get id():String {
			return _id;	
		}
		
		public function get msg():String {
			return _msg;	
		}
		
		public override function clone():Event {
			return new IncomingMsgEvent( _connId, _id, _msg );	
		}
		
		public override function toString():String {
			return formatToString( "IncomingMsgEvent", "type", "bubbles", "cancelable", "eventPhase", "connId", "id", "msg" );	
		}
		
	}
	
}