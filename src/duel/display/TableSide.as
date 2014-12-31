package duel.display {
	import duel.display.FieldSprite;
	import duel.display.utils.ColorScheme;
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
				f.initialize( player.fieldsC[ i ], ColorScheme.getColorForCreatureField() );
			}
			for ( i = 0, len = player.fieldsT.length; i < len; i++ )
			{
				f = new FieldSprite();
				f.x = i * ( G.CARD_W + FIELD_SPACING_X );
				f.y = ( flip ? -1.0 : 1.0 ) * 80;
				addChild( f );
				f.initialize( player.fieldsT[ i ], ColorScheme.getColorForTrapField() );
			}
			
			f = new FieldSprite();
			f.x = -( G.CARD_W + FIELD_SPACING_X );
			f.y = ( flip ? 1.0 : -1.0 ) * 40;
			addChild( f );
			f.initialize( player.deck, ColorScheme.getColorForDeckField() );
			f.cardsContainer.cardSpacing = 2;
			
			f = new FieldSprite();
			f.x = ( G.CARD_W + FIELD_SPACING_X ) * G.FIELD_COLUMNS;
			f.y = ( flip ? 1.0 : -1.0 ) * 40;
			addChild( f );
			f.initialize( player.grave, ColorScheme.getColorForGraveField() );
			f.cardsContainer.cardSpacing = 3;
			
			alignPivot();
		}
	}
}