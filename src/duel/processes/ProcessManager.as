package duel.processes
{
	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/// When all proceses in queue are completed
	[Event( name = "complete", type = "starling.events.Event" )]
	/// When a process has completed
	[Event( name = "processComplete", type = "duel.processes.ProcessEvent" )]
	/// When a process has progressed
	[Event( name="process",type="duel.processes.ProcessEvent" )]
	/**
	 * ...
	 * @author choephix
	 */
	public class ProcessManager extends EventDispatcher implements IAnimatable
	{
		public var queue:Vector.<Process>;
		
		private var currentProcessEvent:ProcessEvent;
		private var processCompleteEvent:ProcessEvent;
		
		private var running:Boolean;
		
		public function ProcessManager()
		{
			queue = new Vector.<Process>();
			currentProcessEvent = new ProcessEvent( ProcessEvent.CURRENT_PROCESS );
			processCompleteEvent = new ProcessEvent( ProcessEvent.PROCESS_COMPLETE );
		}
		
		public function advanceTime( time:Number ):void 
		{
			if ( queue.length == 0 )
			{
				if ( running )
				{
					dispatchEventWith( Event.COMPLETE );
					running = false;
				}
				return;
			}
			
			running = true;
			
			var p:Process = queue[ 0 ];
			
			if ( !p.isStarted )
			{
				if ( isNaN( p.delay ) || p.delay <= 0 )
					p.start();
				else
					p.delay -= time;
				return;
			}
			
			p.preAdvanceTime( time );
			currentProcessEvent.process = p;
			dispatchEvent( currentProcessEvent );
			p.advanceTime( time );
			
			if ( p.isAborted )
			{
				removeProcess( p );
			}
			else
			if ( p.isComplete )
			{
				removeProcess( p );
				
				if ( p.next != null )
					queue.unshift( p.next );
				
				p.end();
				processCompleteEvent.process = p;
				dispatchEvent( processCompleteEvent );
			}
		}
		
		private function removeProcess( p:Process ):void 
		{
			queue.splice( queue.indexOf( p ), 1 );
		}
		
		public function appendProcess( p:Process ):void
		{
			queue.push( p );
		}
		
		public function prependProcess( p:Process ):void
		{
			//if ( queue.length > 0 ) //TODO why the fuck did I comment this out?
				//queue[ 0 ].interrupt();
			queue.unshift( p );
		}
		
		// // //
		
		public function get isIdle():Boolean { return !running }
		public function get currentProcess():Process { return isIdle ? null : queue[ 0 ] }
		
		public function toString():String { return queue.join("\n"); }
		
		// // //
		public static function gen( name:String, onEnd:Function = null, ...args ):Process
		{
			var p:Process = new Process();
			p.name = name;
			p.onEnd = onEnd;
			p.args = args;
			return p;
		}
	}
}