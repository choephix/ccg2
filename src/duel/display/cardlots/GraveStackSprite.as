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
		public function GraveStackSprite( list:CardListBase ) { super( list ) }
		
		override protected function tweenToPlace( o:CardSprite ):void
		{
			/* * */
			const TARGET_Y:Number = y - cardSpacing * ( cardsCount - 1 );
			if ( o.alpha < .25 )
			{
				o.x = x;
				o.y = y - 100;
				o.alpha = 0.0;
				o.scaleX = z;
				o.scaleY = z;
				o.tween.to( x, TARGET_Y );
				return;
			}
			/* * */
			
			super.tweenToPlace( o );
		}
	}
}