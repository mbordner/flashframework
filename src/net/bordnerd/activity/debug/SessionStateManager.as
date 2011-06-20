package net.bordnerd.activity.debug {

	/**
	 * @author michael.bordner
	 */
	public interface SessionStateManager 
	{
	
		function setSessionState( s:String ):void;
		function getSessionState():String;
				
	}
}
