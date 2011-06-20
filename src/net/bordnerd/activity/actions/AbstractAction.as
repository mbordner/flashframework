package net.bordnerd.activity.actions {

	/**
	 * @author michael.bordner
	 */
	public class AbstractAction 
	{
		
		private var _expression:String;
		
		public function AbstractAction( expression:String = null ) {
			_expression = expression;
		}
		
		public function get expression():String {
			if( _expression != null && _expression.length > 0 ) {
				return _expression;	
			}	
			return _expression;
		}
		
		public function getArguments():Array {
			return [ _expression ];	
		}
		
		public function initializeArguments( a:Array ):void {
			if( a.length > 0 ) {
				_expression = a[0] as String;	
			}
		}
		
	}
}
