package duel.display.cardlots
{
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
		
		private var _active:Boolean = false;
		
		private var selectedIndex:int = -1;
		
		private var hand:Hand;
		
		public function HandSprite( hand:Hand )
		{
			this.hand = hand;
			setTargetList( hand );
		}
		
		override public function advanceTime( time:Number ):void
		{
			//arrange();
			
			var o:CardSprite;
			var i:int = list.cardsCount;
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				o.x = lerp( o.x, o.targetProps.x, .15 );
				o.y = lerp( o.y, o.targetProps.y, .30 );
				o.scaleX = lerp( o.scaleX, o.targetProps.scale, .20 );
				o.scaleY = lerp( o.scaleY, o.targetProps.scale, .20 );
				o.rotation = lerp( o.rotation, o.targetProps.rotation, .25 );
			}
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
			
			const POR:Number = .100;
			var YY:Number
			
			if ( _active )
			{
				YY = App.mouseXY.y / App.WINDOW_H;
				YY = Math.max( 0, YY - 1.0 + POR );
				YY = YY * 1 / POR;
				YY = 1 - YY;
				
				YY = App.mouseXY.y / App.WINDOW_H > 1.0 - POR ? 0.0 : 1.0;
			}
			else
				YY = 1.0;
			
			const W:Number = maxWidth - G.CARD_W;
			
			var x:Number = G.CARD_W * .5;
			var y:Number = 0.0;
			
			var o:CardSprite;
			var i:int = list.cardsCount;
			var jj:int = 0;
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				
				/// X
				x = x + theD( W );
				o.targetProps.x = this.x + x;
				
				/// Y
				if ( _active )
					if ( selectedIndex < 0.0 )
						//y = .4 * G.CARD_H * YY
						y = 0
					else
						y =
							( topSide ? 1.0 : -1.0 ) * G.CARD_H
							* ( i == selectedIndex ? .5 : -.4 )
				else
					y = ( topSide ? 1.0 : -1.0 ) * G.CARD_H * -.4;
				o.targetProps.y = this.y + y;
				
				/// Z
				o.targetProps.scale = z;
				
				/// ROTATION
				o.targetProps.rotation = topSide ? Math.PI : .0;
				
				/// Index
				if ( topSide )
					o.parent.setChildIndex( o, 0 );
				else
					o.parent.setChildIndex( o, o.parent.numChildren - 1 );
				
				cardsParent.addChild( o );
				
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
			d = Math.min(( W - G.CARD_W * .5 ) / cardsCount, G.CARD_W );
			/**/
			
			return d;
		}
		
		private function lerp( a:Number, b:Number, r:Number ):Number
		{ return a + r * ( b - a ) }
		
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
		
		private function onCardSelected( e:Event ):void
		{
			var c:Card = e.data as Card;
			if ( c == null )
				return;
			if ( hand.containsCard( c ) )
				show( c );
		}
		
		private function onCardDeselected( e:Event ):void
		{
			var c:Card = e.data as Card;
			if ( c == null )
				return;
			if ( hand.containsCard( c ) )
				unshow( c );
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
		
		public function set active( value:Boolean ):void
		{
			_active = value;
			arrange();
		}
	
	}
}