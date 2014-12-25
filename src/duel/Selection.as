package duel
{
	import duel.cards.Card;
	import duel.gui.CardAura;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Selection
	{
		public var selectionAura:CardAura;
		
		private var _selectedCard:Card;
		
		public function Selection()
		{
			selectionAura = new CardAura();
		}
		
		public function get selectedCard():Card 
		{
			return _selectedCard;
		}
		
		public function set selectedCard(value:Card):void 
		{
			_selectedCard = value;
			
			if ( _selectedCard == null ) {
				selectionAura.removeFromParent( false );
				return;
			}
			
			_selectedCard.sprite.auraContainer.addChild( selectionAura );
			selectionAura.color = 0xCCFF00;
		}
	}
}