package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.ExpressionParser;
	import net.bordnerd.exparse.terms.Terminal;
	
	public class Variable 
		extends
			Terminal
	{
		
		public function Variable( strValue:String ) {
			super( strValue );	
		}
		
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			objHash[ this.getValue() ] = true;
			return [];	
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			return [];	
		}	
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return objDataProvidingParser.dataProvider.getDataValue( this.getValue() );
		}
		
		public override function toString():String {
			return this.getValue();	
		}
		
	}
}