package net.bordnerd.exparse.terms.logic {
	import net.bordnerd.exparse.terms.Terminal;
	import net.bordnerd.exparse.ExpressionParser;
	
	/**
	 * @author michael.bordner
	 */
	public class While
		extends
			Terminal 
	{
		private var objConditionTree:ExpressionParser = null;
		private var objBodyTree:ExpressionParser = null;
		
		public function While( strBody:String ) {
			this.numConsumption = -1;
			
			var arrChars:Array = strBody.split("");
			
			if( arrChars[0] == '(' ) {
				// this.consumption will be the number of extra characters to consume
				// which the parent parse tree will use to adjust its pointers.
				//	if strCall was () then consumption would be 1, essentially the index into the body
				//	of the last character that ended the body
				this.numConsumption = ExpressionParser.findGroupClose( arrChars, 0, "(", ")" );
				
				if( this.numConsumption == -1 ) {
					this.error("Expected closing )");	
				} else {
					this.objConditionTree = new ExpressionParser( strBody.substring( 1, this.numConsumption ) );
					++this.numConsumption; // 1 past the closing ) to the start of the body block
	
					if( this.objConditionTree.wasError() == false ) {
	
						this.objBodyTree = new ExpressionParser();
						this.objBodyTree.parseS( strBody.substring( this.numConsumption ), 1 );// only parse off one more expression
						
						if( this.objBodyTree.wasError() == false ) {
							this.numConsumption += this.objBodyTree.getConsumption();										
						} else {
							this.error( this.objBodyTree.getErrorMsg() );	
						}
					
					} else {
						this.error( this.objConditionTree.getErrorMsg() );	
					}
					
				}
			} else {
				this.error("Expected starting (");	
			}	
			
		}
		
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			if( this.objConditionTree != null ) {
				this.objConditionTree.getVariables( objHash, objRootParser, objDataProvidingParser );
			}
			if( this.objBodyTree != null ) {
				this.objBodyTree.getVariables( objHash, objRootParser, objDataProvidingParser );
			}
			return [];	
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			if( this.objConditionTree != null ) {
				this.objConditionTree.getLValues( objHash, objRootParser, objDataProvidingParser );
			}
			if( this.objBodyTree != null ) {
				this.objBodyTree.getLValues( objHash, objRootParser, objDataProvidingParser );
			}
			return [];
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			var arrEvaluations:Array = new Array();
			this.clearReturnValue();
			if( this.objConditionTree != null ) {
				while( this.objConditionTree.evaluate(objRootParser,objDataProvidingParser) ) {
					if( this.objBodyTree != null ) {
						arrEvaluations.push( this.objBodyTree.evaluate(objRootParser,objDataProvidingParser) );
						if( this.objBodyTree.hadReturnValue() ) {
							this.setReturnValue( this.objBodyTree.getReturnValue() );
							break;	
						}
					}	
				}			
			}
			return arrEvaluations;	
		}
		
		public override function toString():String {
			var strTmp:String = "WHILE";
			if( this.objConditionTree != null ) {
				strTmp += "( " + this.objConditionTree.toString() + " )";
				if( this.objBodyTree != null ) {
					strTmp += " " + this.objBodyTree.toString();
				}
			}
			return strTmp;	
		}
		
		
	}
}