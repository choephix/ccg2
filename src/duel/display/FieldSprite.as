package duel.display {
	import duel.display.cardlots.CardsStackSprite;
	import duel.G;
	import duel.Game;
	import duel.table.Field;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class FieldSprite extends Image 
	{
		public var cardsContainer:CardsStackSprite;
		public var field:Field;
		
		public function FieldSprite() 
		{
			super( App.assets.getTexture( "field" ) );
		}
		
		public function initialize( field:Field, color:uint ):void
		{
			/** /
			var color:uint = 0xFFFFFF;
			switch( field.type )
			{
				case FieldType.CREATURE:	color = 0x440011; break;
				case FieldType.TRAP:		color = 0x07274B; break;
				case FieldType.DECK:		color = 0x222222; break;
				case FieldType.GRAVEYARD:	color = 0x221139; break;
			}
			/**/
			
			this.field = field;
			
			this.width = G.CARD_W;
			this.height = G.CARD_H;
			this.color = color; 
			//this.alpha = 0.5;
			this.touchable = true;
			this.useHandCursor = true;
			alignPivot();
			
			cardsContainer = new CardsStackSprite( field );
			cardsContainer.x = x;
			cardsContainer.y = y;
			parent.addChild( cardsContainer );
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) return;
			
			if ( t.phase == TouchPhase.ENDED ) {
				Game.current.onFieldClicked( field );
			} 
		}
		
	}

}