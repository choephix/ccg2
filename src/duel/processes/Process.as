package duel.processes 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class Process
	{
		private static var UID:uint = 0;
		private var uid:uint = 0;
		
		public var time:Number = CONFIG::slowmode?.888:.033;
		public var name:String = "unnamed";
		public var callback:Function = null;
		public var callbackArgs:Array = null;
		
		internal var isComplete:Boolean = false;
		internal var aborted:Boolean = false;
		
		public function Process()
		{
			this.uid = ++UID;
		}
		
		public function toString():String 
		{
			return uid + ". " + name + "[" + time.toFixed(2) + "]";
		}
		
		public function advanceTime( time:Number ):void 
		{
			this.time -= time;
			
			isComplete = this.time < .0;
		}
		
		public function abort():void
		{
			aborted = true;
		}
	}
}