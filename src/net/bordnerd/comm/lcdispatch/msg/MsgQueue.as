package net.bordnerd.comm.lcdispatch.msg {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.lcdispatch.lc.LCDConnection;
	import net.bordnerd.comm.lcdispatch.lc.LCDConnectionObserver;
	import net.bordnerd.comm.lcdispatch.event.*;
	import net.bordnerd.comm.lcdispatch.msg.*;
	import flash.events.EventDispatcher;
	
	public class MsgQueue
		extends
			EventDispatcher
		implements
			LCDConnectionObserver
	{
		
		private var _lcdConn:LCDConnection;
		private var _incomingMsgs:Object;
		private var _outgoingMsgParts:Array;
		
		public function MsgQueue( lcdConn:LCDConnection ) {
			super( this );
			_lcdConn = lcdConn;
			_lcdConn.setObserver( this );
			_incomingMsgs = new Object();
			_outgoingMsgParts = new Array();
		}
	
		public function sendMsg( id:String, contents:String ):void {
			if( contents != null && contents.length > 0 ) {
				var msg:LCMsg = new LCOutgoingMsg( _lcdConn.getConnectionId(), id, contents );
				var parts:Array = msg.getMsgParts();
				if( parts.length > 0 ) {
					for( var i:uint = 0; i < parts.length; ++i ) {
						_outgoingMsgParts.push( parts[i] );	
					}
				}
				this.sendParts();	
			}	
		}
		
		public function receiveMsg( contents:String ):void {
			trace("MsgQueue.receiveMsg("+contents+")");
			if( contents != null && contents.length > 0 ) {
				var msg:LCMsg = new LCIncomingMsg( contents );
				var id:String = msg.getId();
				trace(">> msg id is:"+id);
				if( id != null ) {
					if( msg.isMsgComplete() ) {
						trace(">> msg is complete, dispatching IncomingMsgEvent");
						this.dispatchMsg( msg );
					} else {
						trace(">> msg is partial");
						if( this._incomingMsgs[ id ] == null ) {
							trace(">> first packet, storing as root msg on incomingMsgs queue");
							this._incomingMsgs[ id ] = msg;	
						} else {
							trace(">> appending the contents to existing root msg with same id.");
							LCMsg( this._incomingMsgs[ id ] ).append( msg.getContent() );
							if( LCMsg( this._incomingMsgs[ id ] ).isMsgComplete() ) {
								trace(">> msg is complete, dispatching IncomingMsgEvent");
								this.dispatchMsg( LCMsg( this._incomingMsgs[id] ) );
								this._incomingMsgs[id] = null;	
							}	
						}
					}	
				}
			}
		}
		
		
		//////////////////////////////////////////////////////////////////
		// Private Methods
		//////////////////////////////////////////////////////////////////
		
		private function dispatchMsg( msg:LCMsg ):void {
			this.dispatchEvent( new IncomingMsgEvent( msg.getConnId(), msg.getId(), msg.getContent() ) );
		}
		
		private function sendParts():void {
			while( this._outgoingMsgParts.length > 0 ) {
				this._lcdConn.sendMsg( String(this._outgoingMsgParts.shift()) );	
			}	
		}
		
		
	}

}