package duel.controllers
{
	import duel.cards.Card;
	import duel.cards.properties.CreatureCardProperties;
	import duel.display.fields.FieldSpriteGuiState;
	import duel.GameEntity;
	import duel.players.Player;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	import starling.animation.DelayedCall;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class SelectionManager extends GameEntity
	{
		private var faq:PlayerControllerFAQ;
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
		public var ctrl:UserPlayerController;
		
		public function initialize( player:Player, faq:PlayerControllerFAQ ):void
		{
			this.player = player;
			this.faq = faq;
			
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
			
			var dcall:DelayedCall = new DelayedCall( update, .250 );
			dcall.repeatCount = 0;
			juggler.add( dcall );
		}
		
		public function advanceTime(time:Number):void 
		{
			//update();
		}
		
		public function update():void
		{
			/// DESELECT CARD IF IMPOSSIBLE
			if ( selectedCard != null )
				deselectOnImpossible()
			
			/// SWITCH SELEcTION CONTEXTS
			if ( selectedCard == null )
				contextOnField = scfNilSelected
			else
			if ( selectedCard.isInHand && selectedCard.type.isCreature )
				contextOnField = scfHandCreature
			else
			if ( selectedCard.isInHand && selectedCard.type.isTrap )
				contextOnField = scfHandTrap
			else
			if ( selectedCard.isInPlay && selectedCard.type.isCreature )
				contextOnField = scfFieldCreature
			
			var i:int;
			
			// -- // -- // -- // -- // -- // -- // -- // -- // -- //
			// -- // 
			// -- // 					LOOP CARDS
			// -- // 
			// -- // -- // -- // -- // -- // -- // -- // -- // -- //
			var c:Card;
			for ( i = 0; i < game.cardsCount; i++ ) 
			{
				c = game.cards[ i ];
				c.sprite.isSelectable = 
					ctrl.active && 
					selectedCard == null &&
					c.lot != null && 
					c.lot.type.isHand && 
					canPlayHandCard( c );
			}
			
			// -- // -- // -- // -- // -- // -- // -- // -- // -- //
			// -- // 
			// -- // 					LOOP INDEXED FIELDS
			// -- // 
			// -- // -- // -- // -- // -- // -- // -- // -- // -- //
			var f:IndexedField;
			for ( i  = 0; i < game.indexedFields.length; i++ ) 
			{
				f = game.indexedFields[ i ];
				f.sprite.setGuiState( judgeFieldGuiState( f ) );
			}
			
			// -- // -- // -- // -- // -- // -- // -- // -- // -- //
			// -- // 
			// -- // 						DECK
			// -- // 
			// -- // -- // -- // -- // -- // -- // -- // -- // -- //
			
			if ( !player.deck.isEmpty )
				player.deck.topCard.sprite.isSelectable = 
					ctrl.active && 
					selectedCard == null &&
					player.mana.current > 0;
		}
		
		private function judgeFieldGuiState( f:IndexedField ):FieldSpriteGuiState
		{
			if ( !player.isMyTurn ) return FieldSpriteGuiState.NONE;
			if ( !game.interactable ) return FieldSpriteGuiState.NONE;
			
			if ( selectedCard == null )
				if ( ctrl.active && !f.isEmpty && canPlayFieldCard( f.topCard ) )
					return FieldSpriteGuiState.SELECTABLE;
				else
					return FieldSpriteGuiState.NONE;
			
			if ( selectedCard.isInHand )
			{
				if ( selectedCard.cost > player.mana.current )
					return FieldSpriteGuiState.NONE;
				
				if ( selectedCard.type.isCreature )
				{
					if ( f is CreatureField )
						if ( faq.canSummonCreatureOn( selectedCard, f, true ) == null )
							return selectedCard.statusC.needTribute ? 
								FieldSpriteGuiState.TRIBUTE_SUMMON : 
								FieldSpriteGuiState.NORMAL_SUMMON;
					return FieldSpriteGuiState.NONE;
				}
				if ( selectedCard.type.isTrap )
				{
					if ( f is TrapField )
						if ( faq.canSetTrapOn( selectedCard, f, true ) == null )
							return f.isEmpty ?
								FieldSpriteGuiState.SET_TRAP : 
								FieldSpriteGuiState.REPLACE_TRAP;
					return FieldSpriteGuiState.NONE
				}
			}
			
			if ( !selectedCard.isInPlay ) return FieldSpriteGuiState.NONE;
			if ( !selectedCard.type.isCreature ) return FieldSpriteGuiState.NONE;
			
			if ( f == selectedCard.indexedField )
				if ( faq.canCreatureSafeFlip( selectedCard, true ) == null )
					return FieldSpriteGuiState.SAFE_FLIP;
			
			if ( faq.canCreatureRelocateTo( selectedCard, f, true ) == null )
				return FieldSpriteGuiState.RELOCATE_TO;
			
			if ( f.index == selectedCard.indexedField.index )
				if ( f.owner == player.opponent )
					if ( f is CreatureField )
						if ( faq.canCreatureAttack( selectedCard, true ) == null )
							return f.isEmpty ?
								FieldSpriteGuiState.ATTACK_DIRECT : 
								FieldSpriteGuiState.ATTACK_CREATURE;
			
			return FieldSpriteGuiState.NONE
		}
		
		private function canPlayFieldCard( c:Card ):Boolean 
		{
			if ( !player.isMyTurn )
				return false;
			
			if ( c.type.isCreature )
				return !c.exhausted;
			return false;
		}
		
		private function canPlayHandCard( c:Card ):Boolean 
		{
			if ( !player.isMyTurn )
				return false;
			
			if ( c.cost > player.mana.current )
				return false;
				
			if ( c.type.isCreature )
				return player.fieldsC.hasAnyFieldThat( canSummonTo );
			if ( c.type.isTrap )
				return player.fieldsT.hasAnyFieldThat( canSetTrapTo );
			
			function canSummonTo( f:CreatureField ):Boolean
			{ return faq.canSummonCreatureOn( c, f, true ) == null }
			function canSetTrapTo( f:TrapField ):Boolean
			{ return faq.canSetTrapOn( c, f, true ) == null }
			
			return false;
		}
		
		public function deselectOnImpossible():void
		{
			if ( selectedCard.isInHand )
				if ( canSelectHandCard( selectedCard ) )
					return;
			if ( selectedCard.isInPlay && selectedCard.type.isCreature )
				if ( canSelectCreature( selectedCard ) )
					return;
			selectCard( null );
		}
		
		//{ Selection Contexts
		
		// in hand
		
		private function schEnabledIsSelectable( o:* ):Boolean
		{
			if ( o is Card && player.hand.containsCard( o as Card ) )
				return true;
			return false
		}
		
		private function schEnabledOnSelected( o:* ):void
		{
			//if ( !player.canPerformAction() )
				//game.gui.pMsg( "Not enough mana" );
			//else
			if ( Card( o ).controller != player )
				game.gui.pMsg( "This is not your card" );
			else
			if ( !canSelectHandCard( o as Card ) )
				game.gui.pMsg( "You cannot select this card for reasons" );
			else
				selectCard( o == selectedCard ? null : o as Card )
		}
		
		private function schDisabledIsSelectable( o:* ):Boolean
		{
			return false
		}
		
		// in play 
		
		private function scfNilSelectedIsSelectable( o:* ):Boolean
		{
			return o is Field;
		}
		private function scfNilSelectedOnSelected( o:* ):void
		{
			var problem:String;
			
			if ( o is CreatureField )
			{
				if ( CreatureField(o).owner == player )
					tryToSelectFieldCard( CreatureField(o).topCard );
				else
					tryToSelectFieldCard( CreatureField(o).opposingCreature );
			}
			if ( o is Field && Field( o ).type.isDeck && Field( o ).owner == player )
			{
				problem = faq.canDrawCard( player, true );
				if ( problem == null )
					ctrl.performActionDraw();
				else
					game.gui.pMsg( problem );	
			}
		}
		
		private function scfHandCreatureIsSelectable( o:* ):Boolean
		{
			return o is IndexedField;
		}
		private function scfHandCreatureOnSelected( o:* ):void
		{
			var problem:String = faq.canSummonCreatureOn( selectedCard, o as IndexedField, true );
			
			if ( problem == null )
				ctrl.performActionSummon( selectedCard, o as CreatureField );
			else
				game.gui.pMsg( problem );
		}
		
		
		private function scfHandTrapIsSelectable( o:* ):Boolean
		{
			return o is IndexedField;
		}
		private function scfHandTrapOnSelected( o:* ):void
		{
			var problem:String = faq.canSetTrapOn( selectedCard, o as IndexedField, true );
			
			if ( problem == null )
				ctrl.performActionTrapSet( selectedCard, o as TrapField );
			else
				game.gui.pMsg( problem );
		}
		
		
		private function scfFieldCreatureIsSelectable( o:* ):Boolean
		{
			return o is IndexedField;
		}
		private function scfFieldCreatureOnSelected( ff:* ):void
		{
			var problem:String;
			
			var f:IndexedField = ff as IndexedField;
			
			if ( f == null )
				return;
			
			///SAFE FLIP
			if ( f  == selectedCard.lot )
			{
				if ( selectedCard.faceDown && selectedCard.statusC.isFlippable )
				{
					problem = faq.canCreatureSafeFlip( selectedCard, true );
					if ( problem == null )
						ctrl.performActionSafeFlip( selectedCard );
					else
						game.gui.pMsg ( problem );
				}
				else
					selectCard( null );
				return;
			}
				
			/// RELOCATION
			if ( f.owner == player )
			{
				problem = faq.canCreatureRelocateTo( selectedCard, f as IndexedField, true );
				if ( problem == null )
					ctrl.performActionRelocation( selectedCard, f as CreatureField );
				else
				if ( f is IndexedField && IndexedField( f ).isEmpty )
					game.gui.pMsg( problem );
				else
					selectCard( f.topCard );
			}
			else
			/// ATTACK
			if ( f.owner == player.opponent && f.index == selectedCard.indexedField.index )
			{
				problem = faq.canCreatureAttack( selectedCard, true );
				if ( problem == null )
					ctrl.performActionAttack( selectedCard );
				else
				if ( f is IndexedField && IndexedField( f ).isEmpty )
					game.gui.pMsg( problem );
			}
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
			if ( card.exhausted )
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
				selectedCard.sprite.selectedAura.visible = false;
				
				game.gui.hideTip();
				
				if ( player.hand.containsCard( selectedCard ) )
					player.handSprite.unshow( selectedCard );
			}
			
			/// /// /// /// ///
			selectedCard = card
			/// /// /// /// ///
			
			/// NEW SELECTION
			if ( selectedCard != null )
			{
				if ( player.hand.containsCard( selectedCard ) )
					player.handSprite.show( selectedCard );
				
				if ( player.hand.containsCard( selectedCard ) )
					game.gui.showTip( selectedCard.name + '\n\n' + selectedCard.descr );
				
				selectedCard.sprite.selectedAura.visible = true;
			}
			
			///
			//update();
		}
		
		public function tryToSelectFieldCard( card:Card ):void
		{
			if ( card == null )
				//game.gui.pMsg( "There is no creature here" );
				selectCard( null );
			else
			if ( card.exhausted )
				game.gui.pMsg( "This card is exhausted" );
			else
			if ( card.controller != player )
				game.gui.pMsg( "This is not your creature" );
			else
				selectCard( card );
		}
		
		// // // // //
		// BULLSHIT //
		// // // // //
		
		private function log( ...rest ):void
		{ trace.apply( null, rest ) }
	}
}