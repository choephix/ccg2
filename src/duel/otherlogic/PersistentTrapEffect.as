package duel.otherlogic 
{
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class PersistentTrapEffect 
	{
		/// must accept one arg of type Process and return Boolean
		public var funcDeactivateCondition:Function = FALSEHOOD;
		
		/// must accept one arg of type Process
		public var funcActivate:Function	= NOTHING;
		public var funcUpdate:Function		= NOTHING;
		public var funcDeactivate:Function	= NOTHING;
		
		private var _isActive:Boolean = false;
		
		private var _lastP:GameplayProcess;
		
		public function start( p:GameplayProcess ):void
		{
			_isActive = true;
			funcActivate( p );
		}
		
		public function update( p:GameplayProcess ):void
		{
			if ( _lastP == p )
				return;
			_lastP = p;
			funcUpdate( p );
		}
		
		public function end( p:GameplayProcess ):void
		{
			_isActive = false;
			funcDeactivate( p );
		}
		
		public function mustEnd( p:GameplayProcess ):Boolean
		{
			return funcDeactivateCondition( p );
		}
		
		public function get isActive():Boolean 
		{ return _isActive }
		
		public function get isNone():Boolean
		{ return funcUpdate == ERROR }
		
		//
		private static function FALSEHOOD( p:GameplayProcess ):Boolean 
		{ return false }
		private static function ERROR( p:GameplayProcess ):void
		{ CONFIG::development{ throw new UninitializedError("Undefined Function Called") } }
		private static function NOTHING( p:GameplayProcess ):void
		{}
		
	}

}