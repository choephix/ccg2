package duel.display.cardlots
{
	import chimichanga.global.utils.MathF;
	import duel.cards.Card;
	import duel.cards.CardListBase;
	import duel.display.CardSprite;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class StackSprite extends CardsContainer
	{
		public var cardSpacing:Number = 10;
		
		public function StackSprite( list:CardListBase )
		{
			if ( list == null )
				throw new ArgumentError( "Why is list NULL, bitch? WHY?" );
			
			setTargetList( list );
			juggler.add( this );
		}
		
		override protected function arrangeAll():void
		{
			var o:CardSprite;
			var i:int = list.cardsCount;
			var j:int = 0;
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				o.alpha = 1.0;
				o.x = x;
				o.y = y - cardSpacing * j;
				cardsParent.addChild( o );
			
				o.touchable = false;
				o.useHandCursor = false;
				j++;
			}
		}
		
		override protected function tweenToPlace( o:CardSprite ):void
		{
			const TARGET_Y:Number = y - cardSpacing * ( cardsCount - 1 );
			
			juggler.xtween( o, .150,
				{
					alpha : 1.0,
					x : x,
					y : TARGET_Y,
					scaleX : 1.0,
					scaleY : 1.0,
					rotation : MathF.randSign * MathF.random( .025 ),
					transition : Transitions.EASE_OUT
				} );
				
			cardsParent.addChild( o );
			
			o.touchable = false;
			o.useHandCursor = false;
		}
		
	}
	
}