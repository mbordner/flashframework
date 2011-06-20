package net.bordnerd.exparse.ops {
	import net.bordnerd.exparse.ExpressionParser;
	
	public class Operator
		extends 
			ExpressionParser 
	{
		
		private var strOperator:String = null;
		
		public function Operator( strOperator:String ) {
			super();
			this.strOperator = strOperator;
		}
		
		public function getOperator():String {
			return this.strOperator;	
		}
	
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return null;	
		}
		
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			return [];
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			return [];			
		}
		
		public override function toString():String {
			return "( " + this.strOperator + " ) ";	
		}
	
	}
}