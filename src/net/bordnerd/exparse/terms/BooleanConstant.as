package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.Constant;
	import net.bordnerd.exparse.ExpressionParser;
	
	/**
	 * @author michael.bordner
	 */
	public class BooleanConstant
		extends
			Constant 
	{
		private var boolValue:Boolean = false;
		
		public function BooleanConstant( strValue:String ) {
			super( strValue );
			this.boolValue = new Boolean( this.castBoolean( strValue ) );	
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return this.boolValue.valueOf();	
		}
		
		public override function toString():String {
			return this.boolValue.toString();	
		}
	}
}