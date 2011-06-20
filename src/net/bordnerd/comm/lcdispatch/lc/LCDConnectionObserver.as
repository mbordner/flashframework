package net.bordnerd.comm.lcdispatch.lc {
	/**
	 * @author michael.bordner
	 */
	public interface LCDConnectionObserver 
	{
		function receiveMsg( msg:String ):void;
	}

}
