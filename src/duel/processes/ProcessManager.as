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
		
		private var processEvent:ProcessEvent;
		
		private var running:Boolean;
		
		public function ProcessManager()
		{
			queue = new Vector.<Process>();
			processEvent = new ProcessEvent( ProcessEvent.PROCESS );
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
			
			var currentProcess:Process = queue[ 0 ];
			
			if ( currentProcess.isComplete )
			{
				removeCurrentProcess();
				
				if ( currentProcess.callback != null )
					currentProcess.callback.apply( null, currentProcess.callbackArgs );
				
				return;
			}
			
			currentProcess.advanceTime( time );
			processEvent.process = currentProcess;
			dispatchEvent( processEvent );
		}
		
		public function abortCurrentProcess():void 
		{
			removeCurrentProcess();
		}
		
		private function removeCurrentProcess():void 
		{
			queue.shift();
		}
		
		public function enqueueProcess( p:Process ):void
		{
			queue.push( p );
		}
		
		public function interruptCurrentProcess( p:Process ):void
		{
			queue.unshift( p );
		}
		
		// // //
		
		public function get isIdle():Boolean { return !running }
		
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