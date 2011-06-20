package net.bordnerd.comm.lcdispatch.lc {
	/**
	 * @author michael.bordner
	 */
	
	import net.bordnerd.comm.lcdispatch.LCDispatcher;
	import net.bordnerd.comm.lcdispatch.lc.LCDConnectionObserver;
	import flash.net.*;
	import flash.events.*;
	 
	public class LCDConnection
		extends
			LocalConnection
	{
		
		private static const LCD_CONN_ID_PREFIX:String = "_lcd";
		private static const LCD_CONN_MAX_COUNT:Number = 16; // i would hope there are never more than 8 swfs running on a machine that need to use this class :)
		
		private var _connId:String = null;
		private var _knownConnIds:Object = null;
		
		private var _sendArgs:Array = null;
		private var _observer:LCDConnectionObserver;
		
		public function LCDConnection() {
			super();
			this.allowDomain("*");
			this.allowInsecureDomain("*");
			
			this.addEventListener( StatusEvent.STATUS, this.onStatus );
			
			this._sendArgs = new Array();
			this._knownConnIds = new Object();
			if( this.establishConnection() ) {
				this.ping();
			}
		}
		
		////////////////////////////////////////////////////////////////////////
		// Public Methods
		////////////////////////////////////////////////////////////////////////
	
		public function setObserver( observer:LCDConnectionObserver ):void {
			_observer = observer;	
		}
		
		public function destroy():void {
			if( this.isConnected() ) {
				this.close();	
			}	
		}
		
		public function getConnectionId():String {
			return _connId;	
		}
		
		public function isConnected():Boolean {
			return this.getConnectionId() != null;	
		}
		
		public function sendMsg( msg:String ):void {
			if( this.isConnected() ) {
				for( var connId:String in this._knownConnIds ) {
					if( LCDispatcher.lockedSendId == null || LCDispatcher.lockedSendId == connId ) {
						if( this._knownConnIds[ connId ] == true ) {
							this.supersend( connId, "receive", msg );	
						}
					} else {
						trace("LCDConnection.sendMsg() blocked send to: "+connId+" because locked to send Id is:" +LCDispatcher.lockedSendId );	
					}
				}
			}
		}
		
		public function receive( msg:String ):void {
			trace("LCDConnection.receive("+msg+")");
			if( msg != null && msg.length > 0 ) {
				if( _observer != null ) {
					_observer.receiveMsg( msg );	
				}
			}
		}
		
		/**
		 * This method is used to receive new LCD channel ids
		 */
		public function pong( otherConnId:String ):void {
			this._knownConnIds[ otherConnId ] = true;
		}
		
		
		////////////////////////////////////////////////////////////////////////
		// Private Methods
		////////////////////////////////////////////////////////////////////////
		
		private function onStatus( evt:StatusEvent ):void {
			switch( evt.level ) {
				case "error":
					trace( "error sending msg on connection id:" + this._sendArgs[0][0]+" msg:["+this._sendArgs[0][2]+"]");
					this._knownConnIds[ this._sendArgs[0][0] ] = null; // deactive broadcast channel
					break;
				case "status":
					if( this._knownConnIds[ this._sendArgs[0][0] ] == undefined ) {
						this._knownConnIds[ this._sendArgs[0][0] ] = true; // activate broadcast channel	
					}
					break;	
			}
			this._sendArgs.shift();
			if( this._sendArgs.length > 0 ) {
				trace(">> LCDConnection sending msg. [ conn:"+this._sendArgs[0][0]+", method:"+this._sendArgs[0][1]+", msg:"+this._sendArgs[0][2]+"]");
				super.send.apply( super, this._sendArgs[0] );
			}
		}
		
		private function supersend( ...arguments ):void {
			var sendArgs:Array = new Array();
			for( var i:Number = 0; i < arguments.length; ++i ) {
				sendArgs.push( arguments[i] );	
			}
			this._sendArgs.push( sendArgs );
			if( this._sendArgs.length == 1 ) {
				trace(">> LCDConnection sending msg. [ conn:"+this._sendArgs[0][0]+", method:"+this._sendArgs[0][1]+", msg:"+this._sendArgs[0][2]+"]");
				super.send.apply( super, this._sendArgs[0] );
			}	
		}
		
		private function setConnectionId( connId:String ):void {
			this._connId = connId;	
		}			
		
		private function ping():void {
			var connId:String = this.getConnectionId();
			if( connId != null ) {
				for( var knownConnId:String in this._knownConnIds ) {
					this.supersend( knownConnId, "pong", connId );
				}
			}
		}			
		
		/**
		 * this method will try to establish a local connection with an expected name of
		 * LCDConnection.LCD_CONN_ID_PREFIX + Number.  other LCDConnection objects will use
		 * this protocol to discover the existing channels.  this protocol only will allow
		 * LCDConnection.LCD_CONN_MAX_COUNT of LCDConnection objects to exist.
		 */
		private function establishConnection():Boolean {
			var connId:String = null;
			var connIdNum:Number = -1;
			
			while( ++connIdNum < LCDConnection.LCD_CONN_MAX_COUNT ) {
				connId = LCDConnection.LCD_CONN_ID_PREFIX + connIdNum;
				try {
					this.connect( connId );
					this.setConnectionId( connId );
					break;
				} catch ( e1:ArgumentError ) {
					this._knownConnIds[ connId ] = true;// activate broadcast channel
				}
			}
			
			var tmpLC:LocalConnection = new LocalConnection();
			while( ++connIdNum < LCDConnection.LCD_CONN_MAX_COUNT ) {
				connId = LCDConnection.LCD_CONN_ID_PREFIX + connIdNum;
				try {
					tmpLC.connect( connId );
					try {
						tmpLC.close();
					} catch ( e2:ArgumentError ) {
					}
				} catch ( e3:ArgumentError ) {
					this._knownConnIds[ connId ] = true;// activate broadcast channel
				}
			}
		
			return this.isConnected();
		}
		
		
		
	}

}