package net.bordnerd.comm.lcdispatch.msg {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.lcdispatch.msg.*; 
	 
	public class LCIncomingMsg extends LCMsg 
	{
		public function LCIncomingMsg( msg:String ) {
			super();
			if( msg != null && msg.length > 0 ) {
				var tokens:Array = msg.split( LCMsg.DELIM );
				if( tokens.length >= 2 ) {
					var header:String = String(tokens.shift());
					this.parseHeader( header );
					var strContent:String = tokens.join( LCMsg.DELIM );
					this.append( strContent ); 	
				}	
			}	
		}	
	}

}