package net.bordnerd.exparse {
	import flash.events.*;
	import net.bordnerd.exparse.functiontable.TableFunction;
	
	public interface DataProvider extends IEventDispatcher {
	
		function getDataValue( strIdentifier:String ):Object;
		function setDataValue( strIdentifier:String, varValue:* ):void;
		function serialize():String;
		function deserialize( s:String ):void;
		function getTableFunction( strIdentifier:String ):TableFunction;
		
	}
}