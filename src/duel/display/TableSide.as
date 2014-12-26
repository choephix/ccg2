package duel.display {
	import duel.display.FieldSprite;
	import duel.G;
	import duel.GameSprite;
	import duel.Player;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class TableSide extends GameSprite
	{
		public var player:Player;
		
		public function TableSide( player:Player, flip:Boolean )
		{
			this.player = player;
			
			const FIELD_SPACING_X:Number = 25;
			
			var f:FieldSprite;
			var i:int;
			var len:int;
			for ( i = 0, len = player.fieldsC.length; i < len; i++ )
			{
				f = new FieldSprite();
				f.x = i * ( G.CARD_W + FIELD_SPACING_X );
				f.y = ( flip ? 1.0 : -1.0 ) * 80;
				addChild( f );
				f.initialize( player.fieldsC[ i ], 0x440011 );
			}
			for ( i = 0, len = player.fieldsT.length; i < len; i++ )
			{
				f = new FieldSprite();
				f.x = i * ( G.CARD_W + FIELD_SPACING_X );
				f.y = ( flip ? -1.0 : 1.0 ) * 80;
				addChild( f );
				f.initialize( player.fieldsT[ i ], 0x07274B );
			}
			
			f = new FieldSprite();
			f.x = -( G.CARD_W + FIELD_SPACING_X );
			f.y = ( flip ? 1.0 : -1.0 ) * 40;
			addChild( f );
			f.initialize( player.deck, 0x222222 );
			f.cardsContainer.cardSpacing = 2;
			
			f = new FieldSprite();
			f.x = ( G.CARD_W + FIELD_SPACING_X ) * G.FIELD_COLUMNS;
			f.y = ( flip ? 1.0 : -1.0 ) * 40;
			addChild( f );
			f.initialize( player.grave, 0x221139 );
			f.cardsContainer.cardSpacing = 3;
			
			alignPivot();
		}
	}
}