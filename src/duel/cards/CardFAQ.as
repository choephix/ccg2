package duel.cards 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class CardFAQ 
	{
		private var me:Card;
		public function CardFAQ( me:Card ) { this.me = me }
		
		public function isFriendly( c:Card ):Boolean { return c.controller == me.controller }
		public function isEnemy( c:Card ):Boolean { return c.controller == me.controller.opponent }
		public function isOpposingCreature( c:Card ):Boolean { return c == me.indexedField.opposingCreature }
		
		public function amInPlay():Boolean { return me.isInPlay }
		public function amGraveTopCard():Boolean { return me.controller.grave.topCard == me }
	}

}