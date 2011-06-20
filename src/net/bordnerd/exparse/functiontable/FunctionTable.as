package net.bordnerd.exparse.functiontable {
	import net.bordnerd.exparse.functiontable.*;
	import net.bordnerd.exparse.terms.logic.FunctionExpression;
	
	/**
	 * @author michael.bordner
	 */
	public class FunctionTable 
	{
		private static var objFunctionTable:FunctionTable = null;
		
		private var objFunctionMap:Object = null;
		
		public function FunctionTable(){
			this.objFunctionMap = new Object();
		}
		
		public function addFunction( strIdentifier:String, objScope:Object, objFunction:Function ):void {
			if( strIdentifier != null && strIdentifier.length > 0  ) {
				this.objFunctionMap[ strIdentifier.toUpperCase() ] = new FunctionWrapper( objScope, objFunction );
			}
		}
		
		public function addFunctionExpression( strIdentifier:String, objFunctionExpression:FunctionExpression ):void {
			if( strIdentifier != null && strIdentifier.length > 0  ) {
				this.objFunctionMap[ strIdentifier.toUpperCase() ] = objFunctionExpression;
			}
		}
		
		public function removeFunction( strIdentifier:String ):void {
			if( strIdentifier != null && strIdentifier.length > 0  ) {
				this.objFunctionMap[ strIdentifier.toUpperCase() ] = null;
			}
		}
		
		public function getTableFunction( strIdentifier:String ):TableFunction {
			if( strIdentifier != null && strIdentifier.length > 0  ) {
				strIdentifier = strIdentifier.toUpperCase();
				if( this.objFunctionMap[ strIdentifier ] != undefined ) {
					return TableFunction( this.objFunctionMap[ strIdentifier ] );	
				}	
			}	
			return null;
		}
		
		public static function getInstance():FunctionTable {
			if( FunctionTable.objFunctionTable == null ) {
				FunctionTable.objFunctionTable = new FunctionTable();
			}
			return FunctionTable.objFunctionTable;
		}
	}
}