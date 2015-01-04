package duel.processes
{
	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class ProcessManager extends EventDispatcher implements IAnimatable
	{
		public var queue:Vector.<Process>;
		
		private var currentProcessEvent:ProcessEvent;
		
		private var running:Boolean;
		
		public function ProcessManager()
		{
			queue = new Vector.<Process>();
			currentProcessEvent = new ProcessEvent( ProcessEvent.CURRENT_PROCESS );
		}
		
		public function advanceTime( time:Number ):void 
		{
			if ( queue.length == 0 )
			{
				if ( running )
				{
					dispatchEventWith( Event.COMPLETE );
					removeEventListeners( Event.COMPLETE );
					running = false;
				}
				return;
			}
			
			running = true;
			
			var p:Process = queue[ 0 ];
			
			if ( !p.isStarted )
			{
				p.start();
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
			//if ( queue.length > 0 )
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