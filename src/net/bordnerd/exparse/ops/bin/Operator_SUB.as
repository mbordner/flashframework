package net.bordnerd.exparse.ops.bin {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class Operator_SUB
		extends 
			BinaryOperator 
	{
		public function Operator_SUB( objTerm1:ExpressionParser, objTerm2:ExpressionParser ) {
			super( "SUB", objTerm1, objTerm2 );
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return Number(this.getTerm1().evaluate(objRootParser,objDataProvidingParser)) - Number(this.getTerm2().evaluate(objRootParser,objDataProvidingParser));	
		}
	}
}