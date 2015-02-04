package duel.display 
{
	import duel.GameEntity;
	/**
	 * ...
	 * @author choephix
	 */
	public class SelectionVisuals extends GameEntity
	{
		
		public function SelectionVisuals() 
		{
			
		}
		
		public function updateSelectables():void
		{
			var card:Card = selectedCard;
				
			/// HAND
			
			var i:int = 0;
			for ( 0; i < currentPlayer.hand.cardsCount; i++ )
				currentPlayer.hand.getCardAt( i ).sprite.isSelectable = 
					card == null ? canPlayAtAll( currentPlayer.hand.getCardAt( i ) ) : false;
			for ( 0; i < currentPlayer.opponent.hand.cardsCount; i++ )
				currentPlayer.opponent.hand.getCardAt( i ).sprite.isSelectable = false;
			
			/// COMBAT FIELDS
			var clr:uint;
			var cond:Function;
			
			clr = 0; cond = null;
			p1.fieldsC.forEachField( setFieldAuraColor );
			p1.fieldsT.forEachField( setFieldAuraColor );
			p2.fieldsC.forEachField( setFieldAuraColor );
			p2.fieldsT.forEachField( setFieldAuraColor );
			
			if ( card == null )
			{
				clr = 0xFFFFFF; cond = isSelectable;
				currentPlayer.fieldsC.forEachField( setFieldAuraColor );
			}
			else
			{
				if ( card.lot is Hand )
				{
					if ( card.isTrap )
					{
						clr = 0xB062FF; cond = canSetTrapTo;
						currentPlayer.fieldsT.forEachField( setFieldAuraColor );
					}
					if ( card.isCreature )
					{
						clr = 0xCC530B; cond = canSummonTo;
						currentPlayer.fieldsC.forEachField( setFieldAuraColor );
					}
				}
				else
				if ( card.isInPlay )
				{
					if ( card.isCreature && !card.exhausted )
					{
						if ( CommonCardQuestions.canPerformAttack( card ) )
						{
							clr = 0xD71500; //cond = canAttack;
							card.indexedField.opposingCreatureField.sprite.setSelectableness( clr )
							if ( card.indexedField.opposingCreatureField.isEmpty )
								card.indexedField.opposingTrapField.sprite.setSelectableness( clr )
						}
						clr = 0x1050AF; cond = canRelocateTo;
						currentPlayer.fieldsC.forEachField( setFieldAuraColor );
					}
				}
			}
			
			/// SLECTED, IN HAND
			function canSetTrapTo( f:TrapField ):Boolean
			{ return CommonCardQuestions.canPlaceTrapHere( card, f ) }
			function canSummonTo( f:CreatureField ):Boolean
			{ return CommonCardQuestions.canSummonHere( card, f ) }
			
			/// SELECTED, ON FIELD
			//function canAttack( f:CreatureField ):Boolean
			//{ return CommonCardQuestions.canPerformAttack( card ) ) }
			function canRelocateTo( f:CreatureField ):Boolean
			{ return CommonCardQuestions.canRelocateHere( card, f ) }
			
			/// NOTHING SELECTED
			function isSelectable( f:Field ):Boolean
			{ return f.topCard != null && canSelect( f.topCard ) }
			
			function setFieldAuraColor( f:Field ):void
			{
				f.sprite.setSelectableness( cond == null || cond( f ) ? clr : 0 );
			}
		}
		
	}

}