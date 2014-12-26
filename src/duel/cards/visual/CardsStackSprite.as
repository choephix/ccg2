package duel.cards.visual {
	import duel.cardlots.CardListBase;
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
			game.jugglerMild.add( this );
		}
		
		override public function arrange():void 
		{
			removeChildren();
			
			var o:DisplayObject;
			for ( var i:int = 0, iMax:int = list.cardsCount; i < iMax; i++ )
			{
				o = list.getCardAt( i ).sprite;
				o.x = 0;
				o.y = -cardSpacing * numChildren;
				super.addChild( o );
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
				game.jugglerStrict.xtween( o, 0.8, { 
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