package net.bordnerd.exparse.ops.bin {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class Operator_NE 
		extends
			BinaryOperator
	{
	
		public function Operator_NE( objTerm1:ExpressionParser, objTerm2:ExpressionParser ) {
			super( "NE", objTerm1, objTerm2 );	
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return this.getTerm1().evaluate(objRootParser,objDataProvidingParser) != this.getTerm2().evaluate(objRootParser,objDataProvidingParser);	
		}
		
	}
}