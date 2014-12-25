package duel {
	import duel.cards.Card;
	import duel.cards.CardType;
	import duel.table.FieldSprite;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Field
	{
		public var container:PlayerSide;
		public var allowedCardType:CardType;
		
		// BATTLE
		public var card:Card;
		
		public var sprite:FieldSprite;
		
		public function Field( container:PlayerSide, color:uint ) 
		{
			this.container = container;
			this.sprite = new FieldSprite( this, color );
		}
	}
}