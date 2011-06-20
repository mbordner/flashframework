package net.bordnerd.htmlwidget.widget {
	import flash.display.*;
	import net.bordnerd.htmlwidget.model.*;
	import net.bordnerd.htmlwidget.event.*;
	/**
	 * @author michael.bordner
	 */
	public class AbstractWidget extends MovieClip 
	{
		private var _model:WidgetModel;
		private var _bg:Sprite;
		private var _content:MovieClip;
		
		public function AbstractWidget( model:WidgetModel ) {
			super();
			_model = model;		
		}
		
		public function get model():WidgetModel {
			return _model;	
		}
		
		public function initialize():void {
			_bg = new Sprite();
			this.addChild( _bg );
			_content = new MovieClip();
			this.addChild( _content );				
		}
		
		protected function getBG():Sprite {
			return _bg;	
		}
		
		protected function getContent():MovieClip {
			return _content;	
		}
		
		protected function intialized():void {
			this.dispatchEvent( new WidgetEvent( WidgetEvent.WIDGET_INITIALIZED ) );	
		}
				
		public function render():void {
			_content.x = this.model.paddingLeft;
			_content.y = this.model.paddingRight;
			
			_bg.graphics.moveTo(0,0);
			if( this.model.border > 0 ) {
				_bg.graphics.lineStyle( this.model.border, this.model.borderColor, this.model.borderAlpha );
			}
			_bg.graphics.beginGradientFill( GradientType.LINEAR, this.model.backgroundColor,
				this.model.backgroundAlpha, this.model.backgroundRatio );
			_bg.graphics.lineTo(this.model.width,0);
			_bg.graphics.lineTo(this.model.width,this.model.height);
			_bg.graphics.lineTo(0,this.model.height);
			_bg.graphics.lineTo(0,0);
		}
		
		public function getContentHeight():Number {
			return _content.height + model.paddingTop + model.paddingBottom;	
		}
		
		protected function rendered():void {
			this.dispatchEvent( new WidgetEvent( WidgetEvent.WIDGET_RENDERED ) );	
		}
		
	}
}
