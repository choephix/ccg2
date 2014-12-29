package duel.cards.behaviour 
{
	import duel.cards.Card;
	import duel.processes.ProcessWatcher;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardBehaviour 
	{
		public var card:Card;
		
		public var startFaceDown:Boolean = false;
		public var processCheckInGrave:Boolean = false;
		public var processCheckInHand:Boolean = false;
		
		public var graveSpecialConditionFunc:Function;
		public var graveSpecialActivateFunc:Function;
		
		public var handSpecialConditionFunc:Function;
		public var handSpecialActivateFunc:Function;
		
		public function get hasGraveSpecial():Boolean 
		{ return graveSpecialActivateFunc != null }
		
		public function get hasHandSpecial():Boolean 
		{ return handSpecialActivateFunc != null }
	}

}