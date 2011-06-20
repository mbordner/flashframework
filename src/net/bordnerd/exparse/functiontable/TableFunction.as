package net.bordnerd.exparse.functiontable {
	import net.bordnerd.exparse.*;
	
	/**
	 * @author michael.bordner
	 */
	public interface TableFunction 
	{
		function execute( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null, arrArgs:Array = null ):Object;
		function call( ...arrArguments:Array ):Object;
	}
}