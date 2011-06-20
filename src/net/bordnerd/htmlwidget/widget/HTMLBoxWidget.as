package net.bordnerd.htmlwidget.widget {
	import net.bordnerd.htmlwidget.widget.*;
	import net.bordnerd.htmlwidget.model.*;
	import net.bordnerd.htmlwidget.event.*;
	import net.bordnerd.htmlwidget.WidgetFactory;
	import flash.text.*;
	import flash.events.*;
	import flash.display.*;
	/**
	 * @author michael.bordner
	 */
	public class HTMLBoxWidget extends AbstractWidget 
	{
		private var _model:HTMLWidgetModel;
		private var _staticChildren:Array;
		private var _absoluteChildren:Array;
		
		private var _widgetCount:uint;
		private var _tf:TextField;
		
		public function HTMLBoxWidget( model:HTMLWidgetModel ) {
			super( model );
			_model = model;
		}
				
		public override function initialize():void {
			super.initialize();
			
			var childModels:Array = _model.getChildren();
			_staticChildren = new Array();
			_absoluteChildren = new Array();
			
			var wf:WidgetFactory = WidgetFactory.getInstance();
			
			var i:uint;
			
			for( i = 0; i < childModels.length; ++i ) {
				if( childModels[i] is String ) {
					this.renderTextField( childModels[i] as String );
					this.intialized();
				} else {
					var model:WidgetModel = childModels[i] as WidgetModel;
					if( model.position == "static" ) {
						_staticChildren.push( wf.createWidget( model ) );	
					} else if( model.position == "absolute" ) {
						_absoluteChildren.push( wf.createWidget( model ) );
					}
				}
			}
			
			_widgetCount = _staticChildren.length + _absoluteChildren.length;
			for( i = 0; i < _staticChildren.length; ++i ) {
				AbstractWidget(_staticChildren[i]).model.setDimensions( this.model.width, this.model.height );
				AbstractWidget(_staticChildren[i]).addEventListener( WidgetEvent.WIDGET_INITIALIZED, handleWidgetInitializedEvent );
				AbstractWidget(_staticChildren[i]).initialize();	
			}
			for( i = 0; i < _absoluteChildren.length; ++i ) {
				AbstractWidget(_absoluteChildren[i]).model.setDimensions( this.model.width, this.model.height );
				AbstractWidget(_absoluteChildren[i]).model.setDimensions( this.model.width - AbstractWidget(_absoluteChildren[i]).model.left,
					 this.model.height - AbstractWidget(_absoluteChildren[i]).model.top );
				AbstractWidget(_absoluteChildren[i]).addEventListener( WidgetEvent.WIDGET_INITIALIZED, handleWidgetInitializedEvent );
				AbstractWidget(_absoluteChildren[i]).initialize();	
			}
						
		}
		
		public function draw():void {
			this.getContentHeight();
			this.render();	
		}
		
		public override function render():void {
			if( _staticChildren.length > 0 || _absoluteChildren.length > 0 ) {
				var i:uint;
				var widget:AbstractWidget;
				var nextY:Number = 0;
				var content:MovieClip = this.getContent();
				
				for( i = 0; i < _staticChildren.length; ++i ) {
					widget = _staticChildren[i] as AbstractWidget;
					content.addChild( widget );
					widget.x = widget.model.marginLeft;
					widget.y = nextY + widget.model.marginTop;
					nextY = widget.y + widget.model.height + widget.model.marginBottom;
					widget.render();		
				}
				
				for( i = 0; i < _absoluteChildren.length; ++i ) {
					widget = _absoluteChildren[i] as AbstractWidget;
					content.addChild( widget );
					widget.x = widget.model.left;
					widget.y = widget.model.top;
					widget.render();	
				}
			} else if( _tf != null ) {
				if( this.model.textVerticalAlign == "middle" ) {
					_tf.y = ( this.model.height - _tf.height ) / 2;	
				} else if( this.model.textVerticalAlign == "bottom" ) {
					_tf.y = this.model.height - _tf.height;	
				}	
			}
			super.render();
			this.rendered();	
		}
		
		public override function getContentHeight():Number {
			if( _staticChildren.length > 0 || _absoluteChildren.length > 0 ) {
				var i:uint;
				var widget:AbstractWidget;
				var height:Number;
				
				var absoluteHeight:Number = 0;
				
				for( i = 0; i < _absoluteChildren.length; ++i ) {
					widget = _absoluteChildren[i] as AbstractWidget;
					height = widget.getContentHeight();
					absoluteHeight = Math.max( widget.model.top + height, absoluteHeight );					
				}
				
				var staticHeight:Number = 0;
				
				for( i = 0; i < _staticChildren.length; ++i ) {
					widget = _staticChildren[i] as AbstractWidget;
					height = widget.getContentHeight();
					if( widget.model.isHeightDefined() ) {
						widget.model.setDimensions( widget.model.width, Math.max( height, widget.model.height ) );
					} else {
						widget.model.setDimensions( widget.model.width, height );	
					}
					staticHeight += widget.model.marginTop + widget.model.height + widget.model.marginBottom;						
				}
				
				height = Math.max(staticHeight,absoluteHeight);
				
				for( i = 0; i < _absoluteChildren.length; ++i ) {
					widget = _absoluteChildren[i] as AbstractWidget;
					widget.model.setDimensions( widget.model.width, height - widget.model.top );								
				}
				
				return height;
				
			} else {
				return super.getContentHeight();	
			}	
		}
		
		private function handleWidgetInitializedEvent( evt:WidgetEvent ):void {
			if( evt.target == evt.currentTarget ) {
				--_widgetCount;				
				if( _widgetCount == 0 ) {					
					this.intialized();	
				}				
			}
		}
		
		private function renderTextField( str:String ):void {
			var content:MovieClip = this.getContent();
			
			_tf = new TextField();
			_tf.type = TextFieldType.DYNAMIC;
			_tf.width = this.model.width;
			_tf.height = 4;
			_tf.border = false;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.multiline = true;
			_tf.selectable = false;
			_tf.wordWrap = true;
			_tf.embedFonts = true;
			_tf.styleSheet = this.model;
			_tf.htmlText = "<body>"+str+"</body>";
						
			content.addChild( _tf );
		}
	}
}
