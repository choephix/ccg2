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
			
			p.advanceTimeBefore( time );
			currentProcessEvent.process = p;
			dispatchEvent( currentProcessEvent );
			p.advanceTimeAfter( time );
			
			if ( p.isAborted )
			{
				removeCurrentProcess();
			}
			else
			if ( p.isComplete )
			{
				removeCurrentProcess();
				
				if ( p.next != null )
					queue.unshift( p.next );
				
				if ( p.callback != null )
					p.callback.apply( null, p.callbackArgs );
			}
		}
		
		private function removeCurrentProcess():void 
		{
			queue.shift();
		}
		
		public function appendProcess( p:Process ):void
		{
			queue.push( p );
		}
		
		public function prependProcess( p:Process ):void
		{
			queue.unshift( p );
		}
		
		// // //
		
		public function get isIdle():Boolean { return !running }
		public function get currentProcess():Process { return isIdle ? null : queue[ 0 ] }
		
		public function toString():String { return queue.join("\n"); }
		
		// // //
		public static function gen( name:String, callback:Function = null, ...callbackArgs ):Process
		{
			var p:Process = new Process();
			p.name = name;
			p.callback = callback;
			p.callbackArgs = callbackArgs;
			return p;
		}
	}
}