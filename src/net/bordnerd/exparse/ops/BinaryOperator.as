package net.bordnerd.exparse.ops {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	
	public class BinaryOperator 
		extends
			Operator
	{
		
		private var objTerm1:ExpressionParser = null;
		private var objTerm2:ExpressionParser = null;
		
		public function BinaryOperator( strOperator:String, objTerm1:ExpressionParser, objTerm2:ExpressionParser ) {
			super( strOperator );
			this.objTerm1 = objTerm1;
			this.objTerm2 = objTerm2;
				
		}
		
		public function getTerm1():ExpressionParser {
			return this.objTerm1;	
		}
		
		public function getTerm2():ExpressionParser {
			return this.objTerm2;	
		}
		
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			var arrVars:Array = this.objTerm1.getVariables( objHash, objRootParser, objDataProvidingParser );
			arrVars = this.objTerm2.getVariables( objHash, objRootParser, objDataProvidingParser );
			return arrVars;
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			var arrVars:Array = this.objTerm1.getLValues( objHash, objRootParser, objDataProvidingParser );
			arrVars = this.objTerm2.getLValues( objHash, objRootParser, objDataProvidingParser );
			return arrVars;
		}
		
		public override function toString():String {
			return "( " + this.objTerm1.toString() + " " + this.getOperator() + " " + this.objTerm2.toString() + " )";
		}
		
	}
}