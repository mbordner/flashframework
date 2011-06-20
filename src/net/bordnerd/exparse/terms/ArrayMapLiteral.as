package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.Terminal;
	import net.bordnerd.exparse.ExpressionParser;
	import net.bordnerd.exparse.ops.bin.Operator_PROP;
	/**
	 * @author michael.bordner
	 */
	public class ArrayMapLiteral
		extends
			Terminal 
	{
		public function ArrayMapLiteral( strBody:String ) {
			super( strBody );
			if( strBody.charAt(0) == '[' ) { 
				if( strBody.charAt( strBody.length -1 ) == ']' ) {
					this.parseS( strBody.substring( 1, strBody.length -1 ) );
				} else {
					this.error("Expected closing ]");
				}	
			} else {
				this.error("Expected opening [");	
			}
		}
		
		public override function toString():String {
			var strBody:String = super.toString();
			return "[" + strBody + "]";
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			var arrTmp:Array = new Array();
			var arrValues:Array = this.evaluateExpressions( objRootParser, objDataProvidingParser );
			if( this.arrRootNode != null ) {
				for( var i:uint = 0; i < this.arrRootNode.length; ++i ) {
					if( this.arrRootNode[i] is Operator_PROP ) {
						var objProp:Operator_PROP = Operator_PROP( this.arrRootNode[i] );
						arrTmp[ objProp.getTerm1().evaluate(objRootParser,objDataProvidingParser) ] = objProp.getTerm2().evaluate( objRootParser, objDataProvidingParser );
					} else {
						arrTmp.push( arrValues[i] );	
					}	
				}
			}
			return arrTmp;
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			if( this.arrRootNode != null ) {
				for( var i:uint = 0; i < this.arrRootNode.length; ++i ) {
					ExpressionParser(this.arrRootNode[i]).getLValues( objHash, objRootParser, objDataProvidingParser );	
				}
			}
			return [];
		}
		
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			if( this.arrRootNode != null ) {
				for( var i:uint = 0; i < this.arrRootNode.length; ++i ) {
					this.arrRootNode[i].getVariables( objHash, objRootParser, objDataProvidingParser );	
				}
			}
			return [];	
		}
	}
}