package net.bordnerd.htmlwidget {

	import net.bordnerd.htmlwidget.widget.*;
	import net.bordnerd.htmlwidget.model.*;
	import flash.text.*;

	import net.bordnerd.htmlwidget.WidgetFactoryDelegate;

	/**
	 * @author michael.bordner
	 */
	public class WidgetFactory
		implements
			WidgetFactoryDelegate 
	{
		private static var _instance:WidgetFactory;
		
		private var _delegates:Object;
		
		public function WidgetFactory() {
			_delegates = new Object();
			this.addDelegate( "div", this );		
		}
		
		public static function getInstance():WidgetFactory {
			if( _instance == null ) {
				_instance = new WidgetFactory();
			}
			return _instance;	
		}
		
		public function addDelegate( type:String, d:WidgetFactoryDelegate ):void {
			_delegates[ type ] = d;	
		}
		
		public function createWidgetModel( xml:XML, css:StyleSheet ):WidgetModel {
			var type:String = xml.name().toString();
			if( type == "div" ) {
				return new HTMLWidgetModel( xml, css );	
			} else if( _delegates[ type ] != undefined ) {
				return WidgetFactoryDelegate( _delegates[type] ).createWidgetModel(xml, css);	
			}
			return new WidgetModel( xml, css );
		}
		
		public function createWidget( model:WidgetModel ):AbstractWidget {
			var type:String = model.getWidgetType();
			if( type == "div" ) {
				return new HTMLBoxWidget( model as HTMLWidgetModel );
			} else if( _delegates[ type ] != undefined ) {
				return WidgetFactoryDelegate( _delegates[type] ).createWidget(model);	
			}
			return new AbstractWidget( model );
		}
	
		
	}
}
