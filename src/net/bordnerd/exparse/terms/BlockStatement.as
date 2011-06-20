package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.Terminal;
	import net.bordnerd.exparse.ExpressionParser;
	
	/**
	 * @author michael.bordner
	 */
	public class BlockStatement
		extends
			Terminal 
	{
		private var boolHadBlock:Boolean = false;
		
		public function BlockStatement( strBody:String ) {
			super( strBody );
			if( strBody.charAt(0) == '{' ) {
				if( strBody.charAt( strBody.length -1 ) == '}' ) {
					this.boolHadBlock = true;
					this.parseS( strBody.substring( 1, strBody.length - 1 ) );
				} else {
					this.error("Expected closing }");	
				}	
			} else {
				this.parseS( strBody );	
			}
		}
		
		
		public override function toString():String {
			var strBody:String = super.toString();
			if( this.boolHadBlock == true ) {
				return "{ " + strBody + " }";
			} else {
				return strBody + ",";	
			}
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return this.evaluateExpressions(objRootParser,objDataProvidingParser).pop();		
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