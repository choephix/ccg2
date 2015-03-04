package duel.controllers
{
	import chimichanga.global.utils.MathF;
	import duel.cards.Card;
	import duel.cards.temp_database.TempDatabaseUtils;
	import duel.display.fields.FieldSpriteGuiState;
	import duel.display.fx.CardGlow;
	import duel.GameEntity;
	import duel.gameplay.CardEvents;
	import duel.players.Player;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class SelectionManager extends GameEntity
	{
		private var cardGlow:CardGlow;
		
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
		
		private var _updateFlag:Boolean = true;;
		
		public function initialize( player:Player, faq:PlayerControllerFAQ ):void
		{
			this.cardGlow = new CardGlow();
			game.juggler.add( cardGlow );
			
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
			
			game.cardEvents.addEventListener( CardEvents.LEAVE_LOT, onCardLeaveLot );
			game.processes.addEventListener( Event.COMPLETE, onAllProcessesComplete );
		}
		
		private function onAllProcessesComplete( e:Event ):void 
		{
			selectCard( null );
		}
		
		public function advanceTime( time:Number ):void 
		{
			update();
		}
		
		public function update():void
		{
			var i:int;
			
			if ( !game.interactable )
			{
				_updateFlag = true;
				return;
			}
			
			if ( !_updateFlag )
				return;
				
			trace ( "GUI Update" );
			
			/// DESELECT CARD IF IMPOSSIBLE
			if ( selectedCard != null )
				deselectOnImpossible()
			
			/// SWITCH SELEcTION CONTEXTS
			if ( selectedCard == null )
				contextOnField = scfNilSelected
			else
			if ( selectedCard.isInHand && selectedCard.isCreature )
				contextOnField = scfHandCreature
			else
			if ( selectedCard.isInHand && selectedCard.isTrap )
				contextOnField = scfHandTrap
			else
			if ( selectedCard.isInPlay && selectedCard.isCreature )
				contextOnField = scfFieldCreature
			
			//if ( !ctrl.active )
				//return;
			
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
			
			//var f:IndexedField;
			//for ( i  = 0; i < game.indexedFields.length; i++ ) 
			//{
				//f = game.indexedFields[ i ];
				//f.sprite.setGuiState( judgeFieldGuiState( f ) );
			//}
			
			//TODO Test performance withoud dcalls
			//TODO Also clear dcalls before update or fast-clicking problem is problem
			var f:IndexedField;
			var state:FieldSpriteGuiState;
			var delay:Number = .0;
			for ( i  = 0; i < game.indexedFields.length; i++ ) 
			{
				f = game.indexedFields[ i ];
				state = judgeFieldGuiState( f );
				f.sprite.setGuiState( FieldSpriteGuiState.NONE );
				if ( state != FieldSpriteGuiState.NONE )
					juggler.delayCall( f.sprite.setGuiState, delay += .070, state );
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
			
			_updateFlag = false;
		}
		
		private function judgeFieldGuiState( f:IndexedField ):FieldSpriteGuiState
		{
			if ( !player.isMyTurn ) return FieldSpriteGuiState.NONE;
			if ( !game.interactable ) return FieldSpriteGuiState.NONE;
			
			if ( selectedCard == null )
				if ( ctrl.active && !f.isEmpty && f.owner.isMyTurn && canPlayFieldCard( f.topCard ) )
					return FieldSpriteGuiState.SELECTABLE;
				else
					return FieldSpriteGuiState.NONE;
			
			if ( selectedCard.isInHand )
			{
				if ( selectedCard.cost > player.mana.current )
					return FieldSpriteGuiState.NONE;
				
				if ( selectedCard.isCreature )
				{
					if ( f is CreatureField )
						if ( faq.canManuallySummonCreatureOn( selectedCard, f ) == null )
							return selectedCard.statusC.needTribute ? 
								FieldSpriteGuiState.TRIBUTE_SUMMON : 
								FieldSpriteGuiState.NORMAL_SUMMON;
					return FieldSpriteGuiState.NONE;
				}
				if ( selectedCard.isTrap )
				{
					if ( f is TrapField )
						if ( faq.canManuallySetTrapOn( selectedCard, f ) == null )
							return f.isEmpty ?
								FieldSpriteGuiState.SET_TRAP : 
								FieldSpriteGuiState.REPLACE_TRAP;
					return FieldSpriteGuiState.NONE
				}
			}
			
			if ( !selectedCard.isInPlay ) return FieldSpriteGuiState.NONE;
			if ( !selectedCard.isCreature ) return FieldSpriteGuiState.NONE;
			
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
			
			if ( c.isCreature )
				return !c.statusC.hasSummonExhaustion && !c.statusC.hasActionExhaustion;
			
			return false;
		}
		
		private function canPlayHandCard( c:Card ):Boolean 
		{
			if ( !player.isMyTurn )
				return false;
			
			if ( c.cost > player.mana.current )
				return false;
				
			if ( c.isCreature )
				return player.fieldsC.hasAnyFieldThat( canSummonTo );
			if ( c.isTrap )
				return player.fieldsT.hasAnyFieldThat( canSetTrapTo );
			
			function canSummonTo( f:CreatureField ):Boolean
			{ return faq.canManuallySummonCreatureOn( c, f ) == null }
			function canSetTrapTo( f:TrapField ):Boolean
			{ return faq.canManuallySetTrapOn( c, f ) == null }
			
			return false;
		}
		
		public function deselectOnImpossible():void
		{
			if ( selectedCard.isInHand )
				if ( canSelectHandCard( selectedCard ) )
					return;
			if ( selectedCard.isInPlay && selectedCard.isCreature )
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
			if ( player.mana.current < Card( o ).cost  )
				game.gui.pMsg( "You do not have enough AP to play " + o );
			else
			if ( Card( o ).controller != player )
				game.gui.pMsg( "This is not your card" );
			else
			if ( !canPlayHandCard( o as Card ) )
				game.gui.pMsg( "You cannot play " + o + " anywhere right now" );
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
			var problem:String = faq.canManuallySummonCreatureOn( selectedCard, o as IndexedField );
			
			if ( problem == null )
				ctrl.performActionSummon( selectedCard, o as CreatureField );
			else
				game.gui.pMsg( problem );
				
			CONFIG::sandbox
			{
				if ( player.grave == o )
					TempDatabaseUtils.doDiscard( player, selectedCard );
			}
		}
		
		private function scfHandTrapIsSelectable( o:* ):Boolean
		{
			return o is IndexedField;
		}
		private function scfHandTrapOnSelected( o:* ):void
		{
			var problem:String = faq.canManuallySetTrapOn( selectedCard, o as IndexedField );
			
			if ( problem == null )
				ctrl.performActionTrapSet( selectedCard, o as TrapField );
			else
				game.gui.pMsg( problem );
				
			CONFIG::sandbox
			{
				if ( player.grave == o )
					TempDatabaseUtils.doDiscard( player, selectedCard );
			}
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
			
			if ( selectedCard == null )
				return;
			
			///SAFE FLIP
			if ( f  == selectedCard.lot )
			{
				if ( selectedCard.faceDown && selectedCard.propsC.isFlippable )
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
			if ( !player.hand.containsCard( card ) )
				return false;
			return true;
		}
		
		public function canSelectCreature( card:Card ):Boolean
		{
			if ( !card.controller.isMyTurn )
				return false;
			if ( card.controller != player )
				return false;
			if ( card.statusC.hasActionExhaustion )
				return false;
			if ( card.statusC.hasSummonExhaustion )
				return false;
			if ( !card.isInPlay )
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
				selectedCard.sprite.isSelected = false;
				
				if ( player.hand.containsCard( selectedCard ) )
					player.handSprite.selectedCard = null;
			}
			
			/// /// /// /// ///
			selectedCard = card
			/// /// /// /// ///
			
			/// NEW SELECTION
			if ( selectedCard != null )
			{
				if ( player.hand.containsCard( selectedCard ) )
					player.handSprite.selectedCard = selectedCard;
					
				selectedCard.sprite.isSelected = true;
				selectedCard.sprite.addChild( cardGlow );
				cardGlow.on = true;
			}
			else
			{
				//cardGlow.removeFromParent();
				player.handSprite.selectedCard = null;
				cardGlow.on = false;
				
				var i:int;
				for ( i = 0; i < game.indexedFields.length; i++ ) 
					game.indexedFields[ i ].sprite.setGuiState( FieldSpriteGuiState.NONE );
			}
			
			///
			_updateFlag = true;
		}
		
		public function tryToSelectFieldCard( card:Card ):void
		{
			if ( card == null )
				//game.gui.pMsg( "There is no creature here" );
				selectCard( null );
			else
			if ( card.statusC.hasActionExhaustion )
				game.gui.pMsg( "This card already performed an action this turn." );
			else
			if ( card.statusC.hasSummonExhaustion )
				game.gui.pMsg( "This card cannot perform actions during the turn it was summoned." );
			else
			if ( card.controller != player )
				game.gui.pMsg( "You don't control this card." );
			else
				selectCard( card );
		}
		
		private function onCardLeaveLot( ce:CardEvents ):void 
		{
			if ( ce.card == selectedCard )
				selectCard( null );
		}
		
		// // // // //
		// BULLSHIT //
		// // // // //
		
		private function log( ...rest ):void
		{ trace.apply( null, rest ) }
	}
}