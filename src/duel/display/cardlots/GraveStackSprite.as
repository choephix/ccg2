package duel.display.cardlots
{
	import chimichanga.global.utils.MathF;
	import duel.cards.CardListBase;
	import duel.display.CardSprite;
	import starling.animation.Transitions;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class GraveStackSprite extends StackSprite
	{
		
		public function GraveStackSprite( list:CardListBase )
		{
			super( list );
		}
		
		override protected function tweenToPlace( o:CardSprite ):void
		{
			const TARGET_Y:Number = y - cardSpacing * ( cardsCount - 1 );
			
			/* * */
			if ( o.alpha < .5 )
			{
				quickPlaceAt( o, cardsCount - 1 );
				o.alpha = .0;
				o.y += cardSpacing;
				juggler.xtween( o, .550,
					{
						delay : 0.550,
						alpha : 1.0,
						y : TARGET_Y,
						transition : Transitions.EASE_OUT
					} );
				return;
			}
			/* * */
			
			super.tweenToPlace( o );
		}
		
	}

}