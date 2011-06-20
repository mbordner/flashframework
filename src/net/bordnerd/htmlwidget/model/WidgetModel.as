package net.bordnerd.htmlwidget.model {
	
	import flash.text.*;
	import net.bordnerd.htmlwidget.model.*;
	
	/**
	 * @author michael.bordner
	 */
	public class WidgetModel extends StyleSheet
	{
		
		private var _xml:XML;
		private var _parentCSS:StyleSheet;
		private var _style:Object;
		
		
		private var _border:Number = 0;
		private var _borderColor:Number = 0; 
		private var _borderAlpha:Number = 1; 
		
		private var _backgroundColor:Array; // array of colors for gradiant or 1 for solid
		private var _backgroundAlpha:Array; // array of alphas for gradiant or 1 for solid
		private var _backgroundRatio:Array; // array of ratios for gradiant or 1 for solid
		
		private var _marginTop:NumberValue;
		private var _marginBottom:NumberValue;
		private var _marginLeft:NumberValue;
		private var _marginRight:NumberValue;
		private var _paddingTop:NumberValue;
		private var _paddingBottom:NumberValue;
		private var _paddingLeft:NumberValue;
		private var _paddingRight:NumberValue;
		
		private var _width:NumberValue;
		private var _height:NumberValue;
		
		private var _position:String = "static"; // static | absolute
		private var _top:NumberValue;
		private var _left:NumberValue;
		private var _zIndex:NumberValue;
		
		private var _visible:Boolean;
		
		private var _availInnerWidth:Number;
		private var _availInnerHeight:Number;
		private var _availOuterWidth:Number;
		private var _availOuterHeight:Number;
		
		private var _textVerticalAlign:String = "top"; // top | bottom | middle
		
		public function WidgetModel( xml:XML, css:StyleSheet ) {
			super();
			_xml = xml;
			_parentCSS = css;
			
						
			var i:uint;			
			var p:String;	
			var tmpStyle:Object = css.getStyle("body");
			_style = new Object();
			for( p in tmpStyle ) {
				_style[p] = tmpStyle[p];	
			}
								
			if( _xml.@["class"] != undefined ) {
				var classStyle:Object = css.getStyle( "." + _xml.@["class"].toString() );
				if( classStyle != null ) {
					for( p in classStyle ) {
						_style[p] = classStyle[p];	
					}
				}
			}
			
			if( _xml.@["style"] != undefined ) {
				var tmpStyleSheet:StyleSheet = new StyleSheet();
				var s:String = ".s{" + _xml.@["style"].toString() + "}";
				tmpStyleSheet.parseCSS( s );
				tmpStyle = tmpStyleSheet.getStyle(".s");
				for( p in tmpStyle ) {
					_style[p] = tmpStyle[p];
				}
			}
			
			this.setStyle("body",_style);
						
			if( _style["border"] != undefined ) {
				_border = parseDefaultNumberValue( _style["border"], 0 ).value;
				if( _border > 0 ) {
					if( _style["borderColor"] != undefined ) {
						_borderColor = parseDefaultNumberValue( _style["borderColor"], 0 ).value;
					}
					if( _style["borderAlpha"] != undefined ) {
						_borderAlpha = parseDefaultNumberValue( _style["borderAlpha"], 100 ).value / 100;	
					}
				}
			}
			
			if( _style["backgroundColor"] != undefined ) {
				var colorTokens:Array = _style["backgroundColor"].split(",");
				_backgroundColor = new Array();
				_backgroundAlpha = new Array();
				_backgroundRatio = new Array();
				
				for( i = 0; i < colorTokens.length; ++i ) {
					_backgroundColor[i] = parseDefaultNumberValue( colorTokens[i], 0xFFFFFF ).value;
					_backgroundAlpha[i] = 1;
					_backgroundRatio[i] = 255;						
				}
				
				if( _style["backgroundAlpha"] != undefined ) {
					var alphaTokens:Array = _style["backgroundAlpha"].split(",");
					for( i = 0; i < alphaTokens.length; ++i ) {
						_backgroundAlpha[i] = parseDefaultNumberValue( alphaTokens[i], 1 ).value;	
					}	
				}
				
				if( _style["backgroundRatio"] != undefined ) {
					var ratioTokens:Array = _style["backgroundRatio"].split(",");
					for( i = 0; i < ratioTokens.length; ++i ) {
						_backgroundRatio[i] = parseDefaultNumberValue( ratioTokens[i], 255 ).value;	
					}	
				}				
				
			} else {
				_backgroundColor=[0];
				_backgroundAlpha=[0];
				_backgroundRatio=[255];	
			}
			
			
			var margin:NumberValue = parseDefaultNumberValue( _style["margin"], 0 );
			_marginTop = _marginBottom = _marginLeft = _marginRight = margin;
			
			_marginTop = parseDefaultNumberValue( _style["marginTop"], _marginTop.value );
			_marginBottom = parseDefaultNumberValue( _style["marginBottom"], _marginBottom.value );
			_marginLeft = parseDefaultNumberValue( _style["marginLeft"], _marginLeft.value );
			_marginRight = parseDefaultNumberValue( _style["marginRight"], _marginRight.value );
			
			var padding:NumberValue = parseDefaultNumberValue( _style["padding"], 0 );
			_paddingTop = _paddingBottom = _paddingLeft = _paddingRight = padding;
			
			_paddingTop = parseDefaultNumberValue( _style["paddingTop"], _paddingTop.value );
			_paddingBottom = parseDefaultNumberValue( _style["paddingBottom"], _paddingBottom.value );
			_paddingLeft = parseDefaultNumberValue( _style["paddingLeft"], _paddingLeft.value );
			_paddingRight = parseDefaultNumberValue( _style["paddingRight"], _paddingRight.value );
			
			if( _style["position"] != undefined && _style["position"] == "absolute" ) {
				_position = "absolute";	
			}
			
			_zIndex = parseDefaultNumberValue( _style["zIndex"], 0 );
					
			_top = parseDefaultNumberValue( _style["top"], 0 );	
			_left = parseDefaultNumberValue( _style["left"], 0 );	
						
			if( _style["visibility"] != undefined && _style["visibility"] == "hidden" ) {
				_visible = false;	
			}
			
			if( _style["width"] != undefined ) {
				_width = parseDefaultNumberValue( _style["width"], 0 );	
			} else {
				_width = parseDefaultNumberValue( "100%", 10 );	
			}
			if( _style["height"] != undefined ) {
				_height = parseDefaultNumberValue( _style["height"], 10 );	
			} else {
				_height = parseDefaultNumberValue( "100%", 10 );	
			}
			
			if( _style["textVerticalAlign"] != undefined ) {
				_textVerticalAlign = _style["textVerticalAlign"];
			}
		
		}
		
		public override function getStyle( styleName:String ):Object {
			//trace(">> WidgetModel.getStyle('"+styleName+"')");
			if( styleName == "body" ) {
				return _style;	
			}
			return _parentCSS.getStyle( styleName );	
		}
		
				
		public function get xml():XML {
			return _xml;	
		}
		
		public function getWidgetType():String {
			return _xml.name().toString();	
		}
		
		public function get border():Number {
			return _border;	
		}
		
		public function get borderColor():Number {
			return _borderColor;	
		}
		
		public function get borderAlpha():Number {
			return _borderAlpha;	
		}
		
		public function get backgroundColor():Array {
			return _backgroundColor.slice(0);	
		}
		
		public function get backgroundAlpha():Array {
			return _backgroundAlpha.slice(0);	
		}
		
		public function get backgroundRatio():Array {
			return _backgroundRatio.slice(0);	
		}
		
		public function get marginTop():Number {
			return _marginTop.getValue( _availOuterHeight );	
		}
		
		public function get marginBottom():Number {
			return _marginBottom.getValue( _availOuterHeight );	
		}
		
		public function get marginLeft():Number {
			return _marginLeft.getValue( _availOuterWidth );	
		}
		
		public function get marginRight():Number {
			return _marginRight.getValue( _availOuterWidth );	
		}
		
		public function get paddingTop():Number {
			return _paddingTop.getValue( _availInnerHeight );	
		}
		
		public function get paddingBottom():Number {
			return _paddingBottom.getValue( _availInnerHeight );	
		}
		
		public function get paddingLeft():Number {
			return _paddingLeft.getValue( _availInnerWidth );	
		}
		
		public function get paddingRight():Number {
			return _paddingRight.getValue( _availInnerWidth );	
		}
		
		public function get position():String {
			return _position;	
		}
		
		public function get top():Number {
			return _top.getValue( _availOuterHeight );	
		}
		
		public function get left():Number {
			return _left.getValue( _availOuterWidth );	
		}
		
		public function get zIndex():Number {
			return _zIndex.value;	
		}
		
		public function setDimensions( width:Number, height:Number ):void {
			_availOuterWidth = width;
			_availOuterHeight = height;
			
			if( position != "absolute" ) {
				_availInnerWidth = width - _marginLeft.getValue(width) - _marginRight.getValue(width);
				_availInnerHeight = height - _marginTop.getValue(height) - _marginBottom.getValue(height);
			} else {
				_availInnerWidth = width;
				_availInnerHeight = height;
			}
		}
		
		public function get width():Number {
			return _width.getValue( _availInnerWidth );
		}
		
		public function get height():Number {
			return _height.getValue( _availInnerHeight );
		}
		
		public function isWidthDefined():Boolean {
			return ( _style["width"] != undefined ) ? true : false;	
		}
		
		public function isHeightDefined():Boolean {
			return ( _style["height"] != undefined ) ? true : false;	
		}
		
		public function get textVerticalAlign():String {
			return _textVerticalAlign;	
		}
	
		public static function parseDefaultNumberValue( str:String, defaultValue:Number ):NumberValue {
			if( str != null && str.length > 0 ) {
				str = str.replace( /\s/g, "" ); // pulls out white space
				var tmp:String = str.replace( /^#|^0x|[^[0-9a-fA-F\-\.]/g, "" ); // converts to a number string to parse with the Number cast, removes starting # or 0x, allows only 0-9,a-f,A-F, the . or - character to remain. 
				var value:Number;
				if( /^#|^0x/.test(str) ) {
					value = Number( "0x" + tmp );	
				} else {
					value = Number( tmp );	
				}
				if( !isNaN(value) ) {
					if( /\%$/.test( str ) ) {
						return new PercentNumberValue( value );	
					} else {
						return new NumberValue( value );	
					}
				}
			}
			return new NumberValue( defaultValue );
		}
		
		
		
	}
	
	
}
