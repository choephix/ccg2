package duel.display.cardlots {
	import chimichanga.global.utils.MathF;
	import duel.GameEvents;
	import duel.table.Hand;
	import duel.cards.Card;
	import duel.G;
	import starling.events.Event;
	import starling.animation.Transitions;
	import starling.display.DisplayObject;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class HandSprite extends CardsContainer
	{
		static public const SEL_SPACE:Number = 100;
		
		public var maxWidth:Number = 500;
		public var flipped:Boolean = false;
		
		private var _active:Boolean = true;
		
		private var selectedIndex:int = -1;
		
		private var hand:Hand;
		
		public function HandSprite( hand:Hand )
		{
			this.hand = hand;
			setTargetList( hand );
			
			game.addEventListener( GameEvents.TURN_START, onTurnStart );
			game.addEventListener( GameEvents.SELECT, onCardSelected );
			game.addEventListener( GameEvents.DESELECT, onCardDeselected );
			//game.addEventListener( GameEvents.HOVER, onCardSelected );
			//game.addEventListener( GameEvents.UNHOVER, onCardDeselected );
		}
		
		override public function arrange():void
		{
			removeChildren();
			
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
			
			const W:Number = maxWidth - G.CARD_W;
			
			var c:Card;
			var x:Number = G.CARD_W * .5;
			var y:Number = 0.0;
			
			//var o:DisplayObject;
			//var i:int = list.cardsCount;
			//var j:int = 0;
			//while ( --i >= 0 )
			//{
				//o = list.getCardAt( i ).sprite;
				//o.x = 0;
				//o.y = -cardSpacing * j;
				//super.addChild( o );
				//j++;
			//}
			
			for ( var i:int = 0; i < cardsCount; i++ )
			{
				c = list.getCardAt( i );
				super.addChild( c.sprite );
				
				x = x + theD( W );
				y = ( flipped ? -1.0 : 1.0 ) * 50;
				if ( _active )
				{
					if ( selectedIndex < 0 )
						y = 0
					else
						y = ( flipped ? -1.0 : 1.0 ) * ( i == selectedIndex ? -75 : 50 )
				}
					
				
				jugglerStrict.removeTweens( c.sprite );
				jugglerStrict.tween( c.sprite, 0.250, // .850 .250
					{ 
						alpha: 1.0,
						x: x, y: y, 
						transition: Transitions.EASE_OUT // EASE_OUT EASE_OUT_BACK EASE_OUT_ELASTIC
					} );
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
			d = Math.min( W / cardsCount, G.CARD_W );
			/**/
			
			return d;
		}
		
		// EVENT HANDLERS
		
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
			dirty = true;
		}
		
		public function unshow( c:Card ):void
		{
			selectedIndex = -1;
			dirty = true;
		}
		
		// ERRORS
		override public function addChild( child:DisplayObject ):DisplayObject 
		{
			throw new Error( "NEVER USE ADDCHILD ON STACK" );
		}
		
		//
		public function get cardsCount():int { return list.cardsCount }
		
		//
		public function get active():Boolean 
		{
			return _active;
		}
		
		public function set active(value:Boolean):void 
		{
			_active = value;
			dirty = true;
		}
	
	}
}