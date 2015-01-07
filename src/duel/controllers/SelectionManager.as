package duel.controllers
{
	import duel.cards.Card;
	import duel.cards.CommonCardQuestions;
	import duel.GameEntity;
	import duel.players.Player;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.TrapField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class SelectionManager extends GameEntity
	{
		private var ctrl:UserPlayerController;
		private var player:Player;
		
		public var schEnabled:SelectionContext;
		public var schDisabled:SelectionContext;
		
		public var scfNilSelected:SelectionContext;
		public var scfHandCreature:SelectionContext;
		public var scfHandTrap:SelectionContext;
		public var scfFieldCreature:SelectionContext;
		
		public var contextInHand:SelectionContext;
		public var contextOnField:SelectionContext;
		
		public var selectedCard:Card;
		
		public function initialize( ctrl:UserPlayerController, player:Player ):void
		{
			this.player = player;
			this.ctrl = ctrl;
			
			//{ Selection Contexts
			
			schEnabled = new SelectionContext();
			schEnabled.name = "schEnabled";
			schEnabled.isSelectable = schEnabledIsSelectable;
			schEnabled.onSelected = schEnabledOnSelected;
			
			schDisabled = new SelectionContext();
			schDisabled.name = "schDisabled";
			schDisabled.isSelectable = schDisabledIsSelectable;
			
			//
			
			scfNilSelected = new SelectionContext();
			scfNilSelected.name = "scfNilSelected";
			scfNilSelected.isSelectable = scfNilSelectedIsSelectable;
			scfNilSelected.onSelected = scfNilSelectedOnSelected;
			
			scfHandCreature = new SelectionContext();
			scfHandCreature.name = "scfHandCreature";
			scfHandCreature.isSelectable = scfHandCreatureIsSelectable;
			scfHandCreature.onSelected = scfHandCreatureOnSelected;
			
			
			scfHandTrap = new SelectionContext();
			scfHandTrap.name = "scfHandTrap";
			scfHandTrap.isSelectable = scfHandTrapIsSelectable;
			scfHandTrap.onSelected = scfHandTrapOnSelected;
			
			
			scfFieldCreature = new SelectionContext();
			scfFieldCreature.name = "scfFieldCreature";
			scfFieldCreature.isSelectable = scfFieldCreatureIsSelectable;
			scfFieldCreature.onSelected = scfFieldCreatureOnSelected;
			
			//}
			
			contextInHand = schEnabled;
			contextOnField = scfNilSelected;
			
		}
		
		//{ Selection Contexts
		
		private function schEnabledIsSelectable( o:* ):Boolean
		{
			if ( o is Card && player.hand.containsCard( o as Card ) )
				return true;
			return false
		}
		
		private function schEnabledOnSelected( o:* ):void
		{
			if ( o is Card && player.hand.containsCard( o as Card ) )
				if ( canSelectHandCard( o as Card ) )
					selectCard( o == selectedCard ? null : o as Card )
		}
		
		private function schDisabledIsSelectable( o:* ):Boolean
		{
			return false
		}
		
		//
		
		private function scfNilSelectedIsSelectable( o:* ):Boolean
		{
			return o is Field;
		}
		private function scfNilSelectedOnSelected( o:* ):void
		{
			if ( o is CreatureField )
			{
				if ( CreatureField(o).owner == player )
					tryToSelectCard( CreatureField(o).topCard );
				else
					tryToSelectCard( CreatureField(o).opposingCreature );
			}
			if ( o is Field && Field( o ).type.isDeck && Field( o ).owner == player )
			{
				ctrl.performActionDraw();
			}
		}
		
		private function scfHandCreatureIsSelectable( o:* ):Boolean
		{
			return o is CreatureField 
				&&
				CommonCardQuestions.canSummonHere( selectedCard, o as CreatureField );
		}
		private function scfHandCreatureOnSelected( o:* ):void
		{
			ctrl.performActionSummon( selectedCard, o as CreatureField );
		}
		
		
		private function scfHandTrapIsSelectable( o:* ):Boolean
		{
			return o is TrapField
				&&
				CommonCardQuestions.canPlaceTrapHere( selectedCard, o as TrapField );
		}
		private function scfHandTrapOnSelected( o:* ):void
		{
			ctrl.performActionTrapSet( selectedCard, o as TrapField );
		}
		
		
		private function scfFieldCreatureIsSelectable( o:* ):Boolean
		{
			return o is CreatureField;
		}
		private function scfFieldCreatureOnSelected( o:* ):void
		{
			if ( o is CreatureField )
			{
				var f:CreatureField = o as CreatureField;
				
				if ( f.owner == player )
					ctrl.performActionRelocation( selectedCard, f );
				else
				if ( f.owner == player.opponent )
					ctrl.performActionAttack( selectedCard );
			}
			trace ( "SPARTAA!" );
		}
		
		//}
		
		// - CARD - SELECTION - //
		
		public function canSelectHandCard( card:Card ):Boolean
		{
			if ( card.controller != player )
				return false;
			return true;
		}
		
		public function canSelectCreature( card:Card ):Boolean
		{
			if ( card.controller != player )
				return false;
			return true;
		}
		
		public function selectCard( card:Card ):void
		{
			CONFIG::development 
			{ log( "WILL SELECT "+card ) }
			
			/// OLD SELECTION
			if ( selectedCard != null )
			{
				selectedCard.sprite.scaleX = 1.0;
				selectedCard.sprite.scaleY = 1.0;
				
				if ( player.hand.containsCard( selectedCard ) )
				{
					player.handSprite.unshow( selectedCard );
				}
			}
			
			/// /// /// /// ///
			selectedCard = card
			/// /// /// /// ///
			
			/// NEW SELECTION
			if ( selectedCard != null )
			{
				if ( player.hand.containsCard( selectedCard ) )
				{
					player.handSprite.show( selectedCard );
					
					/// UPDATE SELECTION CONTEXT
					if ( selectedCard.type.isCreature )
						contextOnField = scfHandCreature;
					if ( selectedCard.type.isTrap )
						contextOnField = scfHandTrap;
				}
				else
				if ( selectedCard.lot.type.isCreatureField )
				{
					/// UPDATE SELECTION CONTEXT
					contextOnField = scfFieldCreature;
					
					selectedCard.sprite.scaleX = 1.1;
					selectedCard.sprite.scaleY = 1.1;
				}
			}
			else
			{
				contextOnField = scfNilSelected;
			}
		}
		
		public function tryToSelectCard( card:Card ):void
		{
			if ( card == null )
			{
				trace ( "There is no creature here" );
				return;
			}
			if ( card.exhausted )
			{
				trace ( "This card is exhausted" );
				return;
			}
			if ( card.controller != player )
			{
				trace ( "This is not your creature" );
				return;
			}
			selectCard( card );
		}
		
		// // // // //
		// BULLSHIT //
		// // // // //
		
		private function log( ...rest ):void
		{ trace.apply( null, rest ) }
	}
}