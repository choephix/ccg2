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
		
		public function get startFaceDown():Boolean 
		{ throw new AbstractMethodError(); }
	}
}