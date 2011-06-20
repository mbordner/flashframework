package net.bordnerd.comm.lcdispatch.call {
	/**
	 * @author michael.bordner
	 */
	
	import net.bordnerd.comm.lcdispatch.event.*;
	import net.bordnerd.comm.lcdispatch.call.*;
	import net.bordnerd.comm.lcdispatch.msg.*;
	import flash.utils.Timer;
	import flash.events.*;
	
	public class LCOutgoingCall
		extends
			LCCall 
	{
		private static const LCD_CALL_TIMEOUT:Number = 5000;
		
		private var _returnHandler:Function;
		private var _timer:Timer;
			
		public function LCOutgoingCall( id:String, connId:String, name:String, args:Array, returnHandler:Function = null ) {
			super();
			this.setId( id );
			this.setConnId( connId );
			this.setName( name );
			this.setArgs( args );
			_returnHandler = returnHandler;
		}
	
		public function processCall( msgQueue:MsgQueue ):void {
			if( _returnHandler != null ) {
				_timer = new Timer( LCD_CALL_TIMEOUT, 1 );
				_timer.addEventListener( TimerEvent.TIMER_COMPLETE, timeOut );
			}
			msgQueue.sendMsg( this.id, this.toString() );
			if( _returnHandler != null ) {
				_timer.start();
			}
		}
		
		public function processReturn( lcReturn:LCReturn ):void {
			trace("LCOutgoingCall.processReturn( lcReturn )");
			if( _timer != null ) {
				_timer.removeEventListener( TimerEvent.TIMER_COMPLETE, timeOut );
				_timer.stop();				
				_timer = null;									
			}
			if( _returnHandler != null ) {
				_returnHandler( lcReturn );	
			}
		}
		
		private function timeOut( evt:TimerEvent ):void {
			trace("LCOutgoingCall.timeOut(evt)");
			if( _timer != null ) {
				_timer.removeEventListener( TimerEvent.TIMER_COMPLETE, timeOut );
				_timer = null;	
				this.dispatchEvent( new OutgoingCallTimeoutEvent( this.id ) );
			}
		}
	
	}
}