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
		
		private var dispatchCompleteEvent:Boolean;
		
		public function ProcessManager()
		{
			queue = new Vector.<Process>();
		}
		
		public function advanceTime( time:Number ):void 
		{
			if ( isIdle )
			{
				if ( dispatchCompleteEvent )
				{
					//trace( "PM now empty" );
					dispatchEventWith( Event.COMPLETE );
					removeEventListeners( Event.COMPLETE );
					dispatchCompleteEvent = false;
				}
				return;
			}
			
			dispatchCompleteEvent = true;
			
			if ( queue[ 0 ].time < .0 )
				finishCurrentProcess();
			else
				queue[ 0 ].time -= time;
		}
		
		public function finishCurrentProcess():void 
		{
			var p:Process = queue[ 0 ];
			
			removeCurrentProcess();
			
			if ( p.callback != null )
				p.callback.apply( null, p.callbackArgs );
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
		
		public function get isIdle():Boolean { return queue.length == 0 }
		
		// // //
		public static function gen( name:String, callback:Function = null, ...callbackArgs ):Process
		{
			var p:Process = new Process();
			p.uid = ++Process.UID;
			p.name = name;
			p.callback = callback;
			p.callbackArgs = callbackArgs;
			return p;
		}
	}
}

class Process
{
	public static var UID:uint = 0;
	
	public var uid:uint = 0;
	public var time:Number = CONFIG::slowmode?1.999:.100;
	public var name:String = "unnamed";
	public var callback:Function = null;
	public var callbackArgs:Array = null;
	
	public function toString():String 
	{
		return uid + ". " + name + "[" + time.toFixed(2) + "]";
	}
}