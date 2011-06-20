package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.Constant;
	import net.bordnerd.exparse.ExpressionParser;
	
	/**
	 * @author michael.bordner
	 */
	public class NumberConstant 
		extends 
			Constant 
	{
		private var numValue:Number = Number.NaN;
	
		public function NumberConstant( strValue:String ) {
			super( strValue );
			this.numValue = this.castNumber( strValue );
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return this.numValue.valueOf();	
		}
		
		public override function toString():String {
			return this.numValue.toString();	
		}
		
	}
}
