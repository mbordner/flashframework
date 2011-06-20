package net.bordnerd.htmlwidget.model {

	/**
	 * @author michael.bordner
	 */
	public class NumberValue 
	{
		
		protected var _value:Number;
		
		public function NumberValue( v:Number ) {
			_value = v;	
		}
		
		public function get value():Number {
			return _value;	
		}
				
		public function getValue( max:Number ):Number {
			return Math.min( max, _value );	
		}
		
	}
}
