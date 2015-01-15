package duel.display.cardlots {
	import duel.cards.Card;
	import duel.display.CardSprite;
	import duel.G;
	import duel.GameEvents;
	import duel.table.Hand;
	import starling.animation.Transitions;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class HandSprite extends CardsContainer
	{
		static public const SEL_SPACE:Number = 100;
		
		public var maxWidth:Number = 800;
		public var topSide:Boolean = false;
		
		private var _active:Boolean = true;
		
		private var selectedIndex:int = -1;
		
		private var hand:Hand;
		
		public function HandSprite( hand:Hand )
		{
			this.hand = hand;
			setTargetList( hand );
		}
		
		override protected function arrangeAll():void 
		{
			arrange();
		}
		
		override protected function tweenToPlace( cs:CardSprite ):void 
		{
			arrange();
		}
		
		public function arrange():void
		{
			/** /
			if ( selectedIndex >= 0 )
			{
				const A:Array = [];
				var j:int = 0;
				var m1:int = selectedIndex;
				var m2:int = cardsCount - selectedIndex;
				var n:Number;
				for ( j = 0; j < cardsCount; j++ )
				{
					n = 1.0 - ( Math.abs( j - selectedIndex ) / ( j < selectedIndex ? m1 : m2 ) );
					A.push( n );
				}
				const A_TOTAL:Number = MathF.sum( A );
			}
			/**/
			
			const W:Number = maxWidth - G.CARD_W;
			
			var x:Number = G.CARD_W * .5;
			var y:Number = 0.0;
			
			var o:CardSprite;
			var i:int = list.cardsCount;
			var jj:int = 0;
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				
				x = x + theD( W );
				y = ( topSide ? -1.0 : 1.0 ) * 50;
				if ( _active )
				{
					if ( selectedIndex < 0 )
						y = 0
					else
						y = ( topSide ? -1.0 : 1.0 ) * ( i == selectedIndex ? -75 : 50 )
				}
				jugglerGui.removeTweens( o );
				jugglerGui.tween( o, 0.250, // .850 .250
					{ 
						alpha: 1.0,
						x: this.x + x, 
						y: this.y + y, 
						rotation: topSide ? Math.PI : .0,
						transition: Transitions.EASE_OUT 
						// EASE_OUT EASE_OUT_BACK EASE_OUT_ELASTIC
					} );
				
				if ( topSide )
					o.parent.setChildIndex( o, 0 );
				else
					o.parent.setChildIndex( o, o.parent.numChildren - 1 );
				
				o.touchable = true;
				o.useHandCursor = true;
				
				jj++;
			}
		}
		
		private function theD( W:Number ):Number
		{
			var d:Number;
			
			/** /
			if ( selectedIndex == -1 || selectedIndex == cardsCount - 1 )
			{
				d = Math.min( W / cardsCount, G.CARD_W );
			}
			else
			{
				d = Math.min( i == selectedIndex + 1 ? Number.MAX_VALUE : ( W - SEL_SPACE ) / cardsCount, G.CARD_W );
			}
			/** /
			if ( selectedIndex == -1 )
			{
				d = Math.min( W / hand.count, G.CARD_W );
			}
			else
			{
				d = ( W - SEL_SPACE ) * A[i] / A_TOTAL;
				if ( i == selectedIndex + 1 ) d = SEL_SPACE;
			}
			/** /
			if ( selectedIndex == -1 || selectedIndex == cardsCount - 1 )
			{
				d = Math.min( W / cardsCount, G.CARD_W );
			}
			else
			{
				if ( i <= selectedIndex )
					d = Math.min( W / cardsCount, G.CARD_W );
				else 
				if ( i == selectedIndex + 1 )
					d = G.CARD_W;
				else 
					d = Math.min( W / cardsCount, G.CARD_W );
			}
			/**/
			d = Math.min( ( W - G.CARD_W*.5 ) / cardsCount, G.CARD_W );
			/**/
			
			return d;
		}
		
		// EVENT HANDLERS
		
		override protected function onCardAdded( e:Event ):void 
		{
			super.onCardAdded( e );
		}
		
		override protected function onCardRemoved( e:Event ):void 
		{
			super.onCardRemoved( e );
			var c:Card = e.data as Card;
			jugglerGui.removeTweens( c.sprite );
			selectedIndex = -1;
			
			arrange();
		}
		
		private function onTurnStart(e:Event):void 
		{
			active = game.currentPlayer == hand.owner;
		}
		
		private function onCardSelected(e:Event):void 
		{
			var c:Card = e.data as Card;
			if ( c == null ) return;
			
			if ( hand.containsCard( c ) ) {
				show( c );
			}
		}
		
		private function onCardDeselected(e:Event):void 
		{
			var c:Card = e.data as Card;
			if ( c == null ) return;
			
			if ( hand.containsCard( c ) ) {
				unshow( c );
			}
		}
		
		//
		public function show( c:Card ):void
		{
			selectedIndex = list.indexOfCard( c );
			arrange();
		}
		
		public function unshow( c:Card ):void
		{
			selectedIndex = -1;
			arrange();
		}
		
		//
		public function get active():Boolean 
		{
			return _active;
		}
		
		public function set active(value:Boolean):void 
		{
			_active = value;
			arrange();
		}
	
	}
}