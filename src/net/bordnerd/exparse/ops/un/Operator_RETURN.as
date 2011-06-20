package net.bordnerd.exparse.ops.un {
	
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class Operator_RETURN 
		extends
			UnaryOperator
	{
		public function Operator_RETURN( objTerm1:ExpressionParser ) {
			super( "RETURN", objTerm1 );	
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return this.getTerm1().evaluate( objRootParser, objDataProvidingParser );	
		}
	}
}