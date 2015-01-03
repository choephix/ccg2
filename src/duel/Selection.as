package duel
{
	import duel.cards.Card;
	import duel.display.CardAura;
	import starling.display.BlendMode;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Selection extends GameEntity
	{
		public var selectionAura:Quad;
		
		private var _selectedCard:Card;
		
		public function Selection()
		{
			//selectionAura = new CardAura();
			selectionAura = assets.generateImage( "card-selectable", true, true );
			selectionAura.blendMode = BlendMode.ADD;
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
			selectionAura.color = value.type.isCreature ? 0xFFCE5E : 0xCB83FC;
			selectionAura.rotation = value.sprite.isTopSide ? Math.PI : .0;
		}
	}
}