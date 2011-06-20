package net.bordnerd.exparse {
	import net.bordnerd.exparse.*;
	import net.bordnerd.exparse.event.DataChangeEvent;
	
	/**
	 * @author michael.bordner
	 */
	public class LocalDataProvider
		extends
			DefaultDataProvider
		implements
			DataProvider 
	{
		private var objParentDataProvider:DataProvider = null;
		
		/**
		 * This class provides a means for hierarchial data providers.
		 */
		public function LocalDataProvider( objParentDataProvider:DataProvider = null ) {
			super();
			if( objParentDataProvider != null ) {	
				this.objParentDataProvider = objParentDataProvider;
			}		
		}
		
		public function setParentDataProvider( objProvider:DataProvider ):void {
			this.objParentDataProvider = objProvider;		
		}		
		
		public override function getDataValue( strIdentifier:String ):Object {
			if( strIdentifier != null && strIdentifier.length > 0 ) {
				if( this.objDataSource[ strIdentifier ] !== undefined ) {
					return this.objDataSource[ strIdentifier ];	
				} else {
					if( this.objParentDataProvider != null ) {
						return this.objParentDataProvider.getDataValue( strIdentifier );	
					}
				}
			}
			return null;
		}
		
		/**
		 * Overrides parent behavior of deleting data elements when setting to undefined, so that local providers have the
		 * ability to hide global data provider elements.
		 */
		public override function setDataValue( strIdentifier:String, varValue:* ):void {
			if( strIdentifier != null && strIdentifier.length > 0 ) {
				if( this.objDataSource[ strIdentifier ] !== undefined ) {	
					
					var oldValue:* = null;
					if( this.objDataSource[ strIdentifier ] != undefined ) {
						oldValue = this.objDataSource[ strIdentifier ];
					}
					
					if( varValue != null ) {
						this.objDataSource[ strIdentifier ] = varValue;
					} else {
						if( this.objDataSource[ strIdentifier ] != undefined ) {
							this.objDataSource[ strIdentifier ] = null;
							delete this.objDataSource[ strIdentifier ];	
						}	
					}					
					
					if( this.willTrigger( DataChangeEvent.DATA_CHANGE ) ) {
						this.dispatchEvent( new DataChangeEvent( strIdentifier, 
							oldValue,
							varValue ) );	
					}
					
				} else {
					this.objParentDataProvider.setDataValue( strIdentifier, varValue );	
				}
			}
		}
		
		/**
		 * This function must be used instead of setDataValue for the first data element, otherwise the value will be created on the parent DataProvider.
		 */
		public function setLocalDataValue( strIdentifier:String, varValue:* ):void {
			if( strIdentifier != null && strIdentifier.length > 0 ) {
				
				var oldValue:* = null;
				if( this.objDataSource[ strIdentifier ] != undefined ) {
					oldValue = this.objDataSource[ strIdentifier ];
				}
				
				if( varValue != null ) {
					this.objDataSource[ strIdentifier ] = varValue;
				} else {
					if( this.objDataSource[ strIdentifier ] != undefined ) {
						this.objDataSource[ strIdentifier ] = null;
						delete this.objDataSource[ strIdentifier ];	
					}	
				}	
				
				if( this.willTrigger( DataChangeEvent.DATA_CHANGE ) ) {
					this.dispatchEvent( new DataChangeEvent( strIdentifier, 
						oldValue,
						varValue ) );	
				}
				
			}		
		}
	
	}
}