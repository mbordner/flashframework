package net.bordnerd.exparse.terms {
	import net.bordnerd.exparse.terms.Variable;
	import net.bordnerd.exparse.ExpressionParser;
	import net.bordnerd.exparse.dynamicvars.*;
	
	/**
	 * Dynamic variable allows handlers to calculate values for variables that match a certain prefix.  If the values
	 * can not exist in the datamodel because they need to be calculated at evaluation time, and you would rather have
	 * the script appear as a variable vs. a function call, dynamic variables may be the solution.  It really is a function
	 * call that appears as a variable (kinda sorta like a getter property on a class instance).
	 * 
	 * @author michael.bordner
	 */
	public class DynamicVariable
		extends
			Variable		
	{
		
		private var objHandler:DynamicVariableHandler;
		
		public function DynamicVariable( strValue:String, objHandler:DynamicVariableHandler ) {
			super( strValue );
			this.objHandler = objHandler;
		}
		
		public override function evaluate( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null ):Object {
			var strVariable:String = this.getValue();
			if( this.objHandler.willHandleDynamicVariable( strVariable ) ) {
				return this.objHandler.evaluateDynamicVariable(strVariable);
			} else {
				return super.evaluate( objRootParser, objDataProvidingParser );
			} 
		}
		
		
	}
}