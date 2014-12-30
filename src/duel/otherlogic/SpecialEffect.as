package duel.otherlogic 
{
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class SpecialEffect 
	{
		public var funcCondition:Function = TRUTH;
		public var funcActivate:Function = ERROR;
		
		private var processNames:Array = [];
		private var _pncount:int = 0;
		
		private var _lastP:GameplayProcess;
		
		public function watch( ...names ):void
		{
			_pncount = processNames.push.apply( null, names );
		}
		
		public function isWatched( p:GameplayProcess ):Boolean
		{
			if ( _pncount <= 0 ) return false;
			if ( _pncount == 1 ) return processNames[0] == p.name;
			var i:int = _pncount;
			while ( --i >= 0 ) 
				if ( processNames[0] == p.name ) return true;
			return false;
		}
		
		public function mustInterrupt( p:GameplayProcess ):Boolean
		{
			if ( _lastP == p ) return false;
			if ( !isWatched( p )  ) return false;
			if ( !meetsCondition( p ) ) return false;
			_lastP = p;
			return true;
		}
		
		public function meetsCondition( p:GameplayProcess ):Boolean
		{
			return funcCondition( p );
		}
		
		public function activateNow( p:GameplayProcess ):void
		{
			CONFIG::development
			{ if ( _pncount == 0 || !isWatched( p ) || !funcCondition( p ) ) throw new Error("Idiot"); }
			 
			funcActivate( p );
		}
		
		//
		private static function TRUTH( p:GameplayProcess ):Boolean 
		{ return true }
		
		private static function ERROR( p:GameplayProcess ):void
		{ CONFIG::development{ throw new UninitializedError("Undefined Function Called") } }
		
	}

}