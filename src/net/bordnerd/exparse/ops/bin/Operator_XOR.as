package net.bordnerd.exparse.ops.bin {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class Operator_XOR 
		extends
			BinaryOperator
	{
	
		public function Operator_XOR( objTerm1:ExpressionParser, objTerm2:ExpressionParser ) {
			super( "XOR", objTerm1, objTerm2 );	
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			var boolTerm1:Boolean = Boolean( this.getTerm1().evaluate(objRootParser,objDataProvidingParser) );
			var boolTerm2:Boolean = Boolean( this.getTerm2().evaluate(objRootParser,objDataProvidingParser) );
			return ( (boolTerm1 && !boolTerm2) || (!boolTerm1 && boolTerm2) );	
		}
		
	}
}