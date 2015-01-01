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
		public var abortable:Boolean = true;
		
		public var onStart:Function = null;
		public var onEnd:Function = null;
		public var onAbort:Function = null;
		public var abortCheck:Function = null;
		public var args:Array = null;
		
		internal var delay:Number = CONFIG::slowmode ? .500 : NaN;
		internal var next:Process = null;
		
		protected var state:ProcessState = ProcessState.WAITING;
		
		public function Process()
		{
			this.uid = ++UID;
		}
		
		internal function start():void 
		{
			CONFIG::development { if ( state == ProcessState.WAITING ) log( "started" ) }
			state = ProcessState.ONGOING;
				
			if ( onStart != null )
				onStart.apply( null, args );
		}
		
		internal function end():void
		{
			if ( onEnd != null )
				onEnd.apply( null, args );
		}
		
		internal function preAdvanceTime( time:Number ):void 
		{
			if ( state == ProcessState.INTERRUPTED )
				state = ProcessState.ONGOING;
		}
		
		internal function advanceTime( time:Number ):void 
		{
			if ( abortCheck != null )
				if ( abortCheck.apply( null, args ) )
					abort();
			
			if ( state == ProcessState.ABORTED )
			{
				if ( onAbort != null )
					onAbort.apply( null, args );
				return;
			}
			
			if ( state == ProcessState.INTERRUPTED )
				return;
			
			if ( !isNaN( delay ) && delay > .0 )
			{
				delay -= time;
				return;
			}
				
			state = ProcessState.COMPLETE;
			
			CONFIG::development
			{ log( "completed" ) }
		}
		
		public function abort():void
		{
			if ( abortable )
			{
				CONFIG::development
				{ throw new Error( "CANNOT ABORT THIS PROCESS!" ) }
				return;
			}
			state = ProcessState.ABORTED
			
			CONFIG::development
			{ log( "aborted" ) }
		}
		
		public function interrupt():void
		{
			state = ProcessState.INTERRUPTED
			
			CONFIG::development
			{ log( "interrupted" ) }
		}
		
		/** Saves selected process for starting immediately after this one. 
		 *  Returns the new end of the chain (which will be either the argument process, or if it has others chained, the tail of that chain)
		 *  NOTE: Keep in mind that this process's callback will be called after the chained process has been added to the queue. **/
		public function chain( p:Process ):*
		{
			next = p;
			while ( p.next != null ) 
				p = p.next;
			return p;
		}
		
		//
		public function get isStarted():Boolean { return state != ProcessState.WAITING }
		public function get isComplete():Boolean { return state == ProcessState.COMPLETE }
		public function get isAborted():Boolean { return state == ProcessState.ABORTED }
		public function get isInterrupted():Boolean { return state == ProcessState.INTERRUPTED || state == ProcessState.ABORTED }
		
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


