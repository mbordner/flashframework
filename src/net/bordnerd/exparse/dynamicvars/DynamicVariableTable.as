package net.bordnerd.exparse.dynamicvars {
	import net.bordnerd.exparse.dynamicvars.*;
	/**
	 * @author michael.bordner
	 */
	public class DynamicVariableTable 
	{
		private static var objDynamicVariableTable:DynamicVariableTable = null;
		
		private var objMap:Object;
		
		public function DynamicVariableTable(){
			this.objMap = new Object();
		}
		
		public function addHandler( strPrefix:String, objHandler:DynamicVariableHandler ):void {
			if( strPrefix != null && strPrefix.length > 0 && objHandler != null ) {
				this.objMap[ strPrefix ] = objHandler;
			}
		}
		
		public function getHandler( strVariable:String ):DynamicVariableHandler {
			if( strVariable != null && strVariable.length > 0 ) {
				for( var strPrefix in this.objMap ) {
					if( strVariable.indexOf( strPrefix ) == 0 ) {
						return this.objMap[ strPrefix ];	
					}
				}
			}
			return null;	
		}
		
		public function hasHandler( strVariable:String ):Boolean {
			return ( this.getHandler( strVariable ) != null );	
		}
		
		public static function getInstance():DynamicVariableTable {
			if( DynamicVariableTable.objDynamicVariableTable == null ) {
				DynamicVariableTable.objDynamicVariableTable = new DynamicVariableTable();	
			}	
			return DynamicVariableTable.objDynamicVariableTable;
		}
	}
}