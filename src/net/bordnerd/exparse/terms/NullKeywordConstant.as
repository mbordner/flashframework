package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.KeywordConstant;
	import net.bordnerd.exparse.ExpressionParser;
	
	/**
	 * @author michael.bordner
	 */
	public class NullKeywordConstant
		extends
			KeywordConstant 
	{
		public function NullKeywordConstant() {
			super("NULL");
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return null;	
		}
		
		public override function toString():String {
			return this.getValue();	
		}
	}
}