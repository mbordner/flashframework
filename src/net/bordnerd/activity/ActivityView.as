package net.bordnerd.activity {
	import flash.display.*;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import net.bordnerd.activity.Activity;
	import net.bordnerd.activity.event.UpdateEvent;
	import net.bordnerd.activity.event.ActivityFWEvent;
	import net.bordnerd.activity.event.ActivityViewEvent;
	
	/**
	 * @author michael.bordner
	 */
	public class ActivityView extends MovieClip 
	{
		
		private var __css:StyleSheet;
		private var __activity:Activity;
		
		public function ActivityView() {
			super();	
		}
		
		public function initialize( activity:Activity, css:StyleSheet ):void {
			__activity = activity;
			__css = css;
			this.configureView();			
		}
		
		public function sendMsg( name:String, args:Object = null ):void {
			this.dispatchEvent( new ActivityViewEvent( name, args ) );
		}
		
		protected function get activity():Activity {
			return __activity;	
		}
		
		protected function get css():StyleSheet {
			return __css;	
		}
		
		protected function setInitialized():void {
			this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.VIEW_INITIALIZED ) );	
		}
		
		protected function setDestroyed():void {
			this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.VIEW_DESTROYED ) );	
		}
		
		protected function getSetting( key:String, defaultValue:String = null ):String {
			return __activity.getModel().getSetting(key, defaultValue);
		}
		
		protected function getSettingAsBoolean( key:String, defaultValue:Boolean ):Boolean {
			return __activity.getModel().getSettingAsBoolean(key, defaultValue);
		}
		
		protected function getSettingAsNumber( key:String, defaultValue:Number ):Number {
			return __activity.getModel().getSettingAsNumber(key, defaultValue);
		}
		
		protected function getConfigAttribute( key:String, defaultValue:String ):String {
			return __activity.getModel().getConfigAttribute(key, defaultValue);
		}
		
		protected function getConfigAttributeAsBoolean( key:String, defaultValue:Boolean ):Boolean {
			return __activity.getModel().getConfigAttributeAsBoolean(key, defaultValue);
		}
		
		protected function getConfigAttributeAsNumber( key:String, defaultValue:Number ):Number {
			return __activity.getModel().getConfigAttributeAsNumber(key, defaultValue);
		}
		
				
		/**
		 * to be overridden, must call setInitialized when configured
		 */		
		protected function configureView():void {
			this.setInitialized(); 
		}
		
		/**
		 * to be overridden
		 */
		public function update( evt:UpdateEvent ):void {
		
		}

		/**
		 * can be overridden
		 */
		public function destroy():void {
			this.setDestroyed();
		}
		
		public static function createTextFieldDisplayObject( htmlText:String, width:Number, css:StyleSheet ):TextField {
			var tf:TextField = new TextField();
			tf.type = TextFieldType.DYNAMIC;
			tf.width = width;
			tf.height = 4;
			
			tf.border = false;
			tf.multiline = true;
			tf.wordWrap = true;
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.embedFonts = true;

			tf.styleSheet = css;
			tf.htmlText = htmlText;
			
			return tf;
		}
		
		public static function createSingleLineTextFieldDisplayObject( htmlText:String, css:StyleSheet ):TextField {
			var tf:TextField = new TextField();
			tf.type = TextFieldType.DYNAMIC;
			tf.width = 4;
			tf.height = 4;
			
			tf.border = false;
			tf.multiline = false;
			tf.wordWrap = false;
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.embedFonts = true;

			tf.styleSheet = css;
			tf.htmlText = htmlText;
			
			return tf;
		}	
		
	}
}
