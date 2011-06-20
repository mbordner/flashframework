package net.bordnerd.activity.debug {
	
	import net.bordnerd.comm.lcdispatch.LCDispatcher;
	import net.bordnerd.comm.lcdispatch.event.LCDispatchEvent;
	import net.bordnerd.comm.lcdispatch.call.LCReturn;
	import net.bordnerd.comm.lcdispatch.event.RemoteCallInvocationEvent;
	import net.bordnerd.comm.lcdispatch.event.OutgoingCallTimeoutEvent;
	
	import net.bordnerd.activity.debug.SessionStateManager;
	
	/**
	 * @author michael.bordner
	 */
	public class SessionStateService 
	{
		
		private static var _instance:SessionStateService = null;
	
		private var _lcd:LCDispatcher;
		private var _manager:SessionStateManager;
		
		public function SessionStateService(){
			_lcd = LCDispatcher.getInstance();
			_lcd.addEventListener( LCDispatchEvent.REMOTE_CALL_INVOCATION, this.handleRemoteCallInvocationEvent );
			_lcd.addEventListener( LCDispatchEvent.OUTGOING_CALL_TIMEOUT, this.handleRemoteCallTimeoutEvent );
		}
		
		public static function getInstance():SessionStateService {
			if( _instance == null ) {
				_instance = new SessionStateService();	
			}
			return _instance;	
		}
		
		public function setManager( manager:SessionStateManager ):void {
			_manager = manager;	
		}
		
		private function handleRemoteCallInvocationEvent( evt:RemoteCallInvocationEvent ):void {
			if( evt ) {
				var name:String = evt.name;
				var args:Array = evt.args;				
				
				if( name == "getSessionState" ) {
					if( _manager != null ) {
						evt.setReturnValue( _manager.getSessionState() );	
					} else {
						evt.setReturnValue( null ); // flag that we didn't handle the call, but did receive it.  the timeout will not be raised in this case.			
					}
				} else if( name == "setSessionState" && args.length > 0 ) {
					if( _manager != null ) {
						_manager.setSessionState( args[0] as String );				
					}
					evt.setReturnValue( null );					
				}
								
			}
		}
		
		private function handleRemoteCallTimeoutEvent( evt:OutgoingCallTimeoutEvent ):void {
			if( evt ) {
				
			}
		}
		
		
		
	}
}
