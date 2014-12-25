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
		
		public function PlayerSide( flip:Boolean )
		{
			super();
			
			var f:Field;
			var i:int;
			for ( i = 0; i < 4; i++ )
			{
				f = new Field( this, 0x440011 );
				addChild( f.sprite );
				f.sprite.x = i * ( G.CARD_W + 50 );
				f.sprite.y = ( flip ? 1.0 : -1.0 ) * 80;
				f.allowedCardType = CardType.CREATURE;
				fieldsC.push( f );
			}
			for ( i = 0; i < 4; i++ )
			{
				f = new Field( this, 0x07274B );
				addChild( f.sprite );
				f.sprite.x = fieldsC[ i ].sprite.x;
				f.sprite.y = ( flip ? -1.0 : 1.0 ) * 80;
				f.allowedCardType = CardType.TRAP;
				fieldsT.push( f );
			}
			
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