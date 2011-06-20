package net.bordnerd.activity {
	import net.bordnerd.activity.Activity;
	import flash.text.StyleSheet;
	import net.bordnerd.activity.ActivityFactory;
	import net.bordnerd.activity.event.ActivityFWEvent;
	/**
	 * @author michael.bordner
	 */
	public class ActivitySequence extends Activity 
	{
		
		private var _childXML:Array;
		private var _children:Array;
		
		private var _activeIndex:uint;
		private var _reportedChildrenCreated:Boolean;
		private var _destroyedCount:uint;
		private var _initializedCount:uint;
		private var _isDestroying:Boolean;
		
		public function ActivitySequence(xml:XML = null, css:StyleSheet = null, serializeKey:String = null ) {
			super( xml, css, serializeKey );
			_activeIndex = 0;
		}
		
		public override function getSession():String {
			return _activeIndex.toString();	
		}
		
		protected override function serializeChildren():void {
			if( _children != null && _children.length > 0 ) {
				for( var i:uint = 0; i < _children.length; ++i ) {
					if( _children[i] != undefined && _children[i] != null ) {
						Activity(_children[i]).serialize();
					}	
				}	
			}	
		}
		
		protected override function resumeSession( session:String ):void {
			// do nothing here, activities must call activityCompleted in this method
			// if they were to be previously completed, but ActivitySequence completion is handled by child activities completing.
		}
		
		protected override function initializeActivity( xml:XML, session:String = null ):void {
			_childXML = new Array();
			var children:XMLList = xml.children();
			var af:ActivityFactory = ActivityFactory.getInstance();
			
			if( session != null ) {
				_activeIndex = parseInt( session ) as uint;	
			}
			
			for( var i:uint = 0; i < children.length(); ++i ) {
				if( XML(children[i]).nodeKind() == "element" ) {
					if( af.hasClass( String(XML(children[i]).name()) ) ) {
						_childXML.push( XML(children[i]) );	
					}		
				}	
			}
			
			this.activityInitialized();
		}
		
		protected override function createChildActivities():void {
			_children = new Array();
			_reportedChildrenCreated = false;
			
			if( _childXML.length > 0 ) {
				
				if( _activeIndex > 0 ) {
					
					_destroyedCount = 0;
					_initializedCount = 0;
					
					var af:ActivityFactory = ActivityFactory.getInstance();			
					var css:StyleSheet = this.getCSS();
					var serializeKey:String = this.getSerializeKey();
					
					var activity:Activity = af.createActivity( String(XML(_childXML[_initializedCount]).name()) );
					activity.addEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleResumedActivityDestroyedEvent );
					activity.addEventListener( ActivityFWEvent.ACTIVITY_INITIALIZED, this.handleResumedActivityInitializedEvent );
					_children[ _initializedCount ] = activity;
					activity.initialize( XML(_childXML[_initializedCount]), css, ( serializeKey != null ) ? serializeKey + "_" + _initializedCount : null );
					
				} else {
					this.createActiveChild();	
				}	
			
			} else {
				this.childActivitiesCreated();
			}
			
		}
		
		protected override function addChildActivities():void {
			this.addChild( Activity(_children[_activeIndex]) );
		}
		
		public function getChildActivityIndex( activity:Activity ):int {
			if( activity != null && _childXML != null ) {
				var childXML:XML = activity.getXMLConfig();
				for( var i:uint; i < _childXML.length; ++i ) {
					if( childXML == _childXML[i] ) {
						return i;	
					}	
				}
			}			
			return -1;
		}
		
		public function getChildActivityCount():uint {
			if( _childXML != null ) {
				return _childXML.length;
			}
			return 0;
		}
		
		public function getActiveChildActivityIndex():uint {
			return _activeIndex;	
		}
		
		public function getActiveChildActivity():Activity {
			if( _children != null ) {
				if( Activity(_children[ _activeIndex ]) != null ) {
					return Activity(_children[ _activeIndex ] );
				}
			}
			return null;
		}
		
		protected override function pauseActivity():void {
			if( _children != null ) {
				try {
					Activity(_children[_activeIndex]).pause();
				} catch ( e:Error )	{
				}	
			}
		}
		
		protected override function resumeActivity():void {
			if( _children != null ) {
				try {
					Activity(_children[_activeIndex]).resume();
				} catch ( e:Error )	{
				}	
			}
		}
		
		protected override function destroyChildActivities():void {
			if( _children != null && _children.length > 0 ) {
				_isDestroying = true;
				var children:Array = new Array();
				var i:uint;
				for( i = 0; i < _children.length; ++i ) {
					if( _children[i] != undefined && _children[i] != null ) {
						children.push( _children[i] );	
					}	
				}
				if( children.length > 0 ) {
					_destroyedCount = children.length;
					for( i = 0; i < children.length; ++i ) {
						Activity(children[i]).removeEventListener( ActivityFWEvent.ACTIVITY_DESTROYING, this.handleActivityDestroyingEvent );	
						Activity(children[i]).destroy();
					}	
				} else {
					this.childActivitiesDestroyed();	
				}
			} else {
				this.childActivitiesDestroyed();	
			}
		}
		
		protected override function removeChildActivities():void {
			if( _children != null && _children.length > 0 ) {
				for( var i:uint = 0; i < _children.length; ++i ) {
					if( _children[i] != undefined && _children[i] != null ) {
						if( this.contains( Activity(_children[i]) ) ) {
							this.removeChild( Activity(_children[i]) );
						}	
					}	
				}
			}
		}
		
		private function createActiveChild():void {
							
			var af:ActivityFactory = ActivityFactory.getInstance();			
			var css:StyleSheet = this.getCSS();
			var serializeKey:String = getSerializeKey();
			
			var activity:Activity = af.createActivity( String(XML(_childXML[_activeIndex]).name()) );
			if( _reportedChildrenCreated == false ) {
				activity.addEventListener( ActivityFWEvent.ACTIVITY_INITIALIZED, this.handleActivityInitializedEvent);	
			}
			activity.addEventListener( ActivityFWEvent.ACTIVITY_CREATED, this.handleActivityCreatedEvent );
			activity.addEventListener( ActivityFWEvent.ACTIVITY_COMPLETED, this.handleActivityCompletedEvent );
			activity.addEventListener( ActivityFWEvent.ACTIVITY_DESTROYING, this.handleActivityDestroyingEvent ); 	
			activity.addEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleActivityDestroyedEvent );
			
			var tmpString:String;
			var tmpNumber:Number;
			if( XML(_childXML[_activeIndex]).@x != undefined ) {
				tmpString = XML(_childXML[_activeIndex]).@x.toString();
				if( tmpString.length > 0 ) {
					tmpNumber = parseInt( tmpString );
					if( !isNaN( tmpNumber ) ) {
						activity.x = tmpNumber;
					}
				}	
			}
			if( XML(_childXML[_activeIndex]).@y != undefined ) {
				tmpString = XML(_childXML[_activeIndex]).@y.toString();
				if( tmpString.length > 0 ) {
					tmpNumber = parseInt( tmpString );
					if( !isNaN( tmpNumber ) ) {
						activity.y = tmpNumber;
					}
				}	
			}
			
			
			_children[ _activeIndex ] = activity;
			activity.initialize( XML(_childXML[_activeIndex]), css, ( serializeKey != null ) ? serializeKey + "_" + _activeIndex : null );
			
		}
		
		private function handleResumedActivityInitializedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				(evt.target as Activity).removeEventListener( ActivityFWEvent.ACTIVITY_INITIALIZED, this.handleResumedActivityInitializedEvent );
							
				++_initializedCount;
				
				if( _initializedCount < _activeIndex ) {
				
					var af:ActivityFactory = ActivityFactory.getInstance();			
					var css:StyleSheet = this.getCSS();
					var serializeKey:String = this.getSerializeKey();			
					
					var activity:Activity = af.createActivity( String(XML(_childXML[_initializedCount]).name()) );
					activity.addEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleResumedActivityDestroyedEvent );
					activity.addEventListener( ActivityFWEvent.ACTIVITY_INITIALIZED, this.handleResumedActivityInitializedEvent );
					_children[ _initializedCount ] = activity;
					activity.initialize( XML(_childXML[_initializedCount]), css, ( serializeKey != null ) ? serializeKey + "_" + _initializedCount : null );
				
				}
				
			}
		}
		
		private function handleResumedActivityDestroyedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				if( ++_destroyedCount == _activeIndex ) {
					for( var i:uint = 0; i < _activeIndex; ++i ) {
						Activity(_children[i]).removeEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleActivityDestroyingEvent );
						_children[i] = null;	
					}
					this.createActiveChild();	
				}	
			}
		}
		
		
		private function handleActivityInitializedEvent( evt:ActivityFWEvent ):void {
			_reportedChildrenCreated = true;
			(evt.target as Activity).removeEventListener( ActivityFWEvent.ACTIVITY_INITIALIZED, this.handleActivityInitializedEvent );
			this.childActivitiesCreated();					
		}
		
		private function handleActivityCreatedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				if( _reportedChildrenCreated == true ) {
					this.addChild( _children[_activeIndex + 1] );
					if( _children[ _activeIndex ] != undefined && _children[ _activeIndex ] != null ) {
						Activity(_children[ _activeIndex ]).removeEventListener( ActivityFWEvent.ACTIVITY_DESTROYING, this.handleActivityDestroyingEvent );	
						Activity(_children[ _activeIndex ]).destroy();	
						//_children[ _activeIndex ] = null;
					}
					++_activeIndex;
				}
			}
		}
		
		private function handleActivityCompletedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				if( _activeIndex + 1 == _childXML.length ) {
					this.completeActivity();	
				} else {
					var af:ActivityFactory = ActivityFactory.getInstance();			
					var css:StyleSheet = this.getCSS();
					var serializeKey:String = getSerializeKey();
					
					var activity:Activity = af.createActivity( String(XML(_childXML[_activeIndex + 1]).name()) );
					activity.addEventListener( ActivityFWEvent.ACTIVITY_CREATED, this.handleActivityCreatedEvent );
					activity.addEventListener( ActivityFWEvent.ACTIVITY_COMPLETED, this.handleActivityCompletedEvent );
					activity.addEventListener( ActivityFWEvent.ACTIVITY_DESTROYING, this.handleActivityDestroyingEvent ); 	
					activity.addEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleActivityDestroyedEvent );
					
					var tmpString:String;
					var tmpNumber:Number;
					if( XML(_childXML[_activeIndex + 1]).@x != undefined ) {
						tmpString = XML(_childXML[_activeIndex + 1]).@x.toString();
						if( tmpString.length > 0 ) {
							tmpNumber = parseInt( tmpString );
							if( !isNaN( tmpNumber ) ) {
								activity.x = tmpNumber;
							}
						}	
					}
					if( XML(_childXML[_activeIndex + 1]).@y != undefined ) {
						tmpString = XML(_childXML[_activeIndex + 1]).@y.toString();
						if( tmpString.length > 0 ) {
							tmpNumber = parseInt( tmpString );
							if( !isNaN( tmpNumber ) ) {
								activity.y = tmpNumber;
							}
						}	
					}
					
					_children[_activeIndex + 1] = activity;
					activity.initialize( XML(_childXML[_activeIndex+1]), css, ( serializeKey != null ) ? serializeKey + "_" + ( _activeIndex + 1 ) : null );
				}
			}	
		}
		
		private function handleActivityDestroyingEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				evt.preventDefault();
			}	
		}
		
		private function handleActivityDestroyedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				Activity(evt.target).removeEventListener( ActivityFWEvent.ACTIVITY_CREATED, this.handleActivityCreatedEvent );
				Activity(evt.target).removeEventListener( ActivityFWEvent.ACTIVITY_COMPLETED, this.handleActivityCompletedEvent );
				Activity(evt.target).removeEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleActivityDestroyedEvent );
				
				for( var i:uint = 0; i < _children.length; ++i ) {
					if( Activity(evt.target) == _children[i] ) {
						if( this.contains( Activity(_children[i]) ) ) {
							this.removeChild( Activity(_children[i]) );
						}
						_children[i] = null;
						break;	
					}	
				}
				
				if( _isDestroying ) {
					if( --_destroyedCount == 0 ) {
						this.childActivitiesDestroyed();	
					}	
				}			
			}
		}
		
	}
}
