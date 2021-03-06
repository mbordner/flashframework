package net.bordnerd.exparse.ops.bin {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class Operator_AND 
		extends
			BinaryOperator
	{
	
		public function Operator_AND( objTerm1:ExpressionParser, objTerm2:ExpressionParser ) {
			super( "AND", objTerm1, objTerm2 );	
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return Boolean(this.getTerm1().evaluate(objRootParser,objDataProvidingParser)) && Boolean(this.getTerm2().evaluate(objRootParser,objDataProvidingParser));	
		}
		
	}
}