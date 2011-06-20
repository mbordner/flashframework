package net.bordnerd.comm.lcdispatch.call {
	/**
	 * @author michael.bordner
	 */
	import net.bordnerd.comm.xmlser.*; 
	
	public class LCReturn
	{
	
		private var _id:String;
		private var _connId:String;
		private var _handled:Boolean;
		private var _value:*;
		private var _acceptMoreReturns:Boolean;
	
		public function LCReturn() {
			_handled = false;
		}
	
		public function get id():String {
			return _id;	
		}
		
		public function get connectionId():String {
			return _connId;
		}
	
		public function get handled():Boolean {
			return _handled;	
		}
	
		public function get value():* {
			return _value;	
		}
	
		public function setValue( val:* ):void {
			_value = val;
			_handled = true;	
		}
	
		protected function setId( id:String ):void {
			_id = id;	
		}
		
		protected function setConnId( connId:String ):void {
			_connId = connId;	
		}
	
		public function set acceptMoreReturns( val:Boolean ):void {
			_acceptMoreReturns = val;	
		}
		
		public function get acceptMoreReturns():Boolean {
			return _acceptMoreReturns;	
		}
	
		public function toXML():XML {
			var xml:XML = <r/>;
			
			xml.@i = this.id;
						
			Serializer.serializeProperty( null, this.value, xml );		
			
			return xml.normalize();
		}	
	
		public function toString():String {
			return this.toXML().toXMLString();
		}		
		
	}

}