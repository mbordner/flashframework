package net.bordnerd.activity.model {

	import net.bordnerd.activity.Activity;
	import net.bordnerd.exparse.DefaultDataProvider;
	import net.bordnerd.exparse.DataProvider;
	/**
	 * @author michael.bordner
	 */
	public class ActivityModel 
		extends
			DefaultDataProvider
		implements
			DataProvider
	{
		
		private var _controller:Activity;
		private var _xml:XML;
		private var _config:XML;
		
		public function ActivityModel( controller:Activity, xml:XML, config:XML ) {
			super();
			_controller = controller;
			_xml = xml;
			_config = config;
		}
		
		public static function getTxtNodeSource( xml:XML ):String {
			if( xml != null ) {
				if( String(xml.name()) == "txt" ) {
					if( xml.hasComplexContent() ) {
						var val:Boolean = XML.prettyPrinting;
						try {					
							XML.prettyPrinting = false;
							var source:String = xml.*.toXMLString();
							return source.split("<![CDATA[").join("").split("]]>").join("");				
						} catch ( e:Error ){
						} finally {
							XML.prettyPrinting = val;	
						}			
					} else {
						return xml.toString();	
					}
				} else {
					return xml.toString();	
				}
			}
			return "";
		}
		
		public static function getBooleanValue( s:String ):Boolean {
			if( s != null && s.toLowerCase() == "true" ) {
				return true;	
			}
			return false;	
		}
		
		public static function getNumberValue( s:String ):Number {
			if( s!= null && s.length > 0 ) {
				var num:Number = Number( s );
				if( !isNaN(num) ) {
					return num;	
				}	
			}
			return 0;	
		}
		
		protected function get controller():Activity {
			return _controller;	
		}
		
		public function get xml():XML {
			return _xml;	
		}
		
		public function get config():XML {
			return _config;	
		}
		
		protected function initialized():void {
			_controller.modelInitialized();
		}
		
		public function initialize():void {
			this.initialized();	
		}
		
		public function getXMLModelTxtNodeSource( nodeName:String ):String {
			try {
				var xml:XML = _xml[ nodeName ][0];
				return getTxtNodeSource( xml.txt[0] );	
			} catch ( e:Error ){
			}
			return "";			 
		}
		
		public function getSetting( key:String, defaultValue:String = null ):String {
			try {
				var list:XMLList = _xml.settings.setting.(@key == key);
				if( list.length() > 0 ) {
					return list[ list.length() - 1 ];
				}
			} catch ( e:Error ) {				
			}
			return defaultValue;			
		}
		
		public function getSettingAsBoolean( key:String, defaultValue:Boolean ):Boolean {
			var s:String = getSetting( key, null );
			if( s != null ) {
				return getBooleanValue(s);
			}
			return defaultValue;
		}
		
		public function getSettingAsNumber( key:String, defaultValue:Number ):Number {
			var s:String = getSetting( key, null );
			if( s != null ) {
				return getNumberValue(s);
			}
			return defaultValue;
		}
		
		public function getConfigAttribute( key:String, defaultValue:String ):String {
			if( _config.@[key] != undefined ) {
				var val:String = _config.@[key].toString();
				if( val != null && val.length > 0 ) {
					return val;	
				}
			}
			return defaultValue;
		}
		
		public function getConfigAttributeAsBoolean( key:String, defaultValue:Boolean ):Boolean {
			var s:String = getConfigAttribute( key, null );
			if( s != null ) {
				return getBooleanValue(s);
			}
			return defaultValue;
		}
		
		public function getConfigAttributeAsNumber( key:String, defaultValue:Number ):Number {
			var s:String = getConfigAttribute( key, null );
			if( s != null ) {
				return getNumberValue(s);
			}
			return defaultValue;
		}
		
	}
}
