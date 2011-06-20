package net.bordnerd.comm.lcdispatch.msg {
	/**
	 * @author michael.bordner
	 */
	public class LCMsg 
	{
		
		protected static const DELIM:String = ":";
		protected static const HEADERDELIM:String = ",";
		protected static const MSGPAYLOADMAXLENGTH:Number = 32000;
		
		private var _connId:String = null;
		private var _id:String = null;
		private var _length:Number = -1;
		private var _content:String = null;
		
		public function LCMsg() {
		}
		
		public function getConnId():String {
			return _connId;	
		}
		
		public function getId():String {
			return _id;
		}
		
		public function getContent():String {
			return _content;	
		}
		
		public function getContentLength():Number {
			return _length;	
		}
		
		public function isMsgComplete():Boolean {
			trace(">>>> checking msg completion: expected content length:"+this.getContentLength()+", actual length:"+this.getContent().length+", content:["+_content+"]");
			return this.getContentLength() == this.getContent().length;
		}
		
		public function append( content:String ):void {
			if( content != null && content.length > 0 ) {
				if( _content != null ) {
					_content = _content + content;
				} else {
					_content = content;	
				}
			}
		}
		
		public function getMsgParts():Array {
			var pieces:Array = new Array();
			
			pieces.push( this.getConnId() );
			pieces.push( LCMsg.HEADERDELIM );
			pieces.push( this.getId() );
			pieces.push( LCMsg.HEADERDELIM );
			pieces.push( this.getContentLength() );
			pieces.push( LCMsg.DELIM );
		
			var header:String = pieces.join("");
			
			var msg:String = this.getContent();
			
			pieces = new Array();
			for( var i:uint = 0; i < msg.length; i+= LCMsg.MSGPAYLOADMAXLENGTH ) {
				if( (msg.length - i) < LCMsg.MSGPAYLOADMAXLENGTH ) {
					pieces.push( header + msg.substr( i ) );
				} else {
					pieces.push( header + msg.substr( i, LCMsg.MSGPAYLOADMAXLENGTH ) );	
				}
				
			}
			
			return pieces;	
		}
		
		protected function setConnId( connId:String ):void {
			if( connId != null && connId.length > 0 ) {
				_connId = connId;	
			}	
		}
		
		protected function setId( id:String ):void {
			if( id != null && id.length > 0 ) {
				_id = id;
			}
		}	
		
		protected function setContentLength( length:Number ):void {
			if( !isNaN( length ) && length >= 0 ) {
				_length = length;
			}	
		}
		
		protected function parseHeader( header:String ):void {
			if(	header != null && header.length > 0 ) {
				if( header.indexOf( LCMsg.HEADERDELIM ) != -1 ) {
					var tokens:Array = header.split( LCMsg.HEADERDELIM );	
					this.setConnId( tokens[0] );
					this.setId( tokens[1] );
					var numTmp:Number = parseInt( tokens[2] );
					if( !isNaN( numTmp ) ) {
						this.setContentLength( numTmp );	
					}
				}
			}
		}
		
	}

}