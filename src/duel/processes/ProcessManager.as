package duel.processes
{
	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/// A process has been removed
	[Event(name = "removed", type = "starling.events.Event")] 
	
	/// A process has been added
	[Event(name = "added", type = "starling.events.Event")] 
	
	///// A process has just started execution
	//[Event(name = "triggered", type = "starling.events.Event")]
	
	/// A process has been aborted
	[Event(name = "cancel", type = "starling.events.Event")]
	
	/// A process has finished successfully
	[Event(name = "complete", type = "starling.events.Event")] 
	
	/**
	 * ...
	 * @author choephix
	 */
	public class ProcessManager extends EventDispatcher implements IAnimatable
	{
		public var queue:Vector.<Process>
		
		public function ProcessManager()
		{
			queue = new Vector.<Process>();
		}
		
		public function advanceTime( time:Number ):void 
		{
			if ( queue.length == 0 )
				return;
			if ( queue[ 0 ].time < .0 )
				finishCurrentProcess();
			else
				queue[ 0 ].time -= time;
		}
		
		public function finishCurrentProcess():void 
		{
			if ( queue[ 0 ].callback != null )
				queue[ 0 ].callback();
			
			dispatchEventWith( Event.COMPLETE, false, queue[ 0 ] );
			removeCurrentProcess();
		}
		
		public function abortCurrentProcess():void 
		{
			dispatchEventWith( Event.CANCEL, false, queue[ 0 ] );
			removeCurrentProcess();
		}
		
		private function removeCurrentProcess():void 
		{
			var p:Process = queue.shift();
			dispatchEventWith( Event.REMOVED, false, p );
		}
		
		public function enqueueProcess( p:Process ):void
		{
			queue.push( p );
			dispatchEventWith( Event.ADDED, false, p );
		}
		
		public function interruptCurrentProcess( p:Process ):void
		{
			queue.unshift( p );
			dispatchEventWith( Event.ADDED, false, p );
		}
		
		// // //
		
		
		
		
		
		
		
		
		
		
		
		
		
		// // //
		public static function gen( name:String, callback:Function = null ):Process
		{
			var p:Process = new Process();
			p.uid = ++Process.UID;
			p.name = name;
			p.callback = callback;
			return p;
		}
	}
}

class Process
{
	public static var UID:uint = 0;
	
	public var uid:uint = 0;
	public var time:Number = .999;
	//public var time:Number = .250;
	public var name:String = "unnamed";
	public var callback:Function = null;
	
	public function toString():String 
	{
		return uid + ". " + name + "[" + time.toFixed(2) + "]";
	}
}