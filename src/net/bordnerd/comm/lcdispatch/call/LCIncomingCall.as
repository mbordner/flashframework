package net.bordnerd.comm.lcdispatch.call {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.xmlser.*;
	import net.bordnerd.comm.lcdispatch.call.*;
	
	public class LCIncomingCall
		extends
			LCCall 
	{
		
		public function LCIncomingCall( connId:String, xml:XML ) {
			super();
			if( connId != null && connId.length > 0 ) {
				this.setConnId( connId );
				if( xml != null && xml.name() == "c" ) {
					var id:String = xml.@i;
					var name:String = xml.@n;
					var args:Array = Deserializer.deserializeArray( xml );
					this.setId( id );
					this.setName( name );
					this.setArgs( args );
				}
			}	
		}
		
	}

}