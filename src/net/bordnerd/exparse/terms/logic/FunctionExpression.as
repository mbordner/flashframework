package net.bordnerd.exparse.terms.logic {
	
	import net.bordnerd.exparse.terms.Terminal;
	import net.bordnerd.exparse.ExpressionParser;
	import net.bordnerd.exparse.functiontable.TableFunction;
	import net.bordnerd.exparse.functiontable.FunctionTable;
	import net.bordnerd.exparse.terms.Variable;
	import net.bordnerd.exparse.LocalDataProvider;
	
	/**
	 * @author michael.bordner
	 */
	public class FunctionExpression
		extends 
			Terminal
		implements
			TableFunction 
	{
		private var strFunctionIdentifier:String = null;
		
		private var objArgListTree:ExpressionParser = null;
		private var objBodyTree:ExpressionParser = null;
		
		private var arrArgumentListVariables:Array = null;
		
		public function FunctionExpression( strBody:String ) {
			this.numConsumption = -1;
			
			var arrChars:Array = strBody.split("");
			
			var numIndex:Number = ExpressionParser.findStart( arrChars, 0, WHITESPACEANDTOKENS );
			if( numIndex < arrChars.length ) {
					
					strFunctionIdentifier = strBody.substring( 0, numIndex );
					numIndex = ExpressionParser.lookAhead( arrChars, numIndex );
					
					if( arrChars[numIndex] == '(' ) {
						
						this.numConsumption = ExpressionParser.findGroupClose( arrChars, numIndex, "(", ")" );
						if( this.numConsumption == -1 ) {
							this.error("Expected arguments close )");	
						} else {
							this.objArgListTree = new ExpressionParser( strBody.substring( numIndex + 1, this.numConsumption ) );
							++this.numConsumption; // 1 past the closing ) to the start of the body block
							
							if( this.objArgListTree.wasError() == false ) {
							
								var boolAllArguments:Boolean = true;
								this.arrArgumentListVariables = new Array();
								var arrParsedExpressions:Array = this.objArgListTree.getParsedExpressions();
								for( var i:uint = 0; i < arrParsedExpressions.length; ++i ) {
									if( !( arrParsedExpressions[i] is Variable ) ) {
										boolAllArguments = false;
										break;	
									} else {
										this.arrArgumentListVariables.push( Variable(arrParsedExpressions[i]).getValue() );
									}	
								}
								
								if( boolAllArguments ) {
								
									this.objBodyTree = new ExpressionParser();
									this.objBodyTree.parseS( strBody.substring( this.numConsumption ), 1 ); // only parse off one more expression
									
									if( this.objBodyTree.wasError() == false ) {
										this.numConsumption += this.objBodyTree.getConsumption();
										
										FunctionTable.getInstance().addFunctionExpression( this.strFunctionIdentifier, this );
										
									} else {
										this.error( this.objBodyTree.getErrorMsg() );	
									}
								
								} else {
									this.error("Invalid argument list");
								}
								
							} else {
								this.error( this.objArgListTree.getErrorMsg() );	
							}
											
						}
						
					} else {
						this.error("Expected arguments Start (");	
					}
				
			} else {
				this.error("Unexpected function end.");	
			}		
			
		}
		
		public function call(  ...arrOtherArgs:Array /* arg1:Object, arg2:Object, argN:Object */ ):Object {
			var arrArguments:Array = [ this, this, [] ];
			for( var i:uint = 0; i < arrOtherArgs.length; ++i ) {
				arrArguments[2].push( arrOtherArgs[i] );	
			}
			return this.execute.apply( this, arrArguments );	
		}
		
		public function execute( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null, arrArgs:Array = null ):Object {		
			objDataProvidingParser = new ExpressionParser();
			var objLocalDataProvider:LocalDataProvider = objDataProvidingParser.createLocalDataProvider();
			objLocalDataProvider.setLocalDataValue( "arguments", arrArgs );
			
			for( var i:uint = 0; i < this.arrArgumentListVariables.length; ++i ) {
				objLocalDataProvider.setLocalDataValue( this.arrArgumentListVariables[i], arrArgs[i] );	
			}
			
			var objValue:Object = this.objBodyTree.evaluate( objRootParser, objDataProvidingParser );
			if( this.objBodyTree.hadReturnValue() ) {
				return this.objBodyTree.getReturnValue();	
			}
				
			return objValue;	
		}
		
		public function getIdentifier():String {
			return this.strFunctionIdentifier;	
		}
	
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			if( this.objArgListTree != null ) {
				this.objArgListTree.getVariables( objHash, objRootParser, objDataProvidingParser );
			}
			if( this.objBodyTree != null ) {
				this.objBodyTree.getVariables( objHash, objRootParser, objDataProvidingParser );
			}
			return [];	
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			if( this.objArgListTree != null ) {
				this.objArgListTree.getLValues( objHash, objRootParser, objDataProvidingParser );
			}
			if( this.objBodyTree != null ) {
				this.objBodyTree.getLValues( objHash, objRootParser, objDataProvidingParser );
			}
			return [];
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			var objFunctionExpression:FunctionExpression = this;
			var funcTmp:Function = function():Object {
				return objFunctionExpression.execute();
			};
			return Object(funcTmp);	
		}
		
		public override function toString():String {
			var strTmp:String = "FUNCTION " + this.strFunctionIdentifier;
			if( this.objArgListTree != null ) {
				strTmp += "( " + this.objArgListTree.toString() + " )";
				if( this.objBodyTree != null ) {
					strTmp += " " + this.objBodyTree.toString();
				}
			}
			return strTmp;	
		}
		
	}
}