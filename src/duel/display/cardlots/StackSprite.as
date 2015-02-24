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
			var i:int = list.cardsCount;
			var j:int = 0;
			while ( --i >= 0 )
				quickPlaceAt( list.getCardAt( i ).sprite, j++ );
		}
		
		protected function quickPlaceAt( o:CardSprite, bottomUpIndex:int ):void
		{
			const TARGET_Y:Number = y - cardSpacing * bottomUpIndex;
			o.tween.alpha = 1.0;
			o.tween.to( x, TARGET_Y, o.rotation, z ); 
			cardsParent.addChild( o );
		}
		
		override protected function tweenToPlace( o:CardSprite ):void
		{
			const TARGET_Y:Number = y - cardSpacing * ( cardsCount - 1 );
			o.tween.to( x, TARGET_Y, MathF.randSign * MathF.random( .025 ), z ); 
			cardsParent.addChild( o );
		}
	}
}