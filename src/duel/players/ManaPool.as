package duel.players 
{
	import duel.GameEntity;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class ManaPool extends GameEntity 
	{
		private var _capMax:int		= 5;
		private var _capMin:int		= 0;
		private var _current:int	= 4;
		private var _cap:int		= 1;
		
		public function refill():void
		{ _current = _cap }
		
		public function useMana( amount:int=1 ):void
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