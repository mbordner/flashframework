package net.bordnerd.exparse.console {
	import flash.events.*;
	import net.bordnerd.exparse.ExpressionParser;
	
	/**
	 * @author michael.bordner
	 */
	public class OutputEvent extends Event 
	{
		public static const CONSOLE_OUTPUT:String = "handleConsoleOutput";
		
		private var strOutput:String = "";
		private var objRootParser:ExpressionParser;
		
		public function OutputEvent( strOutput:String, objRootParser:ExpressionParser ) {
			super( CONSOLE_OUTPUT, true, true );
			if( strOutput != null ) {
				this.strOutput = strOutput;
			}
			this.objRootParser = objRootParser;
		}
		
		public function get output():String {
			return this.strOutput;	
		}
		
		public function get rootParser():ExpressionParser {
			return this.objRootParser;	
		}
		
		public override function clone():Event {
			return new OutputEvent( output, rootParser );	
		}
		
		public override function toString():String {
			return formatToString( "OutputEvent", "type", "bubbles", "cancelable", "eventPhase", "output", "rootParser" );	
		}
		
		
	}
}