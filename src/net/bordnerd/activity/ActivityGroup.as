package net.bordnerd.activity {
	import net.bordnerd.activity.Activity;
	import flash.text.StyleSheet;
	import net.bordnerd.activity.ActivityFactory;
	import net.bordnerd.activity.event.ActivityFWEvent;

	/**
	 * @author michael.bordner
	 */
	public class ActivityGroup extends Activity 
	{
		
		private var _childXML:Array;
		private var _children:Array;
		private var _childMap:Object;
		
		private var _completedCount:uint;
		private var _countToDestroy:uint;
		private var _initializedCount:uint;
		private var _isDestroying:Boolean;
		
		public function ActivityGroup( xml:XML = null, css:StyleSheet = null, serializeKey:String = null ) {
			super( xml, css, serializeKey );
			_completedCount = 0;
		}
		
		protected override function initializeActivity( xml:XML, session:String = null ):void {
			_childXML = new Array();
			var children:XMLList = xml.children();
			var af:ActivityFactory = ActivityFactory.getInstance();
			
			for( var i:uint = 0; i < children.length(); ++i ) {
				if( XML(children[i]).nodeKind() == "element" ) {
					if( af.hasClass( String(XML(children[i]).name()) ) ) {
						_childXML.push( XML(children[i]) );	
					}		
				}	
			}
			
			this.activityInitialized();
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
			// if they were to be previously completed, but ActivityGroup completion is handled by child activities completing.
		}
				
		protected override function createChildActivities():void {
			_children = new Array();
			_childMap = new Object();
			_initializedCount = 0;
			
			var af:ActivityFactory = ActivityFactory.getInstance();
			
			var css:StyleSheet = this.getCSS();
			
			var i:uint;
			for( i = 0; i < _childXML.length; ++i ) {
				var activity:Activity = af.createActivity( String(XML(_childXML[i]).name()) );
				activity.addEventListener( ActivityFWEvent.ACTIVITY_INITIALIZED, this.handleActivityInitializedEvent );
				activity.addEventListener( ActivityFWEvent.ACTIVITY_COMPLETED, this.handleActivityCompletedEvent ); 	
				activity.addEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleActivityDestroyedEvent );
				
				var tmpString:String;
				var tmpNumber:Number;
				if( XML(_childXML[i]).@x != undefined ) {
					tmpString = XML(_childXML[i]).@x.toString();
					if( tmpString.length > 0 ) {
						tmpNumber = parseInt( tmpString );
						if( !isNaN( tmpNumber ) ) {
							activity.x = tmpNumber;
						}
					}	
				}
				if( XML(_childXML[i]).@y != undefined ) {
					tmpString = XML(_childXML[i]).@y.toString();
					if( tmpString.length > 0 ) {
						tmpNumber = parseInt( tmpString );
						if( !isNaN( tmpNumber ) ) {
							activity.y = tmpNumber;
						}
					}	
				}
				
				activity.setParentActivity( this.getParentActivity() );			
				_children.push( activity );
			}

			if( _children.length > 0 ) {
				var serializeKey:String = getSerializeKey();

				for( i = 0; i < _childXML.length; ++i ) {
					Activity(_children[i]).addEventListener( ActivityFWEvent.ACTIVITY_INITIALIZING, this.handleActivityInitializingEvent );
					Activity(_children[i]).initialize( XML(_childXML[i]), css, ( serializeKey != null ) ? serializeKey + "_" + i : null );
				}
			} else {
				this.childActivitiesCreated();
			}
			
		}
		
		protected override function addChildActivities():void {
			for( var i:uint = 0; i < _children.length; ++i ) {
				if( _children[i] != undefined && _children[i] != null ) {
					this.addChild( Activity(_children[i]) );
				}
			}
		}
		
		public function getActivityChildCount():uint {
			if( _children != null ) {
				return _children.length;
			}
			return 0;
		}
		
		public override function getActivityChild( id:String ):Activity {
			if( _childMap != null && _childMap[id] != undefined ) {
				return Activity(_childMap[id]);
			}
			return null;
		}
		
		protected override function pauseActivity():void {
			if( _children != null ) {
				for( var i:uint = 0; i < _children.length; ++i ) {
					try {
						Activity( _children[i] ).pause();
					} catch ( e:Error )	{
					}
				}	
			}
		}
		
		protected override function resumeActivity():void {
			if( _children != null ) {
				for( var i:uint = 0; i < _children.length; ++i ) {
					try {
						Activity( _children[i] ).resume();
					} catch ( e:Error )	{
					}
				}	
			}
		}
		
		protected override function destroyChildActivities():void {
			_isDestroying = true;
			_countToDestroy = 0;
			if( _children != null && _children.length > 0 ) {
				var i:uint;		
				var hadChildrenToDestroy:Boolean = false;	
				for( i = 0; i < _children.length; ++i ) {
					if( _children[i] != undefined && _children[i] != null ) {
						_countToDestroy++;
						hadChildrenToDestroy = true;
					}	
				}
				for( i = 0; i < _children.length; ++i ) {
					if( _children[i] != undefined && _children[i] != null ) {
						Activity(_children[i]).setRepeat(false);
						Activity(_children[i]).destroy();
					}	
				}
				if( !hadChildrenToDestroy ) {
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
		
		private function handleActivityInitializingEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				Activity( evt.target ).removeEventListener( ActivityFWEvent.ACTIVITY_INITIALIZING, this.handleActivityInitializingEvent ); 
				var id:String = Activity( evt.target ).getId();
				if( id != null ) {
					_childMap[id] = Activity( evt.target );
				}
			}	
		}
		

		private function handleActivityInitializedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				++_initializedCount;
				if( _initializedCount == _childXML.length ) {
					this.childActivitiesCreated();	
				}			
			}
		}
		

		private function handleActivityCompletedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				++_completedCount;
				if( _completedCount == _childXML.length ) {
					this.completeActivity();
				}
			}	
		}
		
		private function handleActivityDestroyedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				if( !Activity(evt.target).willRepeat() ) {
					Activity(evt.target).removeEventListener( ActivityFWEvent.ACTIVITY_INITIALIZED, this.handleActivityInitializedEvent );
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
				
				}				
				
				--_countToDestroy;
				if( _isDestroying && _countToDestroy == 0 ) {
					this.childActivitiesDestroyed();
				}
			}
		}
	}
}
