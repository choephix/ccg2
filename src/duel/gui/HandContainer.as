package duel.gui
{
	import chimichanga.global.utils.MathF;
	import duel.cards.Card;
	import duel.cards.CardList;
	import duel.cards.visual.CardsContainerBase;
	import duel.G;
	import starling.animation.Transitions;
	import starling.display.DisplayObject;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class HandContainer extends CardsContainerBase
	{
		static public const SEL_SPACE:Number = 100;
		
		public var maxWidth:Number = 500;
		
		private var selectedIndex:int = -1;
		
		public function HandContainer( list:CardList )
		{
			setTargetList( list );
		}
		
		override public function arrange():void
		{
			removeChildren();
			
			if ( selectedIndex >= 0 )
			{
				const A:Array = [];
				var j:int = 0;
				var m1:int = selectedIndex;
				var m2:int = list.count - selectedIndex;
				var n:Number;
				for ( j = 0; j < list.count; j++ )
				{
					n = 1.0 - ( Math.abs( j - selectedIndex ) / ( j < selectedIndex ? m1 : m2 ) );
					A.push( n );
				}
				const A_TOTAL:Number = MathF.sum( A );
			}
			
			const W:Number = maxWidth - G.CARD_W;
			
			var c:Card;
			var d:Number = 0.0;
			var x:Number = G.CARD_W * .5;
			var y:Number = 0.0;
			for ( var i:int = 0; i < list.count; i++ )
			{
				c = list.at( i );
				super.addChild( c.sprite );
				
				/**/
				if ( selectedIndex == -1 || selectedIndex == list.count - 1 )
				{
					d = Math.min( W / list.count, G.CARD_W );
				}
				else
				{
					d = Math.min( i == selectedIndex + 1 ? Number.MAX_VALUE : ( W - SEL_SPACE ) / list.count, G.CARD_W );
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
				game.jugglerStrict.tween( c.sprite, 0.150, // .850 .250
					{ x: x, y: y, transition: Transitions.EASE_OUT // EASE_OUT EASE_OUT_BACK EASE_OUT_ELASTIC
					} );
			}
		}
		
		override public function addChild( child:DisplayObject ):DisplayObject 
		{
			throw new Error( "NEVER USE ADDCHILD ON STACK" );
		}
		
		public function show( c:Card ):void
		{
			selectedIndex = list.indexOf( c );
			dirty = true;
		}
		
		public function unshow( c:Card ):void
		{
			selectedIndex = -1;
			dirty = true;
		}
	
	}
}