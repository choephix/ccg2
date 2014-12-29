package duel.display.cardlots {
	import duel.cards.Card;
	import duel.cards.CardListBase;
	import duel.display.CardSprite;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardsStackSprite extends CardsContainer
	{
		public var cardSpacing:Number = 10;
		
		private var _fallingCardTween:Tween;
		
		public function CardsStackSprite( list:CardListBase )
		{
			if ( list == null )
				throw new ArgumentError( "Why is list NULL, bitch? WHY?" );
			
			setTargetList( list );
			juggler.add( this );
			
			_fallingCardTween = new Tween( null, .0 );
		}
		
		override public function arrange():void 
		{
			super.arrange();
		}
		
		public function quickArrange():void 
		{
			removeChildren();
			
			var o:CardSprite;
			var i:int = list.cardsCount;
			var j:int = 0;
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				o.alpha = 1.0;
				o.x = 0;
				o.y = -cardSpacing * j;
				addCardChild( o );
				j++;
			}
		}
		
		override protected function onCardAdded( e:Event ):void 
		{
			if ( !_fallingCardTween.isComplete )
				_fallingCardTween.advanceTime( Number.MAX_VALUE );
			
			if ( list.indexOfCard( e.data as Card ) != 0 )
				quickArrange();
			else
			{
				animFallingCard( e.data.sprite as CardSprite );
			}
		}
		
		private function animFallingCard( o:CardSprite ):void
		{
			addCardChild( o );
			
			const TARGET_Y:Number = -cardSpacing * ( cardsCount - 1 );
			
			o.visible = true;
			o.scaleX = 1.0;
			o.scaleY = 1.0;
			o.x = 0.0;
			o.y = TARGET_Y;
			o.alpha = 1.0;
			
			/** /
				_fallingCardTween.reset( o, .250, Transitions.EASE_OUT ); // EASE_OUT EASE_IN
				_fallingCardTween.animate( "y", TARGET_Y );
				o.y = TARGET_Y - 40;
			/** /
				_fallingCardTween.reset( o, .660, Transitions.EASE_OUT_BOUNCE );
				_fallingCardTween.animate( "y", TARGET_Y );
				o.y = TARGET_Y - 40;
			/**/
				_fallingCardTween.reset( o, .880, Transitions.EASE_OUT_BOUNCE );
				_fallingCardTween.animate( "scaleX", 1.0 );
				_fallingCardTween.animate( "scaleY", 1.0 );
				o.scaleX = 1.4;
				o.scaleY = 1.4;
			/**/
			
			jugglerStrict.add( _fallingCardTween );
		}
		
		override protected function onCardRemoved( e:Event ):void 
		{
			if ( !_fallingCardTween.isComplete )
				_fallingCardTween.advanceTime( Number.MAX_VALUE );
			
			quickArrange();
		}
		
		override protected function onCardsReordered(e:Event):void 
		{
			if ( !_fallingCardTween.isComplete )
				_fallingCardTween.advanceTime( Number.MAX_VALUE );
			
			quickArrange();
		}
		
		public function animBunch():void
		{
			var o:DisplayObject;
			for ( var i:int = 0, iMax:int = numChildren; i < iMax; i++ ) 
			{
				o = getChildAt( i );
				o.x = .0;
				o.y = -50 * ( i + 1 );
				o.rotation = Math.random() * 0.2 - 0.1;
				jugglerStrict.xtween( o, 0.8, { 
					x: .0,
					y: -cardSpacing * i,
					//rotation: 0.0,
					rotation: Math.random() * 0.2 - 0.1,
					transition: Transitions.EASE_OUT_BOUNCE
				} );
			}
		}
		
	}

}