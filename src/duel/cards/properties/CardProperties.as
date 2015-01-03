package duel.cards.properties {
	import duel.cards.Card;
	import duel.otherlogic.SpecialEffect;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardProperties 
	{
		public var card:Card;
		
		public var startFaceDown:Boolean = false;
		
		public var graveSpecial:SpecialEffect = new SpecialEffect();
		public var handSpecial:SpecialEffect = new SpecialEffect();
		
		public function get hasGraveSpecial():Boolean 
		{ return graveSpecial != null && !graveSpecial.isNone }
		
		public function get hasHandSpecial():Boolean 
		{ return handSpecial != null && !handSpecial.isNone  }
	}

}