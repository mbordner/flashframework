package net.bordnerd.htmlwidget.event {
	import flash.events.Event;
	
	/**
	 * @author michael.bordner
	 */
	public class WidgetEvent extends Event 
	{
		public static const WIDGET_INITIALIZED:String = "WIDGET_INITIALIZED";
		public static const WIDGET_RENDERED:String = "WIDGET_RENDERED";
				
		public function WidgetEvent( type:String ) {
			super( type, true, true );
		}
		
		public override function clone():Event {
			return new WidgetEvent( type );	
		}
		
		public override function toString():String {
			return formatToString( "WidgetEvent", "type", "bubbles", "cancelable", "eventPhase" );	
		}
		
	}
}
