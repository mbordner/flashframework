package net.bordnerd.exparse.ops.bin {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class Operator_PROP
		extends 
			BinaryOperator 
	{
		
		/**
		 * This is an internal operator, used only in construction of ArrayMapLiteral objects.
		 * This operator is used to define properties on the ArrayMap.
		 */
		public function Operator_PROP( objTerm1:ExpressionParser, objTerm2:ExpressionParser ) {
			super( ":", objTerm1, objTerm2 );
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return null;	
		}
	
	}
}