package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.Constant;
	import net.bordnerd.exparse.ExpressionParser;
	/**
	 * @author michael.bordner
	 */
	public class StringConstant
		extends
			Constant 
	{
		public function StringConstant( strValue:String ) {
			super( strValue );
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return ExpressionParser.unescapeString( this.getValue() );	
		}
		
		public override function toString():String {
			return "'" + this.getValue() + "'";	
		}
	}
}