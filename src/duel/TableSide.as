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
		
		public var player:Player;
		
		public function TableSide( player:Player, flip:Boolean )
		{
			this.player = player;
			
			const FIELD_SPACING_X:Number = 25;
			
			var f:Field;
			var i:int;
			for ( i = 0; i < G.FIELD_COLUMNS; i++ )
			{
				f = new Field( this );
				f.index = i;
				f.initialize( FieldType.CREATURE, player.fieldsC[ i ] );
				f.setViewPosition( i * ( G.CARD_W + FIELD_SPACING_X ),  ( flip ? 1.0 : -1.0 ) * 80 );
				f.allowedCardType = CardType.CREATURE;
				fieldsC.push( f );
			}
			for ( i = 0; i < G.FIELD_COLUMNS; i++ )
			{
				f = new Field( this );
				f.index = i;
				f.initialize( FieldType.TRAP, player.fieldsT[ i ] );
				f.setViewPosition( i * ( G.CARD_W + FIELD_SPACING_X ),  ( flip ? -1.0 : 1.0 ) * 80 );
				f.allowedCardType = CardType.TRAP;
				fieldsT.push( f );
			}
			
			f = new Field( this );
			f.initialize( FieldType.DECK, player.deck );
			f.setViewPosition( -( G.CARD_W + FIELD_SPACING_X ), ( flip ? 1.0 : -1.0 ) * 40 );
			f.cardsContainer.cardSpacing = 2;
			fieldDeck = f;
			
			f = new Field( this );
			f.initialize( FieldType.GRAVEYARD, player.grave );
			f.setViewPosition( ( G.CARD_W + FIELD_SPACING_X ) * G.FIELD_COLUMNS, ( flip ? 1.0 : -1.0 ) * 40 );
			f.cardsContainer.cardSpacing = 3;
			fieldGrave = f;
			
			alignPivot();
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