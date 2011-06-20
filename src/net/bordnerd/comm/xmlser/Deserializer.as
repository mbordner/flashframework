package net.bordnerd.comm.xmlser {
	/**
	 * @author michael.bordner
	 */
	public class Deserializer 
	{
		
		public static function deserializeObject( xml:XML, obj:Object = null ):Object {
			if( obj == null ) {
				obj = {};	
			}
			if( xml != null ) {
				xml = xml.normalize();
				var children:XMLList = xml.children();
				for( var i:uint = 0; i < children.length(); ++i ) {
					var prop:XML = children[i];
					if( prop.nodeKind() == "element" ) {
						var id:String = Deserializer.getIdentifier( prop );
						if( id != null ) {
							obj[ id ] = Deserializer.deserializeProperty( prop );	
						}	
					}	
				}
			}
			return obj;
		}
		
		public static function deserializeArray( xml:XML, arr:Array = null ):Array {
			if( arr == null ) {
				arr = [];	
			}
			if( xml != null ) {
				xml = xml.normalize();
				var children:XMLList = xml.children();
				for( var i:uint = 0; i < children.length(); ++i ) {
					var prop:XML = children[i];
					if( prop.nodeKind() == "element" ) {
						arr.push( Deserializer.deserializeProperty( prop ) );	
					}	
				}
			}
			return arr;	
		}
		
		public static function deserializeProperty( xml:XML ):Object {
			if( xml != null ) {
				xml = xml.normalize();
				var type:String = String(xml.name());
				if( type != "n" ) {
					var value:String = xml.toString();
					
					if( type == "o" ) {
						return Deserializer.deserializeObject( xml );	
					} else if( type == "a"  ) {
						return Deserializer.deserializeArray( xml );	
					} else if( xml.children().length() > 0 ){
						if( type == "i" ) {
							return new int( value );
						} else if( type == "f" ) {
							return new Number( value );	
						} else if( type == "s" ) {
							return xml.toString();	
						} else if( type == "b" ) {
							if( value.toLowerCase() != "false" && value != "0" ) {
								return true;	
							} else {
								return false;	
							}
						}
					}
 				}
			}
			return null;
		}
		
		private static function getIdentifier( xml:XML ):String {
			if( xml != null ) {
				if( xml.@n != undefined && (xml.@n).toString().length > 0 ) {
					return xml.@n;	
				}
			}
			return null;	
		}
		
	}
	
}
