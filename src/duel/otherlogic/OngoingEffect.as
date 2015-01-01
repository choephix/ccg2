package duel.otherlogic 
{
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class OngoingEffect 
	{
		/// must accept one arg of type Process and return Boolean
		public var funcCondition:Function = TRUTH;
		/// must accept one arg of type Process
		public var funcUpdate:Function = ERROR;
		
		private var _lastP:GameplayProcess;
		
		public function meetsCondition( p:GameplayProcess ):Boolean
		{
			return funcCondition( p );
		}
		
		public function update( p:GameplayProcess ):void
		{
			if ( !funcCondition( p ) ) true;
			funcUpdate( p );
		}
		
		public function get isNone():Boolean
		{ return funcUpdate == ERROR }
		
		//
		private static function TRUTH( p:GameplayProcess ):Boolean 
		{ return true }
		private static function ERROR( p:GameplayProcess ):void
		{ CONFIG::development{ throw new UninitializedError("Undefined Function Called") } }
		
	}

}