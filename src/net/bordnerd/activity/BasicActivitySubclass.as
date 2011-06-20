package net.bordnerd.activity {

	import net.bordnerd.activity.Activity;
	import flash.text.StyleSheet;
	import net.bordnerd.activity.event.ActivityViewEvent;

	/**
	 * @author michael.bordner
	 */
	public class BasicActivitySubclass extends Activity
	{
		
		
		public function BasicActivitySubclass( xml:XML = null, css:StyleSheet = null, sessionKey:String = null ) {
			super( xml, css, sessionKey );
		}
		
		/**
		 * return session string that will be restored in resumeSession()
		 */
		public override function getSession():String {
			return '';	
		}
		
		
		/**
		 * This method will be called before the view has been loaded, and any xml models have been loaded.
		 * 
		 * After the activity is initialized, it must call this.activityInitialized() 
		 */
		protected override function initializeActivity( xml:XML, session:String = null ):void {			
			this.activityInitialized();	
		}
		
		/**
		 * This method will be called prior to dispatching the event that the activity is initialized,
		 * and can allow the controller to prepare assets for the view, or dispatch events to the view
		 * to prepare assets.  At this point the controller and view are linked for event processing.
		 * 
		 * After the activity is prepared, it must call this.viewAssetsPrepared()
		 */
		protected override function prepareViewAssets():void {
			this.viewAssetsPrepared();			
		}
		
		/**
		 * This event handler is automatically linked by the ActivityLauncher (in the super class).
		 * ActivityViewEvents will be generic events sent by views for the Activity (controller) to process.
		 */
		protected override function handleViewEvent( evt:ActivityViewEvent ):void {
			
		}
		
		/**
		 * This method is called to start the logic of the activity.  When the activity
		 * completes, it must call this.completeActivity()
		 */
		protected override function startActivity():void {
			
		}
		
		/**
		 * if resuming from previous session, this method is called
		 * instead of startActivity. if this would remuse to a completed activity, the subclass must call activityCompleted()
		 * 
		 * it is possible that the activity resumes into paused state
		 */
		protected override function resumeSession( session:String ):void {
			super.resumeSession( session ); // this will call activityCompleted if the previous session state was STATE_COMPLETED or greater, so call this method last after "resuming session"
		}
				
		
		/**
		 * The activity should pause itself.  resumeActivity() will be called when it should
		 * resume.
		 */
		protected override function pauseActivity():void {
			
		}
		
		protected override function resumeActivity():void {
			
		}
		
		/**
		 * Called when the activity is being destroyed, to give a chance to clean up.
		 * After the activity is destroyed, it must call this.activityDestroyed()
		 */
		protected override function destroyActivity():void {
			this.activityDestroyed();
		}
		
		
	}
}
