package duel {
	import adobe.utils.CustomActions;
	import duel.cards.Card;
	import duel.cards.CardList;
	import duel.cards.CardSprite;
	import duel.cards.CardType;
	import duel.table.FieldType;
	import flash.text.TextField;
	import starling.animation.Transitions;
	import starling.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class TableSide extends GameSprite
	{
		public var fieldsC:Vector.<Field> = new Vector.<Field>();
		public var fieldsT:Vector.<Field> = new Vector.<Field>();
		public var fieldDeck:Field;
		public var fieldGrave:Field;
		
		private var player:Player;
		
		public function TableSide( player:Player, flip:Boolean )
		{
			this.player = player;
			
			const FIELD_SPACING_X:Number = 25;
			const FIELD_COLUMNS:int = 4;
			
			var f:Field;
			var i:int;
			for ( i = 0; i < FIELD_COLUMNS; i++ )
			{
				f = generateField( FieldType.CREATURE, i * ( G.CARD_W + FIELD_SPACING_X ),  ( flip ? 1.0 : -1.0 ) * 80 );
				f.index = i;
				f.allowedCardType = CardType.CREATURE;
				fieldsC.push( f );
			}
			for ( i = 0; i < FIELD_COLUMNS; i++ )
			{
				f = generateField( FieldType.TRAP, i * ( G.CARD_W + FIELD_SPACING_X ),  ( flip ? -1.0 : 1.0 ) * 80 );
				f.index = i;
				f.allowedCardType = CardType.TRAP;
				fieldsT.push( f );
			}
			
			f = generateField( FieldType.DECK, ( G.CARD_W + FIELD_SPACING_X ) * FIELD_COLUMNS, ( flip ? 1.0 : -1.0 ) * 40, player.deck );
			f.cardsContainer.cardSpacing = 2;
			fieldDeck = f;
			
			f = generateField( FieldType.GRAVEYARD, -( G.CARD_W + FIELD_SPACING_X ), ( flip ? 1.0 : -1.0 ) * 40, player.grave );
			f.cardsContainer.cardSpacing = 3;
			fieldGrave = f;
			
			alignPivot();
		}
		
		private function generateField( type:FieldType, x:Number, y:Number, cardList:CardList = null ):Field
		{
			var f:Field;
			f = new Field( this, type, cardList );
			f.sprite.x = x;
			f.sprite.y = y;
			f.cardsContainer.x = f.sprite.x;
			f.cardsContainer.y = f.sprite.y;
			return f;
		}
		
		public function addCardTo( c:Card, field:Field, flipped:Boolean = false ):void
		{
			if ( game.p1.hand.contains( c ) ) game.p1.hand.remove( c );
			if ( game.p2.hand.contains( c ) ) game.p2.hand.remove( c );
			
			if ( c.field != null ) {
				c.field.removeCard( c );
			}
			
			field.addCard( c );
			c.faceDown = flipped;
		}
		
		public function containsField( field:Field ):Boolean {
			return field.container == this;
		}
	}
}