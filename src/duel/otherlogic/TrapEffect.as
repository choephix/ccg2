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
		//public var watcherDeactivate:ProcessWatcher	= new ProcessWatcher();
		public var watcherUpdate:ProcessWatcher		= new ProcessWatcher();
		
		/// must accept one arg of type Process
		public var funcOnLeavePlay:Function			= NOTHING;
		
		// . . . 
		
		public var isBusy:Boolean = false;
		public var isActive:Boolean = false;
		
		private var _lastP:GameplayProcess;
		
		// 
		
		public function mustActivate( p:GameplayProcess ):Boolean
		{
			if ( isActive ) return false;
			if ( isBusy ) return false;
			if ( _lastP == p ) return false;
			if ( p.isComplete ) return false;
			
			return watcherActivate.doesProcessPassCheck( p );
			
			_lastP = p;
			
			return true;
		}
		
		public function mustDeactivate( p:GameplayProcess ):Boolean
		{
			if ( !isActive ) return false;
			if ( isBusy ) return false;
			if ( _lastP == p ) return false;
			if ( p.isComplete ) return false;
			
			return watcherDeactivate.doesProcessPassCheck( p );
			
			_lastP = p;
			
			return true;
		}
		
		public function onActivate( p:GameplayProcess ):void
		{
			watcherActivate.funcEffect( p );
		}
		
		public function onUpdate( p:GameplayProcess ):void
		{
			if ( isBusy ) return;
			if ( watcherUpdate.doesProcessPassCheck( p ) )
				watcherUpdate.funcEffect( p );
		}
		
		public function onDeactivate( p:GameplayProcess ):void
		{
			watcherDeactivate.funcEffect( p );
		}
		
		public function onLeavePlay( p:GameplayProcess ):void
		{
			funcOnLeavePlay( p );
		}
		
		//
		private static function TRUTH( p:GameplayProcess ):Boolean 
		{ return true }
		private static function FALSEHOOD( p:GameplayProcess ):Boolean 
		{ return false }
		private static function ERROR( p:GameplayProcess ):void
		{ CONFIG::development{ throw new UninitializedError("Undefined Function Called") } }
		private static function NOTHING( p:GameplayProcess ):void
		{}
	}
}