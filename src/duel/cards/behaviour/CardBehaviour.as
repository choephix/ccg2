package duel.cards.behaviour 
{
	import duel.cards.Card;
	import duel.otherlogic.SpecialEffect;
	import duel.processes.ProcessWatcher;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardBehaviour 
	{
		public var card:Card;
		
		public var startFaceDown:Boolean = false;
		
		public var graveSpecial:SpecialEffect = new SpecialEffect();
		public var handSpecial:SpecialEffect = new SpecialEffect();
		
		public function get hasGraveSpecial():Boolean 
		{ return graveSpecial != null }
		
		public function get hasHandSpecial():Boolean 
		{ return handSpecial != null }
	}

}