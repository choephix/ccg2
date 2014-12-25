package duel.gui
{
	import chimichanga.global.utils.MathF;
	import duel.cards.Card;
	import duel.cards.CardList;
	import duel.cards.CardListEvents;
	import duel.G;
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class HandContainer extends GameSprite implements IAnimatable
	{
		static public const SEL_SPACE:Number = 100;
		public var maxWidth:Number = 500;
		
		private var hand:CardList;
		
		private var selectedIndex:int = -1;
		
		public function HandContainer( hand:CardList )
		{
			super();
			this.hand = hand;
			
			hand.addEventListener( CardListEvents.CHANGED, arrange );
			
			arrange();
		}
		
		public function advanceTime( time:Number ):void
		{
		}
		
		public function arrange():void
		{
			removeChildren();
			
			if ( selectedIndex >= 0 )
			{
				const A:Array = [];
				var j:int = 0;
				var m1:int = selectedIndex;
				var m2:int = hand.count - selectedIndex;
				var n:Number;
				for ( j = 0; j < hand.count; j++ )
				{
					n = 1.0
					- ( Math.abs( j - selectedIndex ) / ( j < selectedIndex ? m1 : m2 ) );
					A.push( n );
				}
				const A_TOTAL:Number = MathF.sum( A );
			}
			
			const W:Number = maxWidth - G.CARD_W;
			
			var c:Card;
			var d:Number = 0.0;
			var x:Number = G.CARD_W * .5;
			var y:Number = 0.0;
			for ( var i:int = 0; i < hand.count; i++ )
			{
				c = hand.at( i );
				addChild( c.sprite );
				
				/**/
				if ( selectedIndex == -1 || selectedIndex == hand.count-1 ) {
					d = Math.min( W / hand.count, G.CARD_W );
				} else {
					d = Math.min( i == selectedIndex + 1 ? Number.MAX_VALUE : ( W - SEL_SPACE ) / hand.count, G.CARD_W );
				}
				/** /
				if ( selectedIndex == -1 ) {
					d = Math.min( W / hand.count, G.CARD_W );
				} else {
					d = ( W - SEL_SPACE ) * A[i] / A_TOTAL;
					if ( i == selectedIndex + 1 ) d = SEL_SPACE;
				}
				/**/
				
				x = x + d;
				y = i == selectedIndex ? -75 : 0;
				
				game.jugglerStrict.removeTweens( c.sprite );
				game.jugglerStrict.tween( c.sprite, 0.250, // .850 .250
				{
					x: x,
					y: y,
					transition : Transitions.EASE_OUT // EASE_OUT EASE_OUT_BACK EASE_OUT_ELASTIC
				} );
			}
		}
		
		public function show( c:Card ):void
		{
			selectedIndex = hand.indexOf( c );
			arrange()
		}
		
		public function unshow( c:Card ):void
		{
			selectedIndex = -1;
			arrange()
		}
	
	}
}