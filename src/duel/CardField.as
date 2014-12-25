package duel {
	import duel.cards.Card;
	import duel.cards.CardType;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardField extends Image 
	{
		public var container:PlayerSide;
		public var allowedCardType:CardType;
		
		// BATTLE
		public var card:Card;
		
		public function CardField( container:PlayerSide, color:uint ) 
		{
			this.container = container;
			
			super( App.assets.getTexture( "field" ) );
			this.width = G.CARD_W;
			this.height = G.CARD_H;
			this.color = color; 
			//this.alpha = 0.5;
			this.touchable = true;
			this.useHandCursor = true;
			alignPivot();
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) return;
			
			if ( t.phase == TouchPhase.ENDED ) {
				Game.current.onFieldClicked( this );
			} 
		}
	}
}