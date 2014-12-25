package duel.cards
{
	import chimichanga.common.display.Sprite;
	import duel.G;
	import duel.GameSprite;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardSprite extends GameSprite
	{
		
		public var auraContainer:Sprite;
		private var pad:Quad;
		
		private var owner:Card;
		
		public function initialize( owner:Card ):void
		{
			this.owner = owner;
			
			pad = assets.generateImage( "card", true, false );
			pad.color = owner.type.color;
			addChild( pad );
			alignPivot();
			
			auraContainer = new Sprite();
			auraContainer.x = G.CARD_W * 0.5;
			auraContainer.y = G.CARD_H * 0.5;
			addChild( auraContainer );
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) return;
			
			if ( t.phase == TouchPhase.HOVER ) {
				game.onCardRollOver( owner );
			} 
			else
			if ( t.phase == TouchPhase.ENDED ) {
				game.onCardClicked( owner );
			} 
		}
	
	}

}