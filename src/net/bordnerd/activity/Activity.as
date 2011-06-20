package net.bordnerd.activity {
	import flash.display.*;
	import flash.net.*;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flash.events.*;
	import flash.text.StyleSheet;
	
	import net.bordnerd.exparse.event.DataChangeEvent;
	import net.bordnerd.activity.event.ActivityFWEvent;
	import net.bordnerd.activity.event.ActivityViewEvent;
	import net.bordnerd.activity.event.ViewButtonClickEvent;
	
	import net.bordnerd.exparse.ExpressionParser;
	import net.bordnerd.exparse.DataProvider;
	
	import net.bordnerd.activity.exparse.ActivityDataProvider;
	
	import net.bordnerd.activity.ActivityView;
	import net.bordnerd.activity.ActivityFactory;
	import net.bordnerd.activity.model.ActivityModel;
	
	import net.bordnerd.activity.actions.AbstractAction;

	/**
	 * @author michael.bordner
	 */
	public class Activity extends Sprite
	{
		private static var BASE_PATH:String = "";
		private static var SUBPATH_DATA:String = "";
		private static var SUBPATH_IMG:String = "";
		private static var SUBPATH_AUDIO:String = "";
		private static var SUBPATH_SWF:String = "";
		private static var SUBPATH_CSS:String = "";
		
		public static const STATE_NOTCREATED:uint = 0;
		public static const STATE_CREATED:uint = 10;
		public static const STATE_INITIALIZED:uint = 15; // won't to go this state.
		public static const STATE_STARTED:uint = 20;
		public static const STATE_PAUSED:uint = 30;
		public static const STATE_COMPLETED:uint = 40;
		public static const STATE_DESTROYED:uint = 50;
		
		private static var __rootActivity:Activity;
		
		private var __xml:XML;
		private var __css:StyleSheet;
		private var __serializeKey:String;
		
		private var __state:uint;
		private var __session:Array;
		
		private var __delayExpression:ExpressionParser;
		private var __delayVarMap:Object;
		
		private var __createWhen:String;
		private var __startWhen:String;
		private var __destroyWhen:String;
		private var __repeat:Boolean;		
		private var __id:String;
		private var __pauseParent:String;
		private var __viewUrl:String;
		private var __dataUrl:String;
		
		private var __view:ActivityView;
		private var __xmlModel:XML;
		
		private var __isAddedToStage:Boolean;
		
		private var __loader:Loader;
		private var __urlLoader:URLLoader;
		
		private var __childActivities:ActivityGroup;
		private var __parentActivity:Activity;
		
		private var __model:ActivityModel;
		
		private var __actions:Array;
		
		private var __sentInitalizedEvent:Boolean = false;
		
		private var __maxWidth:Number = 0;
		private var __maxHeight:Number = 0;
		
		private var __dataProvider:ActivityDataProvider;
		
		public function Activity( xml:XML = null, css:StyleSheet = null, serializeKey:String = null ) {
			super();
			
			__dataProvider = new ActivityDataProvider( this );
			
			this.addEventListener( Event.ADDED_TO_STAGE, this.handleAddedToStageEvent );
			this.addEventListener( Event.REMOVED_FROM_STAGE, this.handleRemovedFromStageEvent );
			if( xml != null ) {
				this.initialize( xml, css, serializeKey );	
			}			
		}
		
		public static function createRootActivity():Activity {
			__rootActivity = new Activity();
			return __rootActivity;	
		}
		
		public static function getRootActivity():Activity {
			if( __rootActivity == null ) {
				return createRootActivity();	
			}
			return __rootActivity;	
		}
		
		public static function setRootActivity( activity:Activity ):void {
			__rootActivity = activity;	
		}
		
		public function initialize( xml:XML = null, css:StyleSheet = null, serializeKey:String = null ):void {
			trace(">>> Activity.initialize() with serialize key: "+serializeKey);
			//trace(xml);
			__sentInitalizedEvent = false;
			
			__actions = new Array(); // holder for actions that can be suspended
			
			__css = css;
			if( xml.@cloneXML != undefined && xml.@cloneXML.toString().toLowerCase() == "true" ) {
				__xml = xml.copy();
			} else {
				__xml = xml;	
			}
						
			if( __xml.@id != undefined ) {
				__id = (__xml.@id).toString();
				if( __id.length == 0 ) {
					__id = null;	
				}	
			}
						
			if( serializeKey != null ) {
				__serializeKey = serializeKey;
				
				if( __id != null ) {
					__serializeKey = "_"+ __id;	
				}
			
				if( __xml.@serialize != undefined ) {
					var serialize:String = (__xml.@serialize).toString();
					if( serialize.length > 0 && serialize.toLowerCase() == "false" ) {
						__serializeKey = null;	
					}	
				}
			}	
			
			this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_INITIALIZING ) );
					
			var prevState:uint = STATE_NOTCREATED;
			
			var dp:DataProvider = ExpressionParser.getDataProvider();
			if( __serializeKey != null ) {
				__session = dp.getDataValue( __serializeKey ) as Array;
				if( __session != null ) {
					prevState = __session[0] as uint;
				}
			}
			
			if( prevState >= STATE_STARTED ) {
				__state = STATE_STARTED; // restoring session, need to initalize the state to "started"	
			} 
			
			__xmlModel = __xml;//save this as the model, will update to external model during creation if data attribute is specified
				
			
			if( __xml.@pauseParent != undefined ) {
				__pauseParent = (__xml.@pauseParent).toString();
				if( __pauseParent.length == 0 ) {
					__pauseParent = null;
				}	
			}
			if( __xml.@repeat != undefined ) {
				if( __xml.@repeat.toString() == "true" ) {
					__repeat = true;	
				} else {
					__repeat = false;	
				}
			}
			if( __xml.@startWhen != undefined ) {
				__startWhen = (__xml.@startWhen).toString();	
			}
			if( __xml.@destroyWhen != undefined ) {
				__destroyWhen = (__xml.@destroyWhen).toString();	
			}
			if( __xml.@createWhen != undefined ) {
				__createWhen = (__xml.@createWhen).toString();	
			}
			if( __xml.@url != undefined ) {
				__dataUrl = (__xml.@url).toString(); // url attribute will be equivalent to data attribute for external xml data, but data will override url.
			}
			if( __xml.@data != undefined ) {
				__dataUrl = (__xml.@data).toString();	
			}
			if( __xml.@view != undefined ) {
				__viewUrl = (__xml.@view).toString();	
			}
						
			var delayCreation:Boolean = false;
			if( __state == STATE_NOTCREATED && __createWhen != null && __createWhen.length > 0 ) {
				createDelayExpression( __createWhen );
														
				if( __delayExpression.evaluate() == false ) {					
					dp.addEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayCreateActivityDataChangeEvent );
					delayCreation = true;
				} else {
					destroyDelayExpression();		
				}
					
			}
			
			//process onLoad
			if( __state != STATE_STARTED ) {
				if( __xml.onLoad != undefined ) {
					var ep:ExpressionParser = new ExpressionParser( __xml.onLoad );
					ep.attachLocalDataProvider( __dataProvider );
					ep.evaluate();					
				}
			}
						
			if( !delayCreation ) {
				this.createActivity();	
			} else {
				sendInitializedEvent();
			}
		}
		
		public function serialize():void {
			if( __serializeKey != null ) {
				if( __state > Activity.STATE_NOTCREATED ) {
					var dp:DataProvider = ExpressionParser.getDataProvider();
					
					// index 0 and 1 are always going to be defined
					var session:Array = [ __state, this.getSession() ];
					// index 2 is optional, and if defined will be the actions array construction information for restoring
					if( __actions.length > 0 ) {
						session.push( this.getActionConstructions() );	
					}
					
					dp.setDataValue( __serializeKey, session ); // session is an array
					this.serializeChildren();
				}
			}
		}
		
		//////////////////////////////////////////////////
		// Public Static Methods
		//////////////////////////////////////////////////
		
		public static function setBasePath( p:String ):void {
			if( p != null ) {
				BASE_PATH = p;
			}	
		}
		
		public static function getBasePath():String {
			return BASE_PATH;	
		}
		
		public static function setDataSubPath( p:String ):void {
			SUBPATH_DATA = p;	
		}
		
		public static function getDataPath():String {
			return BASE_PATH + SUBPATH_DATA;	
		}
		
		public static function setSwfSubPath( p:String ):void {
			SUBPATH_SWF = p;	
		}
		
		public static function getSwfPath():String {
			return BASE_PATH + SUBPATH_SWF;	
		}
		
		public static function setImgSubPath( p:String ):void {
			SUBPATH_IMG = p;	
		}
		
		public static function getImgPath():String {
			return BASE_PATH + SUBPATH_IMG;	
		}
		
		public static function setAudioSubPath( p:String ):void {
			SUBPATH_AUDIO = p;	
		}
		
		public static function getAudioPath():String {
			return BASE_PATH + SUBPATH_AUDIO;	
		}
		
		public static function setCSSSubPath( p:String ):void {
			SUBPATH_CSS = p;	
		}
		
		public static function getCSSPath():String {
			return BASE_PATH + SUBPATH_CSS;	
		}
		
		//////////////////////////////////////////////////
		// Public Methods
		//////////////////////////////////////////////////
		
		public function getId():String {
			return __id;
		}
		
		public function getSerializeKey():String {
			return __serializeKey;	
		}
		
		public function setId( id:String ):void {
			__id = id;	
		}
	
		public function getMaxWidth():Number {
			return __maxWidth;	
		}
			
		public function setMaxWidth( v:Number ):void {
			__maxWidth = v;	
		}

		public function getMaxHeight():Number {
			return __maxHeight;	
		}
		
		public function setMaxHeight( v:Number ):void {
			__maxHeight = v;	
		}

		public function getPauseParent():String {
			return __pauseParent;	
		}
		
		public function getCSS():StyleSheet {
			return __css;	
		}
		
		public function getState():uint {
			return __state;	
		}
		
		public function getView():ActivityView {
			return __view;	
		}
		
		public function get view():ActivityView {
			return __view;	
		}
		
		public function willRepeat():Boolean {
			return __repeat;	
		}
		
		public function setRepeat( val:Boolean ):void {
			__repeat = val;	
		}
		
		/**
		 * @return the loaded xml model which the data attribute on the xml configuration node pointed to, otherwise the xml configuration node is returned.
		 */
		public function getXMLModel():XML {
			return __xmlModel;
		}
		
		/**
		 * @return the xml configuration node that was passed to the constructor
		 */
		public function getXMLConfig():XML {
			return __xml;	
		}
		
		public function getModel():ActivityModel {
			return __model;	
		}
		
		public function get model():ActivityModel {
			return __model;	
		}
		
		public function getActivityChild( id:String ):Activity {
			if( __childActivities != null ) {
				return __childActivities.getActivityChild(id);	
			}
			return null;
		}
		
		public function getChildrenActivityGroup():ActivityGroup {
			return __childActivities;	
		}
		
		public function get childrenActivityGroup():ActivityGroup {
			return __childActivities;	
		}
		
		/**
		 * Unlinks view so that it doesn't receive update events.
		 */
		public function unlinkViewUpdateListener():void {
			this.removeEventListener( ActivityFWEvent.UPDATE_EVENT, __view.update );
		}
		
		/**
		 * Links view so that it does receive update events.
		 */
		public function linkViewUpdateListener():void {
			this.addEventListener( ActivityFWEvent.UPDATE_EVENT, __view.update );
		}
		
		public function modelInitialized():void {
			this.initializeActivity( __xmlModel, __session != null ? __session[1] : null );
		}
		
		public function start():void {
			var prevState:uint = STATE_NOTCREATED;
			if( __session != null ) {
				prevState = __session[0] as uint;
			}
			if( prevState >= STATE_CREATED || __state == STATE_CREATED ) {
				//process onStart
				if( __delayExpression != null ) {
					dp = ExpressionParser.getDataProvider();
					dp.removeEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayStartActivityDataChangeEvent );
					destroyDelayExpression();
				}
				
				
				this.addEventListener( ActivityFWEvent.VIEW_BUTTON_CLICK, this.handleViewButtonClickEvent );
				
				this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_STARTED ) );
				
				if( __state == STATE_CREATED ) {
					__state = STATE_STARTED; // this was moved after the dispatch, so that if this event pauses a parent, it can't end up pausing this instance as consequence (won't be in started state)
					if( __xml.onStart != undefined ) {
						var ep:ExpressionParser = new ExpressionParser( __xml.onStart );
						ep.attachLocalDataProvider( __dataProvider );
						ep.evaluate();
					}					
					
					this.startActivity();
				} else {
					if( prevState == STATE_PAUSED ) {
						this.pause();	
					}
					
					if( __session.length > 2 ) { // if session array is greater than length 2, index 2 must be the actions construction array
						this.restoreActions( __session[2] as Array );
					}
					
					trace(">>> Calling Activity.resumeSession() for activity with session id: "+__serializeKey);
					//trace( __xml );
					this.resumeSession( __session[1] as String );
				}				
				
				sendInitializedEvent();
								
				this.addEventListener( ActivityFWEvent.ACTIVITY_CREATING, this.handleActivityCreatingEvent );
				this.addEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleActivityDestroyedEvent );
				
				if( prevState != STATE_DESTROYED && __delayExpression == null ) {
					if( __destroyWhen != null && __destroyWhen.length > 0 ) {						
						createDelayExpression( __destroyWhen );						
						if( __delayExpression.evaluate() == false ) {					
							var dp:DataProvider = ExpressionParser.getDataProvider();
							dp.addEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayDestroyActivityDataChangeEvent );					
						} else {
							destroyDelayExpression();
							this.destroy();		
						}						
					}
				}
							
			} else {
			 	throw new Error( "invalid state for start()" );	
			}
		}
		
		public function pause():void {
			if( __state == STATE_STARTED ) {
				__state = STATE_PAUSED;
				this.pauseActivity();
				this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_PAUSED ) );	
			}
		}
		
		public function resume():void {
			if( __state == STATE_PAUSED ) {
				__state = STATE_STARTED;
				this.resumeActivity();
				this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_RESUMED ) );
				this.resumeActions();	
			}
		}
		
		public function isAddedToStage():Boolean {
			return __isAddedToStage;	
		}
		
		public function destroy():void {
			if( __state != STATE_DESTROYED ) {
				
				var destroyingEvent:ActivityFWEvent = new ActivityFWEvent( ActivityFWEvent.ACTIVITY_DESTROYING );
				this.dispatchEvent( destroyingEvent );
				if( destroyingEvent.isDefaultPrevented() ) {
					return; // break out, destroy was cancelled.	
				}
				
				var prevState:uint = __state;
				__state = STATE_DESTROYED;
				var dp:DataProvider;
				
				if( prevState == STATE_NOTCREATED ) {
					if( __delayExpression != null ) {
						dp = ExpressionParser.getDataProvider();
						dp.removeEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayCreateActivityDataChangeEvent );
						destroyDelayExpression();
					}	
				} else if( prevState == STATE_CREATED ) {
					if( __delayExpression != null ) {
						dp = ExpressionParser.getDataProvider();
						dp.removeEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayStartActivityDataChangeEvent );
						destroyDelayExpression();
					}
				} else {
					if( __delayExpression != null ) {
						dp = ExpressionParser.getDataProvider();
						dp.removeEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayDestroyActivityDataChangeEvent );
						destroyDelayExpression();
					}
				}
				
				if( prevState > STATE_NOTCREATED ) {
					//unlink view from activity
					__view.removeEventListener( ActivityFWEvent.VIEW_EVENT, this.handleViewEvent );
					this.removeEventListener( ActivityFWEvent.UPDATE_EVENT, __view.update );
					
					destroyChildActivities();
				} else {
					destroyed();	
				}
								
			}			
		}
		
		//////////////////////////////////////////////////
		// Protected Methods
		//////////////////////////////////////////////////
		
		protected function activityAddedToStage():void {
			
		}
		
		protected function activityRemovedFromStage():void {
			
		}
		
		function setParentActivity( activity:Activity ):void {
			__parentActivity = activity;	
		}
		
		function getParentActivity():Activity {
			return __parentActivity;	
		}
		
		
		/**
		 * This method will be called when the view has been loaded, and any xml models have been loaded. 
		 * 
		 * to be overridden, should call activityInitialized()
		 */
		protected function initializeActivity( xml:XML, session:String = null ):void {
			this.activityInitialized();
		}
		
		/**
		 * Activity subclasses must call this method when the activity is initialized.
		 */
		protected function activityInitialized():void {
			var loadingView:Boolean = false;
			if( __viewUrl != null && __viewUrl.length > 0 ) {
				if( __viewUrl.toLowerCase().lastIndexOf(".swf") == __viewUrl.length - 4  ) { // assume it is a URL
					loadingView = true;
					
					__loader = new Loader();
					
					__loader.contentLoaderInfo.addEventListener( Event.COMPLETE, this.handleViewLoadedEvent );
					__loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, this.handleViewLoadFailureEvent );
					
					var rqst:URLRequest = new URLRequest( Activity.getSwfPath() + __viewUrl );
					__loader.load( rqst );
					
				} else if( __parentActivity != null && __parentActivity.getChildByName( __viewUrl ) != null ) {
					__view = ActivityView( __parentActivity.getChildByName( __viewUrl ) );
					this.x = __view.x;
					this.y = __view.y;
					__view.x = 0;
					__view.y = 0;
				} else if( __parentActivity != null && __parentActivity.getView().getChildByName( __viewUrl ) != null ) {
					__view = ActivityView( __parentActivity.getView().getChildByName( __viewUrl ) );
				} else { // assume a library symbol, or some display object class
					trace(">>> Activity creating view with URI:"+__viewUrl);
					var tmp:Class = flash.utils.getDefinitionByName( __viewUrl ) as Class;
					__view = ActivityView( new tmp() ); 		
				}	
			} else {
				__view = new ActivityView();
			}
			
			if( !loadingView ) {
				this.initializeView();	
			}			
		}
		
		/**
		 * to be overridden, called when the view is linked, could be useful to send events to view before start() is called
		 * must call viewAssetsPrepared() when prepared if overriding this method.
		 */
		protected function prepareViewAssets():void {
			this.viewAssetsPrepared();
		}
		
		protected function viewAssetsPrepared():void {
			this.viewAssetsReady();	
		}
		
		
		/**
		 * to be overridden
		 */
		protected function handleViewEvent( evt:ActivityViewEvent ):void {
			
		}
		
		/**
		 * to be overridden, return true if handled 
		 */
		protected function onViewButtonClick( id:String ):Boolean {
			return false;
		}
		
		/**
		 * Activity subclasses should call this method when the activity completes
		 */
		protected function completeActivity():void {
			var prevState:uint = STATE_NOTCREATED;
			if( __session != null ) {
				prevState = __session[0] as uint;
			}
			if( __state == STATE_STARTED ) {
				__state = STATE_COMPLETED;
				
				this.removeEventListener( ActivityFWEvent.VIEW_BUTTON_CLICK, this.handleViewButtonClickEvent );
				
				this.removeEventListener( ActivityFWEvent.ACTIVITY_CREATING, this.handleActivityCreatingEvent );
				this.removeEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleActivityDestroyedEvent );
				
				
				//process onComplete
				if( prevState < STATE_COMPLETED ) {
					if( __xml.onComplete != undefined ) {
						var ep:ExpressionParser = new ExpressionParser( __xml.onComplete );
						ep.attachLocalDataProvider( __dataProvider );
						ep.evaluate();
					}
				}
						
				this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_COMPLETED ) );
				
				var delayDestroy:Boolean = false;
				if( prevState != STATE_DESTROYED ) {
					if( __destroyWhen != null && __destroyWhen.length > 0 ) {
						if( __delayExpression != null ) {
							delayDestroy = true; // this was set up in start	
						} else {
						
							createDelayExpression( __destroyWhen );						
							if( __delayExpression.evaluate() == false ) {					
								var dp:DataProvider = ExpressionParser.getDataProvider();
								dp.addEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayDestroyActivityDataChangeEvent );
								delayDestroy = true;					
							} else {
								destroyDelayExpression();										
							}						

						}					
					}
				}
				
				if( !delayDestroy ) {
					this.destroy();	
				}
				
			} else {
				throw new Error( "invalid state for completeActivity() :" + __state );	
			}					
		}
		
				
		/**
		 * can be overriden
		 */
		protected function createModel( controller:Activity, xml:XML, config:XML ):ActivityModel {
			return new ActivityModel( controller, xml, config );	
		}
		
		/**
		 * can be overridden, must call childActivitiesCreated()
		 */
		protected function createChildActivities():void {
			var creatingChildren:Boolean = false;
			if( __xml.activities != null ) {
				var activities:XMLList = __xml.activities;
				var childActivitiesXML:XML = activities[0];	
			
				if( childActivitiesXML != null ) {
					creatingChildren = true;
					__childActivities = ActivityFactory.getInstance().createActivity( "activities" ) as ActivityGroup;
					__childActivities.addEventListener( ActivityFWEvent.ACTIVITY_INITIALIZED, this.handleChildActivitiesInitializedEvent );
					
					var tmpString:String;
					var tmpNumber:Number;
					if( childActivitiesXML.@x != undefined ) {
						tmpString = childActivitiesXML.@x.toString();
						if( tmpString.length > 0 ) {
							tmpNumber = parseInt( tmpString );
							if( !isNaN( tmpNumber ) ) {
								__childActivities.x = tmpNumber;
							}
						}	
					}
					if( childActivitiesXML.@y != undefined ) {
						tmpString = childActivitiesXML.@y.toString();
						if( tmpString.length > 0 ) {
							tmpNumber = parseInt( tmpString );
							if( !isNaN( tmpNumber ) ) {
								__childActivities.y = tmpNumber;
							}
						}	
					}
					
					__childActivities.setParentActivity( this );
					__childActivities.initialize( childActivitiesXML, __css, ( __serializeKey != null ) ? __serializeKey + "_0" : null );
				}
			}
			if( creatingChildren == false ) {
				this.childActivitiesCreated();	
			}
		}
		
		protected function childActivitiesCreated():void {
			this.created();
		}
		
		/**
		 * can be overridden
		 */
		protected function addChildActivities():void {
			if( __childActivities != null ) {
				this.addChild( __childActivities );	
			}
		}
		
		/**
		 * can be overridden
		 */
		protected function serializeChildren():void {
			if( __childActivities != null ) {
				__childActivities.serialize();
			}	
		}
		
		/**
		 * can be overridden, must call childActivitiesDestroyed()
		 */
		protected function destroyChildActivities():void {
			if( __childActivities != null ) {
				__childActivities.addEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleChildActivitiesDestroyedEvent );
				__childActivities.destroy();	
			} else {
				childActivitiesDestroyed();	
			}
		}
		
		protected function childActivitiesDestroyed():void {
			__view.addEventListener( ActivityFWEvent.VIEW_DESTROYED, this.handleViewDestroyedEvent );
			__view.destroy();
		}
		
		/**
		 * can be overridden
		 */
		protected function removeChildActivities():void {
			var prevState:uint = STATE_NOTCREATED;
			if( __session != null ) {
				prevState = __session[0] as uint;
			}
			if( __childActivities != null ) {
				if( prevState != STATE_DESTROYED ) {
					this.removeChild( __childActivities );
				}	
			}
		}
		
		/**
		 * Called when the activity is started.  This is when the logic should kick in for the activity.
		 * 
		 * to be overridden
		 */
		protected function startActivity():void {
			
		}
		
		/**
		 * to be overriden.  if resuming would resume to a completed activity, the subclass must call activityCompleted()
		 */
		protected function resumeSession( session:String ):void {
			var prevState:uint = STATE_NOTCREATED;
			if( __session != null ) {
				prevState = __session[0] as uint;
			}
			if( prevState >= STATE_COMPLETED ) {
				this.completeActivity();	
			} else {
				this.startActivity();	
			}
		}
		
		/**
		 * to be overriden.
		 */
		public function getSession():String {
			return '';	
		}
		
		/**
		 * to be overridden
		 */
		protected function pauseActivity():void {
			
		}
		
		/**
		 * to be overridden
		 */
		protected function resumeActivity():void {
			
		}
		
		/**
		 * can be overridden, must call activityDestroyed()
		 */
		protected function destroyActivity():void {
			this.activityDestroyed();
		}
		
		protected function activityDestroyed():void {
			//process onUnload
			var prevState:uint = STATE_NOTCREATED;
			if( __session != null ) {
				prevState = __session[0] as uint;
			}
			if( prevState != STATE_DESTROYED ) {
				trace(">>> processing onUnload for activity.");
				if( __xml.onUnload != undefined ) {
					var ep:ExpressionParser = new ExpressionParser( __xml.onUnload );
					ep.attachLocalDataProvider( __dataProvider );
					ep.evaluate();
				}
			}
			this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_DESTROYED ) );	
		}
		
		
		/**
		 * Subclasses may call this method when they are able to be paused,
		 * the actions will be processed when the activity resumes.
		 */
		protected function suspendAction( action:AbstractAction ):void {
			__actions.push( action );
			
			var expression:String = action.expression;
			if( expression != null && expression.length > 0 ) {
				var ep:ExpressionParser = new ExpressionParser( expression );
				ep.attachLocalDataProvider( __dataProvider );
				ep.evaluate();
				if( __state != STATE_PAUSED ) {
					this.resumeActions();	
				}
			} else {
				this.resumeActions();	
			}
		}
		
		/**
		 * Should be override if subclass is suspending actions.
		 */
		protected function processAction( action:AbstractAction ):void {
			
		}		
		
		//////////////////////////////////////////////////
		// Private Methods
		//////////////////////////////////////////////////
		
		private function getActionConstructions():Array {
			var a:Array = new Array();
			for( var i:uint = 0; i < __actions.length; ++i ) {
				var className:String = getQualifiedClassName(__actions[i]);
				var args:Array = AbstractAction( __actions[i] ).getArguments();
				a.push( { c:className, a:args } );
			}
			return a;	
		}
		
		private function restoreActions( a:Array ):void {
			for( var i:uint = 0; i < a.length; ++i ) {
				var className:String = a[i]["c"] as String;
				var args:Array = a[i]["a"] as Array;
				var c:Class = getDefinitionByName( className ) as Class;
				var action:AbstractAction = AbstractAction(new c());
				action.initializeArguments( args );
				__actions.push( action );	
			}	
		}		
		
		private function handleAddedToStageEvent( evt:Event ):void {
			if( evt.target == evt.currentTarget ) {
				__isAddedToStage = true;
				this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_ADDED_TO_STAGE ) );
				this.activityAddedToStage();
			}	
		}
		
		private function handleRemovedFromStageEvent( evt:Event ):void {
			if( evt.target == evt.currentTarget ) {
				__isAddedToStage = false;
				this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_REMOVED_FROM_STAGE ) );
				this.activityRemovedFromStage();
			}
		}
		
		private function resumeActions():void {
			var actions:Array = __actions; // create new array here in case more actions are added
			__actions = new Array();
			while( actions.length > 0 ) {
				var action:AbstractAction = actions.shift() as AbstractAction;
				this.processAction( action );	
			}	
		}
		
		/**
		 * Utility method that will set up data for the startWhen, createWhen, requestControlWhen expressions
		 */
		private function createDelayExpression( expression:String ):void {
			__delayExpression = new ExpressionParser( expression );
			__delayExpression.attachLocalDataProvider( __dataProvider );
			var vars:Array = __delayExpression.getVariables();
			__delayVarMap = new Object(); //storing which variables are in the expression 
				// so we can decide if we should evaluate based on data change event, we'll evaluate only
				// if one of these variables have been changed 
			for( var i:uint = 0; i < vars.length; ++i ) { 
				__delayVarMap[ vars[i] ] = vars[i];	
			}	
		}
		
		private function destroyDelayExpression():void {
			__delayExpression = null;
			__delayVarMap = null;
		}
		
		/**
		 * Will create the display asset view, as well as load any xml model
		 */
		private function createActivity():void {
			this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_CREATING ) );
			
			if( __dataUrl != null && __dataUrl.length > 0 ) {
				__urlLoader = new URLLoader();
				__urlLoader.addEventListener( Event.COMPLETE, this.handleXMLModelLoadedEvent );
				__urlLoader.addEventListener( IOErrorEvent.IO_ERROR, this.handleXMLModelLoadFailedEvent );
				var rqst:URLRequest = new URLRequest( Activity.getDataPath() + __dataUrl );
				__urlLoader.load( rqst );
			} else {
				__model = createModel( this, __xmlModel, __xml );
				__model.initialize();
			}			
			
		}
		
		private function handleXMLModelLoadFailedEvent( evt:Event ):void {
			if( evt.target == evt.currentTarget ) {
				__urlLoader.removeEventListener( Event.COMPLETE, this.handleXMLModelLoadedEvent );
				__urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, this.handleXMLModelLoadFailedEvent );
				__urlLoader = null;	
				__model = createModel( this, __xmlModel, __xml );
				__model.initialize();
			}
		}
		
		private function handleXMLModelLoadedEvent( evt:Event ):void {
			if( evt.target == evt.currentTarget ) {
				__urlLoader.removeEventListener( Event.COMPLETE, this.handleXMLModelLoadedEvent );
				__urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, this.handleXMLModelLoadFailedEvent );
				
				var oldValue:Boolean = XML.ignoreWhitespace;
				XML.ignoreWhitespace = false;
				var xml:XML = new XML( evt.target.data );
				var txtNodes:XMLList = xml..txt;
				var count:uint = txtNodes.length();
				var i:uint;
				for( i = 0; i < count; ++i ) {
					var fixed:String = txtNodes[i].*.toString().replace(/\n|\r/g,"").replace(/\t/g," ").replace(/\s\s+/g," ").replace(/^\s+|\s+$/,"");				
					txtNodes[i] = fixed;
				}			
				XML.ignoreWhitespace = oldValue;
				__xmlModel = new XML( xml.toXMLString() );
				
				__urlLoader = null;
				__model = createModel( this, __xmlModel, __xml );
				__model.initialize();
			}
		}
		
		private function handleViewLoadFailureEvent( evt:IOErrorEvent ):void {
			if( evt.target == evt.currentTarget ) {
				__loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, this.handleViewLoadedEvent );
				__loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, this.handleViewLoadFailureEvent );
				__loader = null;
					
				__view = new ActivityView();
				this.initializeView();
			}
		}
		
		private function handleViewLoadedEvent( evt:Event ):void {
			if( evt.target == evt.currentTarget ) {
				__loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, this.handleViewLoadedEvent );
				__loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, this.handleViewLoadFailureEvent );
				__view = ActivityView( __loader.content );
				__loader = null;
				this.initializeView();
			}
		}
		
		private function initializeView():void {
			__view.addEventListener( ActivityFWEvent.VIEW_INITIALIZED, this.handleViewInitializedEvent );
			__view.initialize( this, __css );
		}
		
		private function handleViewInitializedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				__view.removeEventListener( ActivityFWEvent.VIEW_INITIALIZED, this.handleViewInitializedEvent );			
				
				var mask:Sprite = null;
				var params:Array;
				
				if( __xml.@maskRect != undefined ) {
					mask = new Sprite();
					
					params = __xml.@maskRect.toString().split(",");
					
					mask.graphics.beginFill(0xFFFFFF,0);
					mask.graphics.lineStyle(0,0xFFFFFF,0);
					mask.graphics.drawRect( Number(params[0]), Number(params[1]), Number(params[2]), Number(params[3]) );
					
				} else if( __xml.@maskRoundRect != undefined ) {
					mask = new Sprite();
					
					params = __xml.@maskRoundRect.toString().split(",");
					
					mask.graphics.beginFill(0xFFFFFF,0);
					mask.graphics.lineStyle(0,0xFFFFFF,0);
					mask.graphics.drawRoundRect( Number(params[0]), Number(params[1]), Number(params[2]), Number(params[3]), Number(params[4]), Number(params[5]) );
				
				} else if( __xml.@maskCircle != undefined ) {
					mask = new Sprite();
					
					params = __xml.@maskRoundRect.toString().split(",");
					
					mask.graphics.beginFill(0xFFFFFF,0);
					mask.graphics.lineStyle(0,0xFFFFFF,0);
					mask.graphics.drawCircle( Number(params[0]), Number(params[1]), Number(params[2]) );
					
				} else if( __xml.@maskEllipse != undefined ) {
					mask = new Sprite();
					
					params = __xml.@maskRoundRect.toString().split(",");
					
					mask.graphics.beginFill(0xFFFFFF,0);
					mask.graphics.lineStyle(0,0xFFFFFF,0);
					mask.graphics.drawEllipse( Number(params[0]), Number(params[1]), Number(params[2]), Number(params[3]) );
				
				}
				
				if( mask != null ) {
					this.addChild( mask );
					__view.mask = mask;	
				}
				
				this.createChildActivities();
			}
		}
				
		private function handleChildActivitiesInitializedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				__childActivities.removeEventListener( ActivityFWEvent.ACTIVITY_INITIALIZED, this.handleChildActivitiesInitializedEvent );
				this.childActivitiesCreated();	
			}	
		}
		
		private function created():void {
			
			// link activity with view
			__view.addEventListener( ActivityFWEvent.VIEW_EVENT, this.handleViewEvent );
			this.addEventListener( ActivityFWEvent.UPDATE_EVENT, __view.update );
			
			this.prepareViewAssets();			
				
		}
		
		private function viewAssetsReady():void {
			var prevState:uint = STATE_NOTCREATED;
			if( __session != null ) {
				prevState = __session[0] as uint;
			}
			
			if( prevState != STATE_DESTROYED ) {
				if( __view.parent == null || __view.parent is RootActivity || __view.parent is Loader ) {			
					this.addChild( __view ); // first time the component will be visible.
				}
				this.addChildActivities();
			}
			
			if( prevState == STATE_NOTCREATED ) {
				__state = STATE_CREATED;
				if( __xml.onCreate != undefined ) {
					var ep:ExpressionParser = new ExpressionParser( __xml.onCreate );
					ep.attachLocalDataProvider( __dataProvider );
					ep.evaluate();					
				}
			}
			this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_CREATED ) );
			
			var delayStart:Boolean = false;
			if( __state != STATE_STARTED ) {
				if( __startWhen != null && __startWhen.length > 0 ) {
					
					createDelayExpression( __startWhen );
					
					if( __delayExpression.evaluate() == false ) {					
						var dp:DataProvider = ExpressionParser.getDataProvider();
						dp.addEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayStartActivityDataChangeEvent );
						delayStart = true;
					} else {
						destroyDelayExpression();		
					}
					
				}				
			}
			
			if( !delayStart ) {
				this.start();	
			} else {
				this.sendInitializedEvent();	
			}
		}
		
		private function sendInitializedEvent():void {
			if( __sentInitalizedEvent == false ) {
				__sentInitalizedEvent = true;
				this.dispatchEvent( new ActivityFWEvent( ActivityFWEvent.ACTIVITY_INITIALIZED ) );	
			}	
		}
				
		private function handleDelayCreateActivityDataChangeEvent( evt:DataChangeEvent ):void {
			if( __delayVarMap[ evt.id ] != undefined ) {
				if( __delayExpression.evaluate() ) {
					var dp:DataProvider = ExpressionParser.getDataProvider();
					dp.removeEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayCreateActivityDataChangeEvent );
					destroyDelayExpression();
					createActivity();
				}	
			}
		}
		
		private function handleDelayStartActivityDataChangeEvent( evt:DataChangeEvent ):void {
			if( __delayVarMap[ evt.id ] != undefined ) {
				if( __delayExpression.evaluate() ) {
					var dp:DataProvider = ExpressionParser.getDataProvider();
					dp.removeEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayStartActivityDataChangeEvent );
					destroyDelayExpression();
					start();
				}	
			}
		}
		
		private function handleDelayDestroyActivityDataChangeEvent( evt:DataChangeEvent ):void {
			if( __delayVarMap[ evt.id ] != undefined ) {
				if( __delayExpression.evaluate() ) {
					var dp:DataProvider = ExpressionParser.getDataProvider();
					dp.removeEventListener( DataChangeEvent.DATA_CHANGE, this.handleDelayDestroyActivityDataChangeEvent );
					destroyDelayExpression();
					destroy();
				}	
			}
		}
		
		private function handleViewButtonClickEvent( evt:ViewButtonClickEvent ):void {
			var eventNode:String = "onViewButtonClick_" + evt.id;
			if( __xml[ eventNode ] != undefined ) {
				var ep:ExpressionParser = new ExpressionParser( __xml[ eventNode ].toString() );
				ep.attachLocalDataProvider( __dataProvider );
				ep.evaluate();					
			}
			
			if( this.onViewButtonClick( evt.id ) ) {
				evt.stopImmediatePropagation();	
			}
		}
		
		private function handleActivityCreatingEvent( evt:ActivityFWEvent ):void {
			var activity:Activity = Activity( evt.target );
			if( __id != null && activity.getPauseParent() == __id ) {
				if( __state == STATE_STARTED ) {
					this.pause();					
				}	
			}	
		}
		
		private function handleActivityDestroyedEvent( evt:ActivityFWEvent ):void {
			var activity:Activity = Activity( evt.target );
			if( __id != null && activity.getPauseParent() == __id ) {
				if( __state == STATE_PAUSED ) {
					this.resume();					
				}	
			}	
		}
		
		private function handleViewDestroyedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				var prevState:uint = STATE_NOTCREATED;
				if( __session != null ) {
					prevState = __session[0] as uint;
				}
				__view.removeEventListener( ActivityFWEvent.VIEW_DESTROYED, this.handleViewDestroyedEvent );
				if( prevState != STATE_DESTROYED ) {
					if( this.contains( __view ) ) {
						this.removeChild( __view );
					}
				}
				this.destroyed();
			}
		}
		
		private function handleChildActivitiesDestroyedEvent( evt:ActivityFWEvent ):void {
			if( evt.target == evt.currentTarget ) {
				__childActivities.removeEventListener( ActivityFWEvent.ACTIVITY_DESTROYED, this.handleChildActivitiesDestroyedEvent );
				this.removeChildActivities();
				this.childActivitiesDestroyed();
			}	
		}
		
		private function clearSession():void {
			if( __serializeKey != null ) {
				var dp:DataProvider = ExpressionParser.getDataProvider();
				dp.setDataValue( __serializeKey, null );	
			}
		}
		
		private function destroyed():void {
			if( !__repeat ) {
				this.serialize();
			}
			this.destroyActivity();
			if( __repeat ) {
				var repeatingEvent:ActivityFWEvent = new ActivityFWEvent( ActivityFWEvent.ACTIVITY_REPEATING );
				this.dispatchEvent( repeatingEvent );
				if( repeatingEvent.isDefaultPrevented() == false ) {
					__state = STATE_NOTCREATED;
					this.clearSession();
					this.initialize( __xml, __css, __serializeKey );
				} else {
					__repeat = false;	
				}
			}				
		}
		
	}
}
