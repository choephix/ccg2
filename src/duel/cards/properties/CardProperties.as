package duel.cards.properties {
	import duel.cards.Card;
	import duel.otherlogic.SpecialEffect;
	import starling.errors.AbstractMethodError;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardProperties 
	{
		public var card:Card;
		
		public var graveSpecial:SpecialEffect = new SpecialEffect();
		public var handSpecial:SpecialEffect = new SpecialEffect();
		
		public function get hasGraveSpecial():Boolean 
		{ return graveSpecial != null && !graveSpecial.isNone }
		
		public function get hasHandSpecial():Boolean 
		{ return handSpecial != null && !handSpecial.isNone  }
		
		public function get startFaceDown():Boolean 
		{ throw new AbstractMethodError(); }
	}
}