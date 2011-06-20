package net.bordnerd.activity {

	import flash.text.StyleSheet;
	import net.bordnerd.activity.Activity;
	import net.bordnerd.activity.ActivityGroup;
	import net.bordnerd.activity.ActivitySequence;

	/**
	 * @author michael.bordner
	 */
	public class ActivityFactory 
	{
		
		private static var _instance:ActivityFactory;
		
		private static var _classes:Object;
		
		public function ActivityFactory() {
			_classes = new Object();
			registerActivityClass( "activity", Activity );
			registerActivityClass( "series", ActivitySequence );
			registerActivityClass( "sequence", ActivitySequence );
			registerActivityClass( "activities", ActivityGroup );
			registerActivityClass( "group", ActivityGroup );
		}
				
		public static function getInstance():ActivityFactory {
			if( _instance == null ) {
				_instance = new ActivityFactory();	
			}
			return _instance;
		}
		
		public function registerActivityClass( id:String, cls:Class ):void {
			if( id != "onLoad" && id != "onUnload" && id != "onStart" && id != "onComplete" ) {
				_classes[ id ] = cls;
			} else {
				throw new Error( "can not register class to this id." );	
			}
		}
		
		public function hasClass( id:String ):Boolean {
			return getClass( id ) != null;
		}
		
		public function getClass( id:String ):Class {
			if( _classes[ id ] != undefined ) {
				return Class( _classes[ id ] );	
			}
			return null;
		}
		
		public function createActivity( id:String, xml:XML = null, css:StyleSheet = null, serializeKey:String = null ):Activity {
			var cls:Class = getClass( id );
			if( cls != null ) {
				var activity:Activity = Activity( new cls( xml, css, serializeKey ) );
				return activity;
			}
			return null;
		}
		
	}
}
