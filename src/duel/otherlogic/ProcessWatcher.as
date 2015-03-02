package duel.otherlogic 
{
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author ...
	 */
	public class ProcessWatcher 
	{
		
		/// must accept one arg of type Process and return Boolean
		public var funcCondition:Function 	= TRUTH;
		
		/// must accept one arg of type Process
		public var funcEffect:Function		= NOTHING;
		
		private var _pnList:Vector.<String> = new <String>[];
		private var _pnCount:int = 0;
		private var _pnAny:Boolean = false;
		
		public function watchFor( ...names ):void
		{ 
			_pnCount = _pnList.push.apply( null, names )
		}
		
		public function watchForAny():void
		{ 
			_pnAny = true;
		}
		
		protected function isWatched( p:GameplayProcess ):Boolean
		{
			if ( _pnCount <= 0 )
				return false;
				
			if ( _pnCount == 1 )
				return _pnList[ 0 ] == p.name;
				
			var i:int = _pnCount;
			while ( --i >= 0 ) 
				if ( _pnList[i] == p.name )
					return true;
			
			return false;
		}
		
		public function doesProcessPassCheck( p:GameplayProcess ):Boolean
		{
			if ( _pnAny )
				return true;
			
			if ( !isWatched( p ) )
				return false;
			
			return funcCondition( p );
		}
		
		//
		public static function TRUTH( p:GameplayProcess ):Boolean 
		{ return true }
		public static function FALSEHOOD( p:GameplayProcess ):Boolean 
		{ return false }
		public static function ERROR( p:GameplayProcess ):void
		{ CONFIG::development{ throw new UninitializedError("Undefined Function Called") } }
		public static function NOTHING( p:GameplayProcess ):void
		{}
	}
}