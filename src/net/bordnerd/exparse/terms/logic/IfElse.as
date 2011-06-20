package net.bordnerd.exparse.terms.logic {
	import net.bordnerd.exparse.terms.Terminal;
	import net.bordnerd.exparse.ExpressionParser;
	
	/**
	 * @author michael.bordner
	 */
	public class IfElse
		extends
			Terminal 
	{
		private var objConditionTree:ExpressionParser = null;
		private var objIfTree:ExpressionParser = null;
		private var objElseTree:ExpressionParser = null;
		
		public function IfElse( strBody:String ) {
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
					++this.numConsumption;// 1 past the closing ) to the start of the if block
					
					if( this.objConditionTree.wasError() == false ) {
					
						this.objIfTree = new ExpressionParser();
						this.objIfTree.parseS( strBody.substring( this.numConsumption ), 1 );// parse off 1 statement
						
						if( this.objIfTree.wasError() == false ) {
							
							this.numConsumption += this.objIfTree.getConsumption();
							if( this.numConsumption < strBody.length ) {
								this.numConsumption = ExpressionParser.lookAhead( arrChars, this.numConsumption );
								if( this.numConsumption <= arrChars.length - 4 && strBody.substring( this.numConsumption, this.numConsumption + 4).toUpperCase() == "ELSE" ) {
									this.numConsumption += 4;//pass by the ELSE
									this.objElseTree = new ExpressionParser();
									this.objElseTree.parseS( strBody.substring( this.numConsumption ), 1 );// parse off 1 statement	
									if( this.objElseTree.wasError() == true ) {
										this.error( this.objElseTree.getErrorMsg() );	
									} else {
										this.numConsumption += this.objElseTree.getConsumption();	
									}
								}	
							}
												
						} else {
							this.error( this.objIfTree.getErrorMsg() );
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
			if( this.objIfTree != null ) {
				this.objIfTree.getVariables( objHash, objRootParser, objDataProvidingParser );
			}
			if( this.objElseTree != null ) {
				this.objElseTree.getVariables( objHash, objRootParser, objDataProvidingParser );
			}
			return [];	
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			if( this.objConditionTree != null ) {
				this.objConditionTree.getLValues( objHash, objRootParser, objDataProvidingParser );
			}
			if( this.objIfTree != null ) {
				this.objIfTree.getLValues( objHash, objRootParser, objDataProvidingParser );
			}
			if( this.objElseTree != null ) {
				this.objElseTree.getLValues( objHash, objRootParser, objDataProvidingParser );
			}
			return [];
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			this.clearReturnValue();
			if( this.objConditionTree != null ) {
				if( this.objConditionTree.evaluate(objRootParser,objDataProvidingParser) ) {
					if( this.objIfTree != null ) {
						return this.evaluateBranch( this.objIfTree, objRootParser, objDataProvidingParser);	
					}	
				} else {
					if( this.objElseTree != null ) {
						return this.evaluateBranch( this.objElseTree, objRootParser, objDataProvidingParser);	
					}
				}
			}
			return undefined;	
		}
		
		private function evaluateBranch( objBranch:ExpressionParser, objRootParser:ExpressionParser, objDataProvidingParser:ExpressionParser ):Object {
			var objValue:Object = objBranch.evaluate( objRootParser, objDataProvidingParser );
			if( objBranch.hadReturnValue() ) {
				this.setReturnValue( objBranch.getReturnValue() );	
			}
			return objValue;
		}
		
		public override function toString():String {
			var strTmp:String = "IF";
			if( this.objConditionTree != null ) {
				strTmp += "( " + this.objConditionTree.toString() + " )";
				if( this.objIfTree != null ) {
					strTmp += " " + this.objIfTree.toString();
					if( this.objElseTree != null ) {
						strTmp += " ELSE " + this.objElseTree.toString();	
					}	
				}
			}
			return strTmp;	
		}
		
	}
}