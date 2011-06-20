package net.bordnerd.exparse.ops.bin {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.ops.*;
	import net.bordnerd.exparse.terms.*;
	
	public class Operator_ASGN
		extends 
			BinaryOperator 
	{
		public function Operator_ASGN( objTerm1:ExpressionParser, objTerm2:ExpressionParser ) {
			super( "=", objTerm1, objTerm2 );
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			var objTerm2Value:Object = this.getTerm2().evaluate( objRootParser, objDataProvidingParser );
					
			var objTerm1:ExpressionParser = this.getTerm1();
			
			var strIdentifier:String = null;
			
			if( objTerm1 is ArrayMapElement ) {
				
				var objArrMap:Object = ArrayMapElement( objTerm1 ).getEvaluatedArrayMap( objRootParser, objDataProvidingParser );
				var objIndex:Object = ArrayMapElement( objTerm1 ).getArrayMapIndex( objRootParser, objDataProvidingParser );
				if( objArrMap != null && ( objArrMap is Object ) && objIndex != null ) {
					if( 
						( ( objIndex is Number ) && objIndex >= 0 ) ||
						( ( objIndex is String ) && objIndex.length > 0 )										
					) {
						objArrMap[ objIndex ] = objTerm2Value;	
					}	
				}
			} else {			
				if( objTerm1 is Variable ) {
					strIdentifier = Variable(objTerm1).getValue();
				} else {
					strIdentifier = "" + objTerm1.evaluate( objRootParser, objDataProvidingParser );	
				}
				if( strIdentifier != null && strIdentifier.length > 0 ) {
					objDataProvidingParser.dataProvider.setDataValue( strIdentifier, objTerm2Value );
				}
			}
			return objTerm2Value;
		}
		
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			return this.getTerm2().getVariables( objHash, objRootParser, objDataProvidingParser );	
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			
			var objTerm1:ExpressionParser = this.getTerm1();
			
			var strIdentifier:String = null;
			if( objTerm1 is Variable ) {
				strIdentifier = Variable(objTerm1).getValue();
			} else if( objTerm1 is ArrayMapElement ) {
				strIdentifier = ArrayMapElement( objTerm1 ).getArrayMapName();
			} else {
				strIdentifier = String( objTerm1.evaluate( objRootParser, objDataProvidingParser ) );	
			}
			if( strIdentifier != null && strIdentifier.length > 0 ) {
				objHash[ strIdentifier ] = true;
			}
					
			return [];	
		}
	}
}