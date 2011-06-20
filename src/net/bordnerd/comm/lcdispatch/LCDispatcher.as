package net.bordnerd.comm.lcdispatch {
	/**
	 * @author michael.bordner
	 */
	import flash.events.EventDispatcher;
	
	import net.bordnerd.comm.lcdispatch.*;
	import net.bordnerd.comm.lcdispatch.call.*;
	import net.bordnerd.comm.lcdispatch.event.*;
	import net.bordnerd.comm.lcdispatch.lc.*;
	import net.bordnerd.comm.lcdispatch.msg.*;
	
	public class LCDispatcher
		extends
			EventDispatcher
	{
		
		private static var _lockedSendId:String = null;
		private static var _lockedReceiveId:String = null;
		
		private static var _instance:LCDispatcher = null;
		
		private var _lc:LCDConnection;
		private var _msgQueue:MsgQueue;
		private var _outgoingCalls:Object;
		private var _callSequenceNumber:Number;
		
		public function LCDispatcher(){
			super( this );
			_lc = new LCDConnection();
			_msgQueue = new MsgQueue( _lc );
			_outgoingCalls = new Object();
			_callSequenceNumber = 0;
			_msgQueue.addEventListener( LCDispatchEvent.INCOMING_MSG, this.incomingMsg );	
		}
		
		///////////////////////////////////////////////////
		// Public Methods
		///////////////////////////////////////////////////
		
		public static function set lockedSendId( id:String ):void {
			_lockedSendId = id;
		}
		public static function get lockedSendId():String {
			return _lockedSendId;	
		}
		
		public static function set lockedReceiveId( id:String ):void {
			_lockedReceiveId = id;	
		}
		
		public static function get lockedReceiveId():String {
			return _lockedReceiveId;	
		}
			
		public static function getInstance():LCDispatcher {
			if( _instance == null ) {
				_lockedSendId = null;
				_lockedReceiveId = null;
				_instance = new LCDispatcher();	
			}
			return _instance;
		}
		
		/**
		 * This method attempts to invoke a remote method over a LocalConnection.
		 * @param name String, identifier name for the remote method (handler will match the name with the event property RemoteCallInvocationEvent.name)
		 * @param args Array, arguments for the remote method invocation
		 * @param returnHandler Function, optional callback that will be invoked when a return value is returned from the remote method invocation.  the return handler function should have the signature: function ( val:LCReturn ):void
		 * @return String, unique id for the function call.  Will match the event property OutgoingCallTimeoutEvent.id if nothing calls RemoteCallInvocationEvent.setReturnValue( val ) in LCOutgoingCall.LCD_CALL_TIMEOUT ms.
		 */	
		public static function dispatchCall( name:String, args:Array, returnHandler:Function = null ):String {
			return LCDispatcher.getInstance().processOutgoingCall( name, args, returnHandler );
		}
		
		public static function shutdown():void {
			LCDispatcher.getInstance().destroy();
		}
		
		public function destroy():void {
			if( _lc != null ) {
				_lc.destroy();
				_lockedSendId = null;
				_lockedReceiveId = null;
				_lc = null;
			}
			_instance = null;
		}
			
		///////////////////////////////////////////////////
		// Private Methods
		///////////////////////////////////////////////////
		
		private function incomingMsg( evt:IncomingMsgEvent ):void {
			trace("LCDispatcher.incomingMsg(evt)");
			if( evt ) {
				var msg:String = evt.msg;
				if( msg != null && msg.length > 0 ) {
					try {
						var xml:XML = new XML( msg );
						xml.normalize();
						
						var name:String = String(xml.name());
						switch( name ) {
							case "c":
								this.processIncomingCall( evt.connId, xml );
								break;
							case "r":
								this.processIncomingReturn( evt.connId, xml );
								break;	
						}
						
					} catch ( e:Error ) {
						trace( e.message );
					}
				} 	
			}		
		}
		
		private function processIncomingCall( connId:String, xml:XML ):void {
			trace("LCDispatcher.processIncomingCall( xml )");
			var call:LCIncomingCall = new LCIncomingCall( connId, xml );
			if( LCDispatcher.lockedReceiveId == null || LCDispatcher.lockedReceiveId == connId ) {
				if( call.id && call.name ) {
					var outgoingReturn:LCOutgoingReturn = new LCOutgoingReturn( call.id, connId );
					trace("sending RemoteCallInvocationEvent for call:"+call.name );
					var evt:RemoteCallInvocationEvent = new RemoteCallInvocationEvent( call, outgoingReturn );				
					this.dispatchEvent( evt );
					if( evt.handled ) {
						trace("return was handled for call:"+call.name);
						_msgQueue.sendMsg( call.id, outgoingReturn.toString() );	
					}			
				}
			}
		}
		
		private function processIncomingReturn( connId:String, xml:XML ):void {
			trace("LCDispatcher.processIncomingReturn( xml )");
			var incomingReturn:LCIncomingReturn = new LCIncomingReturn( connId, xml );
			if( LCDispatcher.lockedReceiveId == null || LCDispatcher.lockedReceiveId == connId ) {
				var id:String = incomingReturn.id;		
				if( _outgoingCalls[ id ] != null ) {
					var call:LCOutgoingCall = LCOutgoingCall( _outgoingCalls[ id ] );
					call.removeEventListener( LCDispatchEvent.OUTGOING_CALL_TIMEOUT, this.outgoingCallTimeout );
					call.processReturn( incomingReturn );
					if( !incomingReturn.acceptMoreReturns ) {
						_outgoingCalls[ id ] = null;	
					} else {
						
					}
				}
			}
		}
		
		private function outgoingCallTimeout( evt:OutgoingCallTimeoutEvent ):void {
			trace("LCDispatcher.outgoingCallTimeout(evt.id ="+(evt.id)+")");
			var id:String = evt.id;
			if( _outgoingCalls[ id ] != null ) {
				var call:LCOutgoingCall = LCOutgoingCall( _outgoingCalls[ id ] );	
				call.removeEventListener( LCDispatchEvent.OUTGOING_CALL_TIMEOUT, this.outgoingCallTimeout );
				_outgoingCalls[ id ] = null;
				this.dispatchEvent( evt );
				call.processReturn( new LCOutgoingReturn( id, _lc.getConnectionId() ) );	
			}
		}
		
		private function processOutgoingCall( name:String, args:Array, returnHandler:Function = null ):String {
			var id:String = this.getUniqueCallId();
			var call:LCOutgoingCall = new LCOutgoingCall( id, _lc.getConnectionId(), name, args, returnHandler );
			if( returnHandler != null ) {
				_outgoingCalls[ id ] = call;
				call.addEventListener( LCDispatchEvent.OUTGOING_CALL_TIMEOUT, this.outgoingCallTimeout );
			}
			call.processCall( _msgQueue );
			return id;
		}
		
		private function getUniqueCallId():String {
			++_callSequenceNumber;
			return _lc.getConnectionId() + "_" + _callSequenceNumber;	
		}
		
	}
}
