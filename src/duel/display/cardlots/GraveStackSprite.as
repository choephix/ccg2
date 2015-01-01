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
			
			//o.visible = true;
			//o.scaleX = 1.0;
			//o.scaleY = 1.0;
			//o.y = TARGET_Y + cardSpacing;
			//o.alpha = .0;
			
			juggler.xtween( o, .250,
				{ 
					alpha: 1.0,
					x: x, 
					y: TARGET_Y, 
					scaleX: 1.0, 
					scaleY: 1.0, 
					rotation: MathF.randSign * MathF.random( .025 ), 
					transition: Transitions.EASE_OUT
				} );
				
			cardsParent.addChild( o );
		}
		
	}

}