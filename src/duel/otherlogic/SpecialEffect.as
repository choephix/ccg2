package duel.otherlogic 
{
	import duel.cards.Card;
	import duel.processes.GameplayProcess;
	import duel.table.CardLotType;
	
	public class SpecialEffect 
	{
		/// must accept one arg of type Process and return Boolean
		public var funcCondition:Function = TRUTH;
		/// must accept one arg of type Process
		public var funcActivate:Function = ERROR;
		
		public var allowEverywhere:Boolean = false;
		
		private var _isInProgress:Boolean;
		
		private var _ftypes:Vector.<CardLotType> = new <CardLotType>[];
		private var _ftcount:int = 0;
		
		private var _pnames:Vector.<String> = new <String>[];
		private var _pncount:int = 0;
		private var _pany:Boolean = false;
		
		private var _lastP:GameplayProcess;
		
		public function watch( ...names ):void
		{
			_pncount = _pnames.push.apply( null, names );
		}
		
		public function watchAll():void
		{
			_pany = true;
		}
		
		public function allowIn( ...cardLotTypes ):void
		{
			_ftcount = _ftypes.push.apply( null, cardLotTypes );
		}
		
		public function isAllowedInField( fieldType:CardLotType ):Boolean
		{
			if ( allowEverywhere ) return true;
			if ( _ftcount <= 0 ) return false;
			if ( _ftcount == 1 ) return _ftypes[0] == fieldType;
			var i:int = _ftcount;
			while ( --i >= 0 ) 
				if ( _ftypes[i] == fieldType ) return true;
			return false;
		}
		
		protected function isWatched( p:GameplayProcess ):Boolean
		{
			if ( _pncount <= 0 ) return _pany;
			if ( _pncount == 1 ) return _pnames[0] == p.name;
			var i:int = _pncount;
			while ( --i >= 0 ) 
				if ( _pnames[i] == p.name ) return true;
			return false;
		}
		
		public function mustInterrupt( p:GameplayProcess ):Boolean
		{
			if ( _isInProgress ) return false;
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
		
		public function performEffect( p:GameplayProcess ):void
		{
			CONFIG::development
			{ if ( !isWatched( p ) || !funcCondition( p ) ) throw new Error("Idiot"); }
			
			funcActivate( p );
		}
		
		public function startActivation():void 
		{ _isInProgress = true }
		
		public function finishActivation( c:Card ):void
		{ _isInProgress = false }
		
		public function get isNone():Boolean
		{ return _pncount == 0 }
		
		//
		private static function TRUTH( p:GameplayProcess ):Boolean 
		{ return true }
		
		private static function ERROR( p:GameplayProcess ):void
		{ CONFIG::development{ throw new UninitializedError("Undefined Function Called") } }
		
	}

}