package net.bordnerd.activity {
	import net.bordnerd.activity.ActivityView;
	import net.bordnerd.activity.event.UpdateEvent;
	
	/**
	 * @author michael.bordner
	 */
	public class BasicActivityViewSubclass extends ActivityView 
	{
		public function BasicActivityViewSubclass() {
			super( );
		}
		
		public override function update( evt:UpdateEvent ):void {
		
		}

		public override function destroy():void {
			this.setDestroyed();
		}
		
		protected override function configureView():void {
			this.setInitialized(); 
		}
		
	}
}
