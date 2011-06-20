package net.bordnerd.comm.xmlser {
	/**
	 * This class serializes generic datatypes to an XML format for later deserialization.
	 * 
	 * The class supports the following data types:
	 * 		string : <s>
	 * 		boolean: <b>
	 * 		integer number: <i>
	 * 		floating point number: <f>
	 * 		null: <n>
	 * 		array: <a>
	 * 		object: <o>
	 * 
	 * named values will have the identifier as a node attribute with the name: "n"
	 * 
	 * @author michael.bordner
	 */
	
	import net.bordnerd.comm.xmlser.*; 
	 
	public class Serializer 
	{
		
		/**
		 * This method will serialize an object to an XML instance.  The XML instance will be constructed
		 * following the xmlser schema for serializing and deserializing generic data types.
		 * Optionally, a container XML instance can be passed in where the serialized object properties should
		 * be appended.  If the container is not provided, this method will create a wrapper
		 * XML "o" instance for the serialized properties and return the wrapper instance.
		 * 
		 * @param obj the object to serialize
		 * @param xml (optional) XML instance container to where the serialized properties will be appended
		 * @return an XML instance containing the serialized object properties
		 */
		public static function serializeObject( obj:Object, xml:XML = null ):XML {
			if( xml == null ) {
				xml = <o></o>;	
			}
			if( obj != null ) {
				for( var id:String in obj ) {
					Serializer.serializeProperty( id, obj[id], xml );	
				}	
			} else {
				return <n/>;
			}
			return xml;			
		}
		
		
		/**
		 * This method will serialize an array to an XML instance.  The XML instance will be constructed
		 * following the xmlser schema for serializing and deserializing generic data types.
		 * Optionally, a container XML instance can be passed in where the serialized array elements should
		 * be appended.  If the container is not provided, this method will create a wrapper
		 * XML "a" instance for the serialized elements and return the wrapper instance.
		 * 
		 * @param arr the Array to serialize
		 * @param xml (optional) XML instance container to where the serialized elements will be appended
		 * @return an XML instance containing the serialized array elements
		 */
		public static function serializeArray( arr:Array, xml:XML = null ):XML {
			if( xml == null ) {
				xml = <a></a>;	
			}
			if( arr != null ) {
				for( var i:uint = 0; i < arr.length; ++i ) {
					Serializer.serializeProperty( null, arr[i], xml );	
				}	
			} else {
				xml = <n/>;	
			}
			return xml;	
		}
		
		
		/**
		 * This method will serialize a property value to an XML instance.  The XML instance
		 * will follow the xmlser schema for serializing and deserializing generic data types.
		 * Optionally, a container XML instance can be passed in where the serialized property should
		 * be appended.
		 * 
		 * @param id the identifier for the property
		 * @param value the value for the property
		 * @param xml (optional) XML instance to append the serialized property
		 * @return an XML instance representing the serialized property
		 */
		public static function serializeProperty( id:String = null, value:* = null, xml:XML = null ):XML {
			if( xml == null ) {
				xml = new XML();	
			}
			
			var prop:XML;
			
			if( value != null ) {
				if( value is Boolean ) {
					prop = <b/>;
					prop.appendChild( new XML( Boolean(value).valueOf() ) );
				} else if( value is Number ) {
					if( value is int ) {
						prop = <i/>;	
					} else {
						prop = <f/>;	
					}
					prop.appendChild( new XML( value ) );
				} else if( value is String ) {
					prop = <s/>;
					prop.appendChild( new XML( value ) );	
				} else if( value is Array ) {
					prop = <a/>;
					Serializer.serializeArray( value, prop );
				} else if( value is Object ) {
					prop = <o/>;
					Serializer.serializeObject( value, prop );
				}
			} else {
				prop = <n/>;				
			}
			
			xml.appendChild( prop );
			
			if( id != null ) {
				prop.@n = id;
			}
			
			return prop;
		}		 
		
		
	}
	
}