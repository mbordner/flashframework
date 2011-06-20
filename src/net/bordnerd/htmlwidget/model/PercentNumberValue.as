package net.bordnerd.htmlwidget.model {
	import net.bordnerd.htmlwidget.model.NumberValue;
	
	/**
	 * @author michael.bordner
	 */
	public class PercentNumberValue extends NumberValue 
	{
		public function PercentNumberValue(value:Number) {
			super( value );
		}
		
		public override function getValue( max:Number ):Number {
			return max * value / 100;
		}
	}
}
