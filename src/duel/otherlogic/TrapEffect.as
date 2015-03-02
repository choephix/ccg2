package duel.otherlogic 
{
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapEffect
	{
		public var watcherActivate:ProcessWatcher	= new ProcessWatcher();
		public var watcherTriggered:ProcessWatcher	= new ProcessWatcher();
		public var watcherOngoing:ProcessWatcher	= new ProcessWatcher();
		
		/// no args, no return type
		public var funcOnDeactivate:Function		= ProcessWatcher.NOTHING;
		
		public var isBusy:Boolean = false;
		public var isActive:Boolean = false;
	}
}