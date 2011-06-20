package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.terms.*;
	
	public class Terminal 
		extends
			ExpressionParser
	{
		
		private var strValue:String = null;
		
		public function Terminal( strValue:String = null ) {
			super();
			this.strValue = strValue;	
		}
		
		public function getValue():String {
			return this.strValue;	
		}
		
	}
}