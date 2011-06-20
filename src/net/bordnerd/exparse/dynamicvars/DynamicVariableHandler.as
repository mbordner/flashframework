package net.bordnerd.exparse.dynamicvars {
	/**
	 * @author michael.bordner
	 */
	public interface DynamicVariableHandler 
	{
		
		function evaluateDynamicVariable( strVariable:String ):Object;
		function willHandleDynamicVariable( strVariable:String ):Boolean;	
		
	}
}