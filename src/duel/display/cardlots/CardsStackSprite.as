package duel.display.cardlots {
	import duel.cards.CardListBase;
	import starling.animation.Transitions;
	import starling.display.DisplayObject;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardsStackSprite extends CardsContainer
	{
		public var cardSpacing:Number = 10;
		
		public function CardsStackSprite( list:CardListBase )
		{
			setTargetList( list );
			juggler.add( this );
		}
		
		override public function arrange():void 
		{
			removeChildren();
			
			var o:DisplayObject;
			var i:int = list.cardsCount;
			var j:int = 0;
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				o.alpha = 1.0;
				o.x = 0;
				o.y = -cardSpacing * j;
				super.addChild( o );
				j++;
			}
		}
		
		override public function addChild( child:DisplayObject ):DisplayObject 
		{
			throw new Error( "NEVER USE ADDCHILD ON STACK" );
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