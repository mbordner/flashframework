package net.bordnerd.comm.lcdispatch.msg {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.lcdispatch.msg.*; 
	 
	public class LCOutgoingMsg extends LCMsg 
	{
		public function LCOutgoingMsg( connId:String, id:String, msg:String ) {
			super();
			if( connId != null && connId.length > 0 ) {
				this.setConnId( connId );
				if( id != null && id.length > 0 ) {
					this.setId( id );
					if( msg != null && msg.length > 0 ) {
						this.append( msg );
						this.setContentLength( msg.length );
					}
				}
			}
		}
		
	}

}