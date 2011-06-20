package net.bordnerd.htmlwidget {
	import flash.text.*;
	import net.bordnerd.htmlwidget.widget.*;
	import net.bordnerd.htmlwidget.model.*;
	import net.bordnerd.htmlwidget.event.*;
	/**
	 * @author michael.bordner
	 */
	public class HTMLPanel extends HTMLBoxWidget 
	{
		
		public function HTMLPanel( width:Number, height:Number, html:String, css:StyleSheet ) {
			super( new HTMLWidgetModel(createXML(html),css) );
			this.visible = false;
			model.setDimensions(width, height);
			this.addEventListener( WidgetEvent.WIDGET_INITIALIZED, handleWidgetInitializedEvent );
			this.initialize();
		}
		
		private function handleWidgetInitializedEvent( evt:WidgetEvent ):void {
			if( evt.target == evt.currentTarget ) {
				this.removeEventListener( WidgetEvent.WIDGET_INITIALIZED, handleWidgetInitializedEvent );
				this.addEventListener( WidgetEvent.WIDGET_RENDERED, handleWidgetRenderedEvent );
				this.draw();	
			}	
		}
		
		private function handleWidgetRenderedEvent( evt:WidgetEvent ):void {
			if( evt.target == evt.currentTarget ) {
				this.visible = true;
			}	
		}
		
		private static function createXML( html:String ):XML {
			var oldValue:Boolean = XML.ignoreWhitespace;
			XML.ignoreWhitespace = false;
			var xml:XML = new XML( html.replace(/\n|\r/g,"").replace(/\t/g," ").replace(/\s\s+/g," ").replace(/^\s+|\s+$/,"") );
			XML.ignoreWhitespace = oldValue;
			return xml;
		}	
	
	}
}
