package net.bordnerd.exparse.functiontable {
	import net.bordnerd.exparse.functiontable.*;
	import net.bordnerd.exparse.*;
	
	/**
	 * @author michael.bordner
	 */
	public class FunctionWrapper
		implements
			TableFunction 
	{
		private var objScope:Object;
		private var objFunction:Function;
		
		public function FunctionWrapper( objScope:Object, objFunction:Function ) {
			this.objScope = objScope;
			this.objFunction = objFunction;
		}
		
		public function execute( objRootParser:ExpressionParser = null, objDataProvidingParser:ExpressionParser = null, arrArgs:Array = null ):Object {
			return this.objFunction.apply( this.objScope, arrArgs );	
		}
		
		public function call( ...arrArguments:Array ):Object {
			return this.objFunction.apply( this.objScope, arrArguments );	
		}
		
	}

}