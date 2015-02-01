package duel.display {
	import chimichanga.common.display.Sprite;
	import duel.display.FieldSprite;
	import duel.display.utils.ColorScheme;
	import duel.G;
	import duel.GameEntity;
	import duel.GameSprite;
	import duel.players.Player;
	import duel.table.Field;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class TableSide extends GameEntity
	{
		public function TableSide( player:Player, tableSprite:TableSprite, flip:Boolean )
		{
			initialize( player, tableSprite, flip );
		}
		
		public function initialize( player:Player, tableSprite:TableSprite, flip:Boolean ):void
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
			
			var o:FieldSprite;
			var i:int;
			var len:int;
			var dir:Number = flip ? -1.0 : 1.0;
			for ( i = 0, len = C_COUNT; i < len; i++ )
			{
				o = new FieldSprite();
				prepFieldSprite( o, player.fieldsC.getAt( i ), ColorScheme.getColorForCreatureField() );
				o.x = ( i - ( len - 1 ) * .5 ) * ( G.CARD_W * Z + FIELD_SPACING_X );
				o.y = dir * ( 0.5 * ( G.CARD_H * Z + FIELD_SPACING_Y ) + CENTER_EXRA_MARGIN );
			}
			for ( i = 0, len = T_COUNT; i < len; i++ )
			{
				o = new FieldSprite();
				prepFieldSprite( o, player.fieldsT.getAt( i ), ColorScheme.getColorForTrapField() );
				o.x = ( i - ( len - 1 ) * .5 ) * ( G.CARD_W * Z + FIELD_SPACING_X );
				o.y = dir * ( 1.5 * ( G.CARD_H * Z + FIELD_SPACING_Y ) + CENTER_EXRA_MARGIN );
			}
			
			o = new FieldSprite();
			prepFieldSprite( o, player.deck, ColorScheme.getColorForDeckField() );
			o.x = ( G.CARD_W * Z + FIELD_SPACING_X ) * ( C_COUNT + 1 ) * .5;
			o.y = dir * ( 0.6 * ( G.CARD_H * Z + FIELD_SPACING_Y ) + CENTER_EXRA_MARGIN );
			o.cardsContainer.cardSpacing = 2;
			
			o = new FieldSprite();
			prepFieldSprite( o, player.grave, ColorScheme.getColorForGraveField() );
			o.x = ( G.CARD_W * Z + FIELD_SPACING_X ) * ( C_COUNT + 1 ) * -.5;
			o.y = dir * ( 0.6 * ( G.CARD_H * Z + FIELD_SPACING_Y ) + CENTER_EXRA_MARGIN );
			o.cardsContainer.cardSpacing = 3;
			
			function prepFieldSprite( o:FieldSprite, field:Field, color:uint ):void
			{
				tableSprite.surface.addChild( o );
				o.fieldOverlayParent = tableSprite.fieldTipsParent;
				o.initialize( field, color, tableSprite.cardsParent );
				o.z = Z;
			}
		}
	}
}