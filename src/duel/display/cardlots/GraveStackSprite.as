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
		
		public function GraveStackSprite(list:CardListBase) 
		{
			super(list);
		}
		
		override protected function animFallingCard(o:CardSprite):void 
		{
			addCardChild( o );
			
			const TARGET_Y:Number = -cardSpacing * ( cardsCount - 1 );
			
			o.visible = true;
			o.scaleX = 1.0;
			o.scaleY = 1.0;
			o.x = 0.0;
			o.y = TARGET_Y;
			o.alpha = 1.0;
			
			_fallingCardTween.reset( o, .550, Transitions.EASE_OUT );
			_fallingCardTween.animate( "alpha", 1.0 );
			_fallingCardTween.animate( "y", TARGET_Y );
			o.alpha = .0;
			//o.y = TARGET_Y - 5;
			o.y = TARGET_Y + cardSpacing;
			o.rotation = MathF.randSign * MathF.random( .025 );
			
			juggler.add( _fallingCardTween );
		}
		
	}
	
}