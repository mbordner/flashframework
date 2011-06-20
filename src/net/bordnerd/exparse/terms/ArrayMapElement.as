package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.Terminal;
	import net.bordnerd.exparse.ExpressionParser;
	
	/**
	 * @author michael.bordner
	 */
	public class ArrayMapElement
		extends
			Terminal 
	{
		private var strArrayMapName:String = null;
		
		private var objArrayMapExpression:ExpressionParser = null;
		private var objReferenceExpression:ExpressionParser = null;
		
		public function ArrayMapElement( strArrayMapName:String, strReference:String ) {
			this.strArrayMapName = strArrayMapName;
			
			var arrChars:Array = strReference.split("");
			if( arrChars[0] == '[' ) {
				var numStartPos:Number = 0;
				var numClosePos:Number = ExpressionParser.findGroupClose( arrChars, 0, "[", "]" );
				
				var boolLookingForMultiDimensionalReference:Boolean = true;
				while( numClosePos != -1 && boolLookingForMultiDimensionalReference ) {
					var numTmpStart:Number = ExpressionParser.lookAhead( arrChars, numClosePos + 1 );
					if( numTmpStart < arrChars.length && arrChars[numTmpStart] == "[" ) {
						numStartPos = numTmpStart; // found a multi dimensional reference
						numClosePos = ExpressionParser.findGroupClose( arrChars, numTmpStart, "[", "]" );
					} else {
						// next token was not a multi dimensional reference
						boolLookingForMultiDimensionalReference = false;
					}
				}
				
				if( numClosePos != -1 ) {
					
					this.objArrayMapExpression = new ExpressionParser( strArrayMapName + strReference.substring(0,numStartPos) );
					if( this.objArrayMapExpression.wasError() == false ) {
						this.objReferenceExpression = new ExpressionParser( strReference.substring( numStartPos + 1, numClosePos ) );
						if( this.objReferenceExpression.wasError() ) {
							this.error( this.objReferenceExpression.getErrorMsg() );	
						}
					} else {
						this.error( this.objArrayMapExpression.getErrorMsg() );	
					}
					this.numConsumption = numClosePos + 1;
					
				} else {
					this.error("Expected closing ]");	
				}
					
			} else {
				this.error("Expected opening [");
			}
		}
		
		public function getArrayMapName():String {
			return this.strArrayMapName;	
		}
		
		public function getEvaluatedArrayMap( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return this.objArrayMapExpression.evaluate( objRootParser, objDataProvidingParser );	
		}
		
		public function getArrayMapIndex( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return this.objReferenceExpression.evaluate( objRootParser, objDataProvidingParser );	
		}
		
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			objHash[ this.getValue() ] = true;
			return [];	
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			return [];	
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			return this.getEvaluatedArrayMap( objRootParser, objDataProvidingParser )[ this.getArrayMapIndex(objRootParser,objDataProvidingParser) ];
		}
		
		public override function toString():String {
			return this.objArrayMapExpression.toString() + "[" + this.objReferenceExpression.toString() + "]";
		}
		
	}
}