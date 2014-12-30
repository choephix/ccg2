package duel.processes 
{
	import duel.Game;
	/**
	 * ...
	 * @author choephix
	 */
	public class Process
	{
		private static var UID:uint = 0;
		private var uid:uint = 0;
		
		public var name:String = "unnamed";
		public var callback:Function = null;
		public var callbackArgs:Array = null;
		
		internal var delay:Number = CONFIG::slowmode ? .500 : NaN;
		internal var next:Process = null;
		
		protected var state:ProcessState = ProcessState.WAITING;
		
		public function Process()
		{
			this.uid = ++UID;
		}
		
		internal function advanceTimeBefore( time:Number ):void 
		{
			CONFIG::development { if ( state == ProcessState.WAITING ) log( "started" ) }
			state = ProcessState.ONGOING;
		}
		
		internal function advanceTimeAfter( time:Number ):void 
		{
			if ( state == ProcessState.INTERRUPTED )
				return;
			
			if ( state == ProcessState.ABORTED )
				return;
			
			if ( !isNaN( delay ) && delay > .0 )
			{
				delay -= time;
				return;
			}
				
			state = ProcessState.COMPLETE;
			CONFIG::development{ log( "completed" ) }
		}
		
		public function abort():void
		{
			state = ProcessState.ABORTED
			CONFIG::development{ log( "aborted" ) }
		}
		
		public function interrupt():void
		{
			state = ProcessState.INTERRUPTED
			CONFIG::development{ log( "interrupted" ) }
		}
		
		/// Saves selected process for starting immediately after this one. Returns that same argument. Keep in mind that this process's callback will be called after the chained process has been added to the queue.
		public function chain( p:Process ):*
		{
			return next = p;
		}
		
		//
		public function get isStarted():Boolean { return state != ProcessState.WAITING }
		public function get isComplete():Boolean { return state == ProcessState.COMPLETE }
		public function get isAborted():Boolean { return state == ProcessState.ABORTED }
		public function get isInterrupted():Boolean { return state == ProcessState.INTERRUPTED }
		
		//
		public function toString():String { 
			return uid + ". " + name + 
			( isNaN( delay ) ? "" : 
			"[" + delay.toFixed(2) + "]" ) }
		
		CONFIG::development
		private function log( msg:String ):void {
			//return;
			trace ( "4:" + Game.frameNum + ". " + name+" -:> " + msg )
		}
	}
}

class ProcessState
{
	public static const WAITING:ProcessState = new ProcessState();
	public static const ONGOING:ProcessState = new ProcessState();
	public static const COMPLETE:ProcessState = new ProcessState();
	public static const ABORTED:ProcessState = new ProcessState();
	public static const INTERRUPTED:ProcessState = new ProcessState();
}


