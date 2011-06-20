package net.bordnerd.exparse.ops.bin {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class Operator_GE 
		extends
			BinaryOperator
	{
	
		public function Operator_GE( objTerm1:ExpressionParser, objTerm2:ExpressionParser ) {
			super( "GE", objTerm1, objTerm2 );	
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return this.getTerm1().evaluate(objRootParser,objDataProvidingParser) >= this.getTerm2().evaluate(objRootParser,objDataProvidingParser);	
		}
		
	}
}