package net.bordnerd.exparse.ops {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class UnaryOperator
		extends
			Operator
	{
		private var objTerm1:ExpressionParser = null;
		
		public function UnaryOperator( strOperator:String, objTerm1:ExpressionParser ) {
			super( strOperator );
			this.objTerm1 = objTerm1;		
		}
		
		public function getTerm1():ExpressionParser {
			return this.objTerm1;	
		}
		
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			var arrVars:Array = this.objTerm1.getVariables( objHash, objRootParser, objDataProvidingParser );
			return arrVars;
		}
		
		public override function toString():String {
			if( ExpressionParser.getOperatorDefinition( this.getOperator() ).a == 1 ) {
				return "( " + this.getOperator() + " " + this.objTerm1.toString() + " )";
			} else {
				return "( " + this.objTerm1.toString() + " " + this.getOperator() + " )";
			}
		}
	}
}