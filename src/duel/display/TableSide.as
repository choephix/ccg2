package duel.display {
	import chimichanga.common.display.Sprite;
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
		
		public var tableContainer:Sprite;
		public var cardsContainer:Sprite;
		
		public function TableSide( player:Player, flip:Boolean )
		{
			this.player = player;
			
			tableContainer = new Sprite();
			addChild( tableContainer );
			
			cardsContainer = new Sprite();
			addChild( cardsContainer );
			
			//
			const FIELD_SPACING_X:Number = 25;
			
			var f:FieldSprite;
			var i:int;
			var len:int;
			for ( i = 0, len = player.fieldsC.length; i < len; i++ )
			{
				f = new FieldSprite();
				f.x = i * ( G.CARD_W + FIELD_SPACING_X );
				f.y = ( flip ? 1.0 : -1.0 ) * 80;
				tableContainer.addChild( f );
				f.initialize( player.fieldsC[ i ], ColorScheme.getColorForCreatureField() );
					temp();
			}
			for ( i = 0, len = player.fieldsT.length; i < len; i++ )
			{
				f = new FieldSprite();
				f.x = i * ( G.CARD_W + FIELD_SPACING_X );
				f.y = ( flip ? -1.0 : 1.0 ) * 80;
				tableContainer.addChild( f );
				f.initialize( player.fieldsT[ i ], ColorScheme.getColorForTrapField() );
					temp();
			}
			
			f = new FieldSprite();
			f.x = -( G.CARD_W + FIELD_SPACING_X );
			f.y = ( flip ? 1.0 : -1.0 ) * 40;
			tableContainer.addChild( f );
			f.initialize( player.deck, ColorScheme.getColorForDeckField() );
			f.cardsContainer.cardSpacing = 2;
				temp();
			
			f = new FieldSprite();
			f.x = ( G.CARD_W + FIELD_SPACING_X ) * G.FIELD_COLUMNS;
			f.y = ( flip ? 1.0 : -1.0 ) * 40;
			tableContainer.addChild( f );
			f.initialize( player.grave, ColorScheme.getColorForGraveField() );
			f.cardsContainer.cardSpacing = 3;
				temp();
			
			alignPivot();
			
			function temp():void
			{
				cardsContainer.addChild( f.cardsContainer );
				f.cardsContainer.x = f.x;
				f.cardsContainer.y = f.y;
			}
		}
	}
}