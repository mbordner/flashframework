package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.Terminal;
	import net.bordnerd.exparse.ExpressionParser;
	import net.bordnerd.exparse.console.Console;
	import net.bordnerd.exparse.functiontable.*;
	import flash.utils.*;
	
	/**
	 * @author michael.bordner
	 */
	public class FunctionCall
		extends
			Terminal 
	{
		private var strFunctionName:String = null;
		
		public function FunctionCall( strFunctionName:String, strCall:String ) {
			this.strFunctionName = strFunctionName;
			var arrChars:Array = strCall.split("");
			if( arrChars[0] == '(' ) {
				// this.consumption will be the number of characters that need to be consumed from strCall
				//   -- essentially, given the string strCall, getConsumption() will give the number of
				// 		characters in strCall that this node should consume
				//	ie..
				//	if strCall was () then consumption would be 2
				var numTempConsumption:Number = ExpressionParser.findGroupClose( arrChars, 0, "(", ")" );
				if( numTempConsumption == -1 ) {
					this.error("Expected closing )");	
				} else {
					var numConsumption:Number = numTempConsumption + 1;
					super( this.strFunctionName + strCall.substring(0, numConsumption) );
					this.parseS( strCall.substring( 1, numTempConsumption ) );
					
					// override ExpressionParser property
					this.numConsumption = numConsumption;
				}
			} else {
				this.error("Expected opening (");
			}
		}
		
		public override function getVariables( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			if( this.arrRootNode != null ) {
				for( var i:uint = 0; i < this.arrRootNode.length; ++i ) {
					this.arrRootNode[i].getVariables( objHash, objRootParser, objDataProvidingParser );	
				}
			}
			return [];	
		}
		
		public override function getLValues( objHash:Object = null, objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Array {
			if( this.arrRootNode != null ) {
				switch( this.strFunctionName ) {
					case "INCR":
					case "DECR":
						objHash[ this.arrRootNode[0].getValue() ] = true;
						break;		
				}
			}
			return [];	
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			var arrValues:Array = this.evaluateExpressions( objRootParser, objDataProvidingParser );
			var numTmp:Number = 0;
			var objTmp:Object = null;
			var objExpressionParser:ExpressionParser = null;
	
			var strFunctionIdentifier:String = this.strFunctionName;
			
			var objFunction:TableFunction = objDataProvidingParser.dataProvider.getTableFunction( strFunctionIdentifier );
			if( objFunction != null ) {
				
				return objFunction.execute( objRootParser, objDataProvidingParser, arrValues );
				
			} else {
				strFunctionIdentifier = strFunctionIdentifier.toUpperCase();
			
				switch( strFunctionIdentifier ) {
					case "DELAY":					
						setTimeout( new ExpressionParser( arrValues[0] ).evaluate, Number(arrValues[1]) * 1000 );
						return null;
					case "INCR":
						numTmp = arrValues[0] + 1;
						objDataProvidingParser.dataProvider.setDataValue( this.arrRootNode[0].getValue(), numTmp );
						return numTmp;
					case "DECR":
						numTmp = arrValues[0] - 1;
						objDataProvidingParser.dataProvider.setDataValue( this.arrRootNode[0].getValue(), numTmp );
						return numTmp;
					case "EVAL":
						objExpressionParser = new ExpressionParser( arrValues[0] );
						return objExpressionParser.evaluate( objRootParser, objDataProvidingParser );
					case "LENGTH":
						if( arrValues[0] is String || arrValues[0] is Array ) {
							return arrValues[0].length;	
						}
						return null;
					case "SPLIT":
						if( (arrValues[0] is String) && (arrValues[1] is String) ) {
							return arrValues[0].split( arrValues[1] );
						} else {
							return null;	
						}
					case "JOIN":
						if( arrValues[0] is Array && (arrValues[1] is String) ) {
							return arrValues[0].join( arrValues[1] );
						} else {
							return null;						
						}
					case "PUSH":
						if( arrValues[0] is Array ) {
							arrValues[0].push( arrValues[1] );
						}
						return arrValues[1];
					case "POP":
						if( arrValues[0] is Array ) {
							objTmp = arrValues[0].pop();
							return objTmp;	
						}
						return null;
					case "SHIFT":
						if( arrValues[0] is Array ) {
							objTmp = arrValues[0].shift();
							return objTmp;	
						}
						return null;
					case "UNSHIFT":
						if( arrValues[0] is Array ) {
							arrValues[0].unshift( arrValues[1] );
						}
						return arrValues[1];
					case "SPLICE":
						if( arrValues[0] is Array && arrValues.length >= 3 ) {
							return arrValues[0].splice( arrValues[1], arrValues[2], arrValues[3] );	
						}
						return null;
					case "OUT":
						ExpressionParser.getConsole().out( arrValues[0], objRootParser );
						return null;
					case "MIN":
					case "MAX":
						arrValues.sort( function(a:Number,b:Number):Number{return a-b;} );
						if( this.strFunctionName == "MIN" ) {
							return arrValues[0];	
						} else {
							return arrValues[ arrValues.length -1 ];
						}
					case "SUM":
					case "AVG":
						var numSum:Number = 0;
						for( var i:uint = 0; i < arrValues.length; ++i ) {
							numSum += arrValues[i];	
						}
						if( this.strFunctionName == "SUM" ) {
							return numSum;	
						} else {
							return numSum / arrValues.length;	
						}
					case "RAND":
						return Math.round( Math.random() * arrValues[0] );
					case "ROUND":
						return Math.round( arrValues[0] );
					case "CEIL":
						return Math.ceil( arrValues[0] );
					case "FLOOR":
						return Math.floor( arrValues[0] );
					case "ADDSCRIPTEVENTLISTENER":
						ExpressionParser.addScriptEventListener( this.arrRootNode[0].getValue(), this.arrRootNode[1].getValue() );
						return null;
					case "REMOVESCRIPTEVENTLISTENER":
						ExpressionParser.removeScriptEventListener( this.arrRootNode[0].getValue(), this.arrRootNode[1].getValue() );
						return null;
					case "DISPATCHSCRIPTEVENT":
						ExpressionParser.dispatchScriptEvent( arrValues[0] );
						return null;
								
					default:
						return null;				
				}
				
			}
			return null;	
		}
		
		public override function toString():String {
			return this.strFunctionName + "(" + super.toString() + ")";	
		}
		
	}
}