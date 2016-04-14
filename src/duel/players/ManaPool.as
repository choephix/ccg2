package duel.players 
{
	import duel.G;
	import duel.GameEntity;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class ManaPool extends GameEntity 
	{
		private var _capMax:int		= G.MAX_MANA;
		private var _capMin:int		= 0;
		private var _cap:int		= G.INIT_MANA;
		private var _current:int	= _cap;
		
		public function increase( amount:int ):void
		{ _current = Math.min( _cap, _current + amount ) }
		
		public function refill():void
		{ _current = _cap }
		
		public function decrease( amount:int = 1 ):void
		{ _current -= amount }
		
		public function raiseCap():void
		{ _cap ++; if ( _cap > _capMax ) _cap = _capMax; }
		
		public function decreaseCap():void
		{ _cap --; if ( _cap < _capMin ) _cap = _capMin; }
		
		public function get currentCap():int 
		{ return _cap }
		
		public function get current():int 
		{ return _current }
	}
}