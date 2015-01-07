package duel.display {
	import chimichanga.common.display.Sprite;
	import duel.display.FieldSprite;
	import duel.display.utils.ColorScheme;
	import duel.G;
	import duel.GameSprite;
	import duel.players.Player;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class TableSide extends GameSprite
	{
		public var player:Player;
		
		public var tableContainer:Sprite;
		public var cardsParent:Sprite;
		
		public function TableSide( player:Player, flip:Boolean )
		{
			this.player = player;
			
			tableContainer = new Sprite();
			addChild( tableContainer );
			
			cardsParent = new Sprite();
			addChild( cardsParent );
			
			//
			const FIELD_SPACING_X:Number = 25;
			
			var f:FieldSprite;
			var i:int;
			var len:int;
			for ( i = 0, len = player.fieldsC.count; i < len; i++ )
			{
				f = new FieldSprite();
				f.x = i * ( G.CARD_W + FIELD_SPACING_X );
				f.y = ( flip ? 1.0 : -1.0 ) * 80;
				f.initialize( player.fieldsC.getAt( i ), ColorScheme.getColorForCreatureField() );
				prepFieldSprite( f );
			}
			for ( i = 0, len = player.fieldsT.count; i < len; i++ )
			{
				f = new FieldSprite();
				f.x = i * ( G.CARD_W + FIELD_SPACING_X );
				f.y = ( flip ? -1.0 : 1.0 ) * 80;
				f.initialize( player.fieldsT.getAt( i ), ColorScheme.getColorForTrapField() );
				prepFieldSprite( f );
			}
			
			f = new FieldSprite();
			f.x = ( G.CARD_W + FIELD_SPACING_X ) * G.FIELD_COLUMNS;
			f.y = ( flip ? 1.0 : -1.0 ) * 40;
			f.initialize( player.deck, ColorScheme.getColorForDeckField() );
			f.cardsContainer.cardSpacing = 2;
			prepFieldSprite( f );
			
			f = new FieldSprite();
			f.x = -( G.CARD_W + FIELD_SPACING_X );
			f.y = ( flip ? 1.0 : -1.0 ) * 40;
			f.initialize( player.grave, ColorScheme.getColorForGraveField() );
			f.cardsContainer.cardSpacing = 3;
			prepFieldSprite( f );
			
			alignPivot();
			
			function prepFieldSprite( f:FieldSprite ):void
			{
				tableContainer.addChild( f );
				f.cardsContainer.cardsParent = cardsParent;
				f.cardsContainer.x = f.x;
				f.cardsContainer.y = f.y;
			}
		}
	}
}