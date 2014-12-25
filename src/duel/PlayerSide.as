package duel {
	import adobe.utils.CustomActions;
	import duel.cards.Card;
	import duel.cards.CardSprite;
	import duel.cards.CardType;
	import flash.text.TextField;
	import starling.animation.Transitions;
	import starling.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class PlayerSide extends GameSprite
	{
		public var fieldsC:Vector.<Field> = new Vector.<Field>();
		public var fieldsT:Vector.<Field> = new Vector.<Field>();
		public var fieldDeck:Field;
		public var fieldGrave:Field;
		
		public function PlayerSide( flip:Boolean )
		{
			super();
			
			const FIELD_SPACING_X:Number = 25;
			const FIELD_COLUMNS:int = 4;
			
			var f:Field;
			var i:int;
			for ( i = 0; i < FIELD_COLUMNS; i++ )
			{
				f = new Field( this, 0x440011 );
				f.index = i;
				f.sprite.x = i * ( G.CARD_W + FIELD_SPACING_X );
				f.sprite.y = ( flip ? 1.0 : -1.0 ) * 80;
				f.allowedCardType = CardType.CREATURE;
				fieldsC.push( f );
				addChild( f.sprite );
			}
			for ( i = 0; i < FIELD_COLUMNS; i++ )
			{
				f = new Field( this, 0x07274B );
				f.index = i;
				f.sprite.x = fieldsC[ i ].sprite.x;
				f.sprite.y = ( flip ? -1.0 : 1.0 ) * 80;
				f.allowedCardType = CardType.TRAP;
				fieldsT.push( f );
				addChild( f.sprite );
			}
			
			f = new Field( this, 0x221139 );
			f.sprite.x = ( G.CARD_W + FIELD_SPACING_X ) * FIELD_COLUMNS;
			f.sprite.y = ( flip ? 1.0 : -1.0 ) * 40;
			addChild( f.sprite );
			fieldDeck = f;
			
			f = new Field( this, 0x222222 );
			f.sprite.x = -( G.CARD_W + FIELD_SPACING_X );
			f.sprite.y = ( flip ? 1.0 : -1.0 ) * 40;
			addChild( f.sprite );
			fieldGrave = f;
			
			alignPivot();
		}
		
		public function addCardTo( c:Card, field:Field, flipped:Boolean = false ):void
		{
			if ( game.p1.hand.contains( c ) ) game.p1.hand.remove( c );
			if ( game.p2.hand.contains( c ) ) game.p2.hand.remove( c );
			
			if ( c.field != null ) {
				c.field.card = null;
			}
			
			field.card = c;
			c.field = field;
			
			c.flipped = flipped;
			
			// VISUAL
			var m:CardSprite = c.sprite;
			
			addChild( m );
			m.x = field.sprite.x;
			m.y = field.sprite.y;
			
			m.scaleX = 1.3;
			m.scaleY = 1.3;
			game.jugglerStrict.xtween( m, 0.8, { 
				scaleX:1.0,
				scaleY:1.0,
				alpha:1.0,
				transition: Transitions.EASE_OUT_BOUNCE
			} );
		}
		
		public function containsField( field:Field ):Boolean {
			return field.container == this;
		}
	}
}