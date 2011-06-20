package net.bordnerd.exparse.console {
	import flash.events.*;
	import net.bordnerd.exparse.console.*;
	import net.bordnerd.exparse.ExpressionParser;
	
	/**
	 * @author michael.bordner
	 */
	public class Console
		extends
			EventDispatcher 
	{
		
		private static var objInstance:Console = null;
		
		public function Console() {
			super();	
		}	
		
		public function out( objOutput:*, objRootParser:ExpressionParser = null ):void {
			var strOutput:String;
			if( !(strOutput is String) ) {
				strOutput = ""+objOutput;	
			} else {
				strOutput = String(objOutput);	
			}
			
			trace( ">> console.out('"+ net.bordnerd.exparse.ExpressionParser.escapeString(strOutput)+"')" );
			
			this.dispatchEvent( new OutputEvent( strOutput, objRootParser ) );	
		}
		
		public static function getInstance():Console {
			if( Console.objInstance == null ) {
				Console.objInstance = new Console();	
			}
			return Console.objInstance;
		}
		
	}
}