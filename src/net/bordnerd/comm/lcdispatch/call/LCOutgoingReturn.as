package net.bordnerd.comm.lcdispatch.call {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.lcdispatch.call.LCReturn; 
	 
	public class LCOutgoingReturn
		extends
			LCReturn 
	{
		public function LCOutgoingReturn( id:String, connId:String ) {
			super();
			this.setId( id );
			this.setConnId( connId );	
		}
		
	}

}
