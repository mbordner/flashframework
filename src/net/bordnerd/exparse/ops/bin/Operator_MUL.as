package net.bordnerd.exparse.ops.bin {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class Operator_MUL
		extends 
			BinaryOperator 
	{
		public function Operator_MUL( objTerm1:ExpressionParser, objTerm2:ExpressionParser ) {
			super( "MUL", objTerm1, objTerm2 );
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return Number(this.getTerm1().evaluate(objRootParser,objDataProvidingParser)) * Number(this.getTerm2().evaluate(objRootParser,objDataProvidingParser));	
		}
	}
}