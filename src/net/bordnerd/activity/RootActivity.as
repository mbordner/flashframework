package net.bordnerd.activity {
	import net.bordnerd.activity.Activity;
	import flash.net.*;
	import flash.text.*;
	import flash.events.*;
	
	/**
	 * @author michael.bordner
	 */
	public class RootActivity extends Activity 
	{
		private static const CSS_URL:String = "styles.css";
		private static const CONFIG_URL:String = "config.xml";
		
		private var _urlLoader:URLLoader;
		private var _css:StyleSheet;
		private var _xml:XML;
		
		public function RootActivity() {
			super();
		}
		
		protected function getCSSUrl():String {
			return CSS_URL;
		}
		
		protected function getConfigUrl():String {
			return CONFIG_URL;	
		}
		
		protected function getRootXML():XML {
			return _xml;	
		}
		
		protected function getRootCSS():StyleSheet {
			return _css;	
		}
		
		protected function initializeRootActivity():void {
			this.initialize( this.getRootXML(), this.getRootCSS() );
		}
		
		protected override function activityAddedToStage():void {
			Activity.setRootActivity( this );
			
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener( Event.COMPLETE, this.handleCSSLoadEvent );
			_urlLoader.addEventListener( IOErrorEvent.IO_ERROR, this.handleCSSLoadFailEvent );
			_urlLoader.load( new URLRequest( Activity.getCSSPath() + this.getCSSUrl() ) );
		}
		
		private function handleCSSLoadEvent( evt:Event ):void {
			_css = new StyleSheet();
			_css.parseCSS( String(evt.target["data"]) );
			this.cssLoaded();
		}
		
		private function handleCSSLoadFailEvent( evt:IOErrorEvent ):void {
			this.cssLoaded();
		}
		
		private function cssLoaded():void {
			_urlLoader.removeEventListener( Event.COMPLETE, this.handleCSSLoadEvent );
			_urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, this.handleCSSLoadFailEvent );
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener( Event.COMPLETE, this.handleXMLLoadEvent );
			_urlLoader.addEventListener( IOErrorEvent.IO_ERROR, this.handleXMLLoadFailEvent );
			_urlLoader.load( new URLRequest( Activity.getDataPath() + this.getConfigUrl() ) );
		}
		
		private function handleXMLLoadEvent( evt:Event ):void {
			var oldValue:Boolean = XML.ignoreWhitespace;
			XML.ignoreWhitespace = false;
			var xml:XML = new XML( evt.target.data );
			var txtNodes:XMLList = xml..txt;
			var count:uint = txtNodes.length();
			var i:uint;
			for( i = 0; i < count; ++i ) {
				var fixed:String = txtNodes[i].*.toString().replace(/\n|\r/g,"").replace(/\t/g," ").replace(/\s\s+/g," ").replace(/^\s+|\s+$/,"");				
				txtNodes[i] = fixed;
			}			
			XML.ignoreWhitespace = oldValue;
			_xml = new XML( xml.toXMLString() );			
			this.xmlLoaded();
		}
		
		private function handleXMLLoadFailEvent( evt:IOErrorEvent ):void {
			this.xmlLoaded();
		}
		
		private function xmlLoaded():void {
			_urlLoader.removeEventListener( Event.COMPLETE, this.handleXMLLoadEvent );
			_urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, this.handleXMLLoadFailEvent );
			_urlLoader = null;
			this.initializeRootActivity();
		}
		
	}
}
