package duel.gui
{
	import duel.cards.Card;
	import duel.cards.CardList;
	import duel.cards.CardListEvents;
	import duel.G;
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class HandContainer extends GameSprite implements IAnimatable
	{
		public var maxWidth:Number = 500;
		
		private var hand:CardList;
		
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
			
			const D:Number = Math.min( maxWidth / hand.count, G.CARD_W );
			var c:Card;
			for ( var i:int = 0; i < hand.count; i++ )
			{
				c = hand.at( i );
				addChild( c.model );
				
				game.jugglerStrict.removeTweens( c.model );
				game.jugglerStrict.tween( c.model, 0.250, { y: 0, x: i * D } );
			}
		}
		
		public function show( c:Card ):void
		{
			game.jugglerStrict.removeTweens( c );
			game.jugglerStrict.tween( c.model, 0.100, { y: -140 } );
		}
		
		public function unshow( c:Card ):void
		{
			game.jugglerStrict.removeTweens( c );
			game.jugglerStrict.tween( c.model, 0.200, { y: 0 } );
		}
		
	}
}