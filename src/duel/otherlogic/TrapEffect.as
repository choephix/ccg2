package duel.otherlogic 
{
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapEffect
	{
		/// must accept one arg of type Process and return Boolean
		public var funcActivateCondition:Function = TRUTH;
		/// must accept one arg of type Process and return Boolean
		public var funcDeactivateCondition:Function = TRUTH;
		
		/// must accept one arg of type Process
		public var funcActivate:Function	= NOTHING;
		public var funcUpdate:Function		= NOTHING;
		public var funcDeactivate:Function	= NOTHING;
		
		private var _isActive:Boolean = false;
		
		private var _pnlistA:Vector.<String> = new <String>[];
		private var _pncountA:int = 0;
		
		private var _pnlistD:Vector.<String> = new <String>[];
		private var _pncountD:int = 0;
		
		private var _lastP:GameplayProcess;
		
		public function watchForActivation( ...names ):void
		{ _pncountA = _pnlistA.push.apply( null, names ) }
		
		public function watchForDeactivation( ...names ):void
		{ _pncountD = _pnlistD.push.apply( null, names ) }
		
		protected function isWatchedA( p:GameplayProcess ):Boolean
		{
			if ( _pncountA <= 0 )
				return false;
				
			var i:int = _pncountA;
			while ( --i >= 0 ) 
				if ( _pnlistA[i] == p.name )
					return true;
			
			return false;
		}
		
		protected function isWatchedD( p:GameplayProcess ):Boolean
		{
			if ( _pncountD <= 0 )
				return false;
				
			var i:int = _pncountD;
			while ( --i >= 0 ) 
				if ( _pnlistD[i] == p.name )
					return true;
			
			return false;
		}
		
		public function mustInterrupt( p:GameplayProcess ):Boolean
		{
			if ( _lastP == p ) return false;
			
			if ( p.isComplete ) return false;
			
			if ( _isActive )
			{
				if ( !isWatchedD( p )  ) return false;
				if ( !funcDeactivateCondition( p ) ) return false;
			}
			else
			{
				if ( !isWatchedA( p )  ) return false;
				if ( !funcActivateCondition( p ) ) return false;
			}
			
			_lastP = p;
			return true;
		}
		
		public function activate( p:GameplayProcess ):void
		{
			_isActive = true;
			funcActivate( p );
		}
		
		public function update( p:GameplayProcess ):void
		{
			funcUpdate( p );
		}
		
		public function deactivate( p:GameplayProcess ):void
		{
			_isActive = false;
			funcDeactivate( p );
		}
		
		public function get isActive():Boolean 
		{ return _isActive }
		
		public function get isNone():Boolean
		{ return funcUpdate == ERROR }
		
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