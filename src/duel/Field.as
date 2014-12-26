package duel {
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.cards.CardList;
	import duel.cards.CardSprite;
	import duel.cards.visual.CardsStackSprite;
	import duel.cards.CardType;
	import duel.table.FieldSprite;
	import duel.table.FieldType;
	import starling.animation.Transitions;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Field extends GameEntity
	{
		public var container:TableSide;
		public var type:FieldType;
		public var allowedCardType:CardType;
		public var index:uint;
		
		// BATTLE
		public var cards:CardList;
		
		public var sprite:FieldSprite;
		public var cardsContainer:CardsStackSprite;
		public var player:Player;
		
		public function Field( container:TableSide ) 
		{
			this.container = container;
			this.player = container.player;
		}
		
		public function initialize( type:FieldType, cardList:CardList = null ):void
		{
			this.type = type;
			this.cards = cardList;
			
			var color:uint = 0xFFFFFF;
			if ( isCreatureField )	color = 0x440011;	else
			if ( isTrapField )		color = 0x07274B;	else
			if ( isDeckStack ) 		color = 0x222222;	else
			if ( isGraveyardStack )	color = 0x221139;
			
			sprite = new FieldSprite( this, color );
			cardsContainer = new CardsStackSprite( cards );
			
			container.addChild( sprite );
			container.addChild( cardsContainer );
		}
		
		public function addCard( c:Card ):void
		{
			if ( c.field )
			{
				error( "WTF, BRO?" );
				c.field.removeCard( c );
			}
			
			c.field = this;
			
			cards.add( c );
			//cardsContainer.animBunch();
		}
		
		public function removeCard( c:Card ):void 
		{
			cards.remove( c );
			c.field = null;
		}
		
		//
		public function setViewPosition( x:Number, y:Number ):void
		{
			sprite.x = x;
			sprite.y = y;
			cardsContainer.x = sprite.x;
			cardsContainer.y = sprite.y;
		}
		
		public function animFall( c:Card ):void 
		{
			var m:CardSprite = c.sprite;
			m.scaleX = 1.3;
			m.scaleY = 1.3;
			game.jugglerStrict.xtween( m, 0.8, { 
				scaleX:1.0,
				scaleY:1.0,
				alpha:1.0,
				transition: Transitions.EASE_OUT_BOUNCE
			} );
		}
		
		//
		public function get isCreatureField():Boolean 	{ return type == FieldType.CREATURE }
		public function get isTrapField():Boolean 		{ return type == FieldType.TRAP }
		public function get isDeckStack():Boolean 		{ return type == FieldType.DECK }
		public function get isGraveyardStack():Boolean 	{ return type == FieldType.GRAVEYARD }
		
		public function get isEmpty():Boolean 	{ return cards.count == 0 }
	}
}