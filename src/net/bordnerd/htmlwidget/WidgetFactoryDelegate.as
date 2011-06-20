package net.bordnerd.htmlwidget {
	import net.bordnerd.htmlwidget.widget.*;
	import net.bordnerd.htmlwidget.model.*;
	import flash.text.*;
	/**
	 * @author michael.bordner
	 */
	public interface WidgetFactoryDelegate 
	{
		function createWidgetModel( xml:XML, css:StyleSheet ):WidgetModel;
		function createWidget( model:WidgetModel ):AbstractWidget;
	}
}
