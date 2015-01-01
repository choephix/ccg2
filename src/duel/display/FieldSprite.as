package duel.display {
	import duel.display.cardlots.DeckStackSprite;
	import duel.display.cardlots.GraveStackSprite;
	import duel.display.cardlots.StackSprite;
	import duel.GameSprite;
	import duel.table.Field;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class FieldSprite extends GameSprite 
	{
		public var cardsContainer:StackSprite;
		public var image:Image;
		
		public var field:Field;
		
		private var _pointerIsOver:Boolean = false;
		
		public function initialize( field:Field, color:uint ):void
		{
			image = assets.generateImage( "field", true, true );
			addChild( image );
			
			if ( field.type.isGraveyard )
				cardsContainer = new GraveStackSprite( field );
			else
			if ( field.type.isDeck )
				cardsContainer = new DeckStackSprite( field );
			else
				cardsContainer = new StackSprite( field );
			
			cardsContainer.touchable = false;
			
			this.field = field;
			field.sprite = this;
			
			image.color = color; 
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) {
				if ( _pointerIsOver ) {
					_pointerIsOver = false;
					if ( !field.isEmpty )
						game.onCardRollOut( field.getCardAt( 0 ) );
				}
				return;
			}
			else
			if ( t.phase == TouchPhase.HOVER ) {
				if ( !_pointerIsOver ) {
					_pointerIsOver = true;
					if ( !field.isEmpty )
						game.onCardRollOver( field.getCardAt( 0 ) );
				}
			}
			else
			if ( t.phase == TouchPhase.ENDED ) {
				game.onFieldClicked( field );
			} 
		}
		
	}

}