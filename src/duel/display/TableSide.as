package duel.display {
	import chimichanga.common.display.Sprite;
	import duel.display.FieldSprite;
	import duel.display.utils.ColorScheme;
	import duel.G;
	import duel.GameEntity;
	import duel.GameSprite;
	import duel.players.Player;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class TableSide extends GameEntity
	{
		public function TableSide( player:Player, tableSprite:TableSprite, flip:Boolean )
		{
			//p2.tableSide.x = App.W * 0.50;
			//p2.tableSide.y = App.H * 0.23;
			//p1.tableSide.x = App.W * 0.50;
			//p1.tableSide.y = App.H * 0.77;
			
			//
			const CENTER_EXRA_MARGIN:Number = 15;
			const FIELD_SPACING_X:Number = 45;
			const FIELD_SPACING_Y:Number = 30;
			const Z:Number = G.TABLE_Z;
			
			const C_COUNT:int = player.fieldsC.count;
			const T_COUNT:int = player.fieldsT.count;
			
			var f:FieldSprite;
			var i:int;
			var len:int;
			var dir:Number = flip ? -1.0 : 1.0;
			for ( i = 0, len = C_COUNT; i < len; i++ )
			{
				f = new FieldSprite();
				f.x = ( i - ( len - 1 ) * .5 ) * ( G.CARD_W * Z + FIELD_SPACING_X );
				f.y = dir * ( 0.5 * ( G.CARD_H * Z + FIELD_SPACING_Y ) + CENTER_EXRA_MARGIN );
				f.initialize( player.fieldsC.getAt( i ), ColorScheme.getColorForCreatureField() );
				prepFieldSprite( f );
			}
			for ( i = 0, len = T_COUNT; i < len; i++ )
			{
				f = new FieldSprite();
				f.x = ( i - ( len - 1 ) * .5 ) * ( G.CARD_W * Z + FIELD_SPACING_X );
				f.y = dir * ( 1.5 * ( G.CARD_H * Z + FIELD_SPACING_Y ) + CENTER_EXRA_MARGIN );
				f.initialize( player.fieldsT.getAt( i ), ColorScheme.getColorForTrapField() );
				prepFieldSprite( f );
			}
			
			f = new FieldSprite();
			f.x = ( G.CARD_W * Z + FIELD_SPACING_X ) * ( C_COUNT + 1 ) * .5;
			f.y = dir * ( 0.6 * ( G.CARD_H * Z + FIELD_SPACING_Y ) + CENTER_EXRA_MARGIN );
			f.initialize( player.deck, ColorScheme.getColorForDeckField() );
			f.cardsContainer.cardSpacing = 2;
			prepFieldSprite( f );
			
			f = new FieldSprite();
			f.x = ( G.CARD_W * Z + FIELD_SPACING_X ) * ( C_COUNT + 1 ) * -.5;
			f.y = dir * ( 0.6 * ( G.CARD_H * Z + FIELD_SPACING_Y ) + CENTER_EXRA_MARGIN );
			f.initialize( player.grave, ColorScheme.getColorForGraveField() );
			f.cardsContainer.cardSpacing = 3;
			prepFieldSprite( f );
			
			function prepFieldSprite( f:FieldSprite ):void
			{
				tableSprite.surface.addChild( f );
				f.fieldTipsParent = tableSprite.fieldTipsParent;
				f.cardsContainer.cardsParent = tableSprite.cardsParent;
				f.cardsContainer.x = f.x;
				f.cardsContainer.y = f.y;
				f.z = Z;
			}
		}
	}
}