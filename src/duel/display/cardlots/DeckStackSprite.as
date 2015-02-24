package duel.display.cardlots
{
	import duel.cards.CardListBase;
	import duel.display.CardSprite;
	import starling.animation.Transitions;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class DeckStackSprite extends StackSprite
	{
		public function DeckStackSprite( list:CardListBase ) { super( list ) }
		
		override protected function tweenToPlace( o:CardSprite ):void
		{
			const TARGET_Y:Number = y - cardSpacing * ( cardsCount - 1 );
			o.tween.to( x, TARGET_Y, .0, z );
			cardsParent.addChild( o );
		}
	}
}