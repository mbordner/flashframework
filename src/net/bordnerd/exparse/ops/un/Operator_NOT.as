package net.bordnerd.exparse.ops.un {
	
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class Operator_NOT 
		extends
			UnaryOperator
	{
		public function Operator_NOT( objTerm1:ExpressionParser ) {
			super( "NOT", objTerm1 );	
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return !this.getTerm1().evaluate( objRootParser, objDataProvidingParser );	
		}
	}
}