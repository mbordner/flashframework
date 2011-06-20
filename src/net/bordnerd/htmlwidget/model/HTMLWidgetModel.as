package net.bordnerd.htmlwidget.model {
	import net.bordnerd.htmlwidget.model.WidgetModel;
	import flash.text.*;
	import net.bordnerd.htmlwidget.WidgetFactory;
	
	/**
	 * @author michael.bordner
	 */
	public class HTMLWidgetModel extends WidgetModel 
	{
		
		private var _children:Array;
		private var _stackedChildren:Array;
		
		public function HTMLWidgetModel( xml:XML, css:StyleSheet ) {
			super(xml,css);
			
			_children = new Array();
			_stackedChildren = new Array();
			
			var nodes:XMLList = xml.*;
			var count:uint = nodes.length();
			
			var model:WidgetModel;
			
			for( var i:uint = 0; i < count; ++i ) {
				model = null;
				if( nodes[i].nodeKind() == "text" ) {
					if( count == 1 ) {
						_children.push( nodes[i].toString() );
					} else {
						var child:XML = <div></div>;
						
						while( i < count && isHTMLTextNode(nodes[i]) ) {
							child.appendChild( nodes[i] );
							++i;	
						}
						
						child = <div>{ child.*.toString().replace(/\n|\r/g,"") }</div>;
						
						if( i == count ) {
							_children.push( child.toString() );
						} else {
							model = new HTMLWidgetModel( child, this );
							--i;								
						} 	
					}	
				} else if( nodes[i].nodeKind() == "element" ) {
					if( nodes[i].name().toString() == "div" ) {
						model = new HTMLWidgetModel( nodes[i], this );
					} else if( nodes[i].name().toString() == "al" ) {	
						model = this.convertALToDivs( nodes[i] );
					} else {
						model = WidgetFactory.getInstance().createWidgetModel( nodes[i], this );	
					}
				}
				if( model != null ) {
					if( model.position == "absolute" && model.zIndex != 0 ) {
						_stackedChildren.push( model );	
					} else {
						_children.push( model );	
					}
				}
			}
		}
		
		public function getChildren():Array {
			return _children.slice(0);	
		}
		
		public function getStackedChildren():Array {
			return _stackedChildren.slice(0);	
		}
		
		private function isHTMLTextNode( n:XML ):Boolean {
			if( n.nodeKind() == "text" ) {
				return true;	
			} else if( n.nodeKind() == "element" ) {
				var type:String = n.name().toString().toLowerCase();
				if( type == "a" || type == "b" || type == "br" || type == "font" || type == "img" ||
					type == "i" || type == "li" || type == "p" || type == "span" ||	type == "textformat" ||
					type == "u"
				) {
					return true;	
				}
			}
			return false;	
		}
		
		private function convertALToDivs( xml:XML ):HTMLWidgetModel {
			var container:XML = <div></div>;
			if( xml.@style != undefined ) {
				container.@style = xml.@style.toString();	
			}
			if( xml.@["class"] != undefined ) {
				container.@["class"] = xml.@["class"].toString();	
			}
			
			var letters:Array = [ 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','x','y','z' ];
			
			var lis:XMLList = xml.li;
			var count:uint = lis.length();
			
			for( var i:uint = 0; i < count; ++i ) {
				var row:XML = <div><div style="position:absolute;width:5%;text-align:right;text-vertical-align:middle;">{letters[i]}.</div><div style="position:absolute;left:7%;">{ lis[i].toString() }</div></div>;	
				container.appendChild( row );
			}
			
			//trace("---------");
			//trace( container.toXMLString() );
			//trace("---------");
			
			var model:HTMLWidgetModel = new HTMLWidgetModel( container, this );
			return model;		
			
		}
		
	}
}
