package net.bordnerd.comm.lcdispatch.call {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.xmlser.*; 
	import net.bordnerd.comm.lcdispatch.call.LCReturn;
	 
	public class LCIncomingReturn 
		extends
			LCReturn
	{
		
		public function LCIncomingReturn( connId:String, xml:XML ) {
			super();
			if( connId != null && connId.length > 0 ) {
				this.setConnId( connId );
				if( xml != null && xml.name() == "r" ) {
					xml = xml.normalize();
					var id:String = xml.@i;
					var value:* = Deserializer.deserializeProperty( xml.children()[0] );
					this.setId( id );
					this.setValue( value );
				}
			}
		}
		
	}

}