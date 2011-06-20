package net.bordnerd.activity.event {

	import flash.events.Event;

	/**
	 * @author michael.bordner
	 */
	public class ActivityFWEvent extends Event 
	{
		
		public static const ACTIVITY_CREATING:String = "activityCreating";
		public static const ACTIVITY_CREATED:String = "activityCreated";
		public static const ACTIVITY_INITIALIZING:String = "activityInitializing";
		public static const ACTIVITY_INITIALIZED:String = "activityInitialized";
		public static const ACTIVITY_STARTED:String = "activityStarted";
		public static const ACTIVITY_PAUSED:String = "activityPaused";
		public static const ACTIVITY_RESUMED:String = "activityResumed";
		public static const ACTIVITY_COMPLETED:String = "activityCompleted";
		public static const ACTIVITY_DESTROYING:String = "activityDestroying";
		public static const ACTIVITY_DESTROYED:String = "activityDestroyed";
		public static const UPDATE_EVENT:String = "updateEvent";
		public static const VIEW_INITIALIZED:String = "viewInitialized";
		public static const VIEW_EVENT:String = "viewEvent";
		public static const VIEW_DESTROYED:String = "viewDestroyed";
		public static const VIEW_BUTTON_CLICK:String = "viewButtonClick";
		public static const ACTIVITY_REPEATING:String = "activityRepeating";
		public static const ACTIVITY_ADDED_TO_STAGE:String = "activityAddedToStage";
		public static const ACTIVITY_REMOVED_FROM_STAGE:String = "activityRemovedFromStage";
		
		public function ActivityFWEvent( type:String, bubbles:Boolean = true, cancelable:Boolean = true ) {
			super( type, bubbles, cancelable );
		}
		
		public override function clone():Event {
			return new ActivityFWEvent( type, bubbles, cancelable );	
		}
		
		public override function toString():String {
			return formatToString( "ActivityEvent", "type", "bubbles", "cancelable", "eventPhase" );	
		}
		
	}
}
