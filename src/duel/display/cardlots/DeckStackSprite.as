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
		
		public function DeckStackSprite(list:CardListBase) 
		{
			super(list);
		}
		
		override protected function tweenToPlace( o:CardSprite ):void
		{
			const TARGET_Y:Number = y - cardSpacing * ( cardsCount - 1 );
			
			juggler.xtween( o, .150,
				{
					alpha : 1.0,
					x : x,
					y : TARGET_Y,
					scaleX : z,
					scaleY : z,
					rotation : .0,
					transition : Transitions.EASE_OUT
				} );
				
			cardsParent.addChild( o );
		}
		
	}

}