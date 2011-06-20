package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.Terminal;
	
	/**
	 * @author michael.bordner
	 */
	public class Constant
		extends 
			Terminal 
	{
		public function Constant( strValue:String ) {
			super(strValue);
		}
	
	}
}