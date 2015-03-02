package duel.otherlogic 
{
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapEffect
	{
		public var watcherActivate:ProcessWatcher;
		public var watcherTriggered:ProcessWatcher;
		public var watcherOngoing:ProcessWatcher;
		public var watcherDeactivate:ProcessWatcher;
		
		public var isBusy:Boolean = false;
		public var isActive:Boolean = false;
		public var lastInterruptedProcess:GameplayProcess = null;
		
		public function TrapEffect( persistent:Boolean ) 
		{
			watcherActivate = new ProcessWatcher();
			if ( persistent )
			{
				watcherTriggered = new ProcessWatcher();
				watcherOngoing = new ProcessWatcher();
				watcherDeactivate = new ProcessWatcher();
			}
		}
	}
}