package net.bordnerd.comm.lcdispatch.call {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.xmlser.*;
	import flash.events.EventDispatcher;
	 
	public class LCCall
		extends
			EventDispatcher
	{
		private var _id:String;
		private var _connId:String;
		private var _name:String;
		private var _args:Array;
		
		public function LCCall() {
			super( this );
		}
		
		public function get id():String {
			return _id;	
		}
		
		public function get connectionId():String {
			return _connId;
		}
		
		public function get name():String {
			return _name;	
		}
		
		public function get args():Array {
			if( _args != null ) {
				return _args;
			}
			return [];	
		}
		
		protected function setId( val:String ):void {
			if( val ) {
				_id = val;
			}
		}
		
		protected function setConnId( val:String ):void {
			if( val ) {
				_connId = val;
			}
		}
		
		protected function setName( val:String ):void {
			if( val ) {
				_name = val;	
			}	
		}
		
		protected function setArgs( val:Array ):void {
			if( val ) {
				_args = val;	
			}	
		}
		
		public function toXML():XML {
			var xml:XML = <c/>;
			
			xml.@n = this.name;
			xml.@i = this.id;
			
			Serializer.serializeArray( this.args, xml );		
			
			return xml.normalize();
		}
		
		public override function toString():String {
			return this.toXML().toXMLString();	
		}
		
	}
}