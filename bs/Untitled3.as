import duel.cards.temp_database.TempDatabaseUtils;
import duel.table.CardLotType;























				function( c:Card ):void ///		..C		Gonzales
				{
					c.name = "Gonzales";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 3;
					c.propsC.haste = true;
				},
				/* * */
				null,
				/* * * /
				
					PLAYER 2
				
				/* * */
				null,
				/* * * /
				
					BOTH PLAYERS
				
				/* * */
				function( c:Card ):void ///		..C		Obelix
				{
					c.name = "Obelix";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 14;
				},
				/* * */
				function( c:Card ):void ///		..C		Bro
				{
					c.name = "Bro";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 13;
					c.propsC.haste = true;
				},
				/* * */
				function( c:Card ):void ///		..C		Hulk
				{
					c.name = "Hulk";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 16;
					c.propsC.needTribute = true;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #1";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #2";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #3";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #4";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #5";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #6";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 8;
				},
				/* * */
				
				
				
				
				
				
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.allowIn( CardLotType.GRAVEYARD );
					special.allowIn( CardLotType.HAND );
				
				
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
				
				
				
				
						TempDatabaseUtils.doPutInHand( c.owner.grave.findByName( "Zag" ), c.owner );
						
						TempDatabaseUtils.doPutInHand( c, c.controller );
						
						TempDatabaseUtils.doKill( c );
				
						TempDatabaseUtils.doKill( p.getSourceCard() );
				
						TempDatabaseUtils.doKill( p.getAttacker() );
				
						TempDatabaseUtils.doDiscard( c.controller, c );
				
						c.indexedField.opposingCreatureField.addLock();
						c.indexedField.opposingCreatureField.removeLock();
				
						TempDatabaseUtils.doForceAttack( c.indexedField.opposingCreature, false );
						
						
						
						TempDatabaseUtils.doDestroyTrapsRow( c.controller.opponent );
						TempDatabaseUtils.doDestroyTrapsRow( c.controller );
						TempDatabaseUtils.doKillCreaturesRow( c.controller.opponent );
						TempDatabaseUtils.doKillCreaturesRow( c.controller );
						TempDatabaseUtils.doDealDirectDamage( c.controller, c.controller.lifePoints / 2, c );
						
						TempDatabaseUtils.doPutInHandTrapsRow( c.controller.opponent );
						
						TempDatabaseUtils.doPutToGrave( p.getSourceCard() );
						
						
						c.propsC.basePower = c.controller.opponent.creatureCount * 5;
						
						
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c == p.getSourceCard();
					}
						
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c != p.getSourceCard() ) return false;
						if ( c.controller.grave.findFirstCard( isViableTarget ) == null ) return false;
						return true;
					}
						
						
						
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						return true;
					}
						
						
						
						
						
						
						
						
						
						
						
						
						
				/** /
				function( c:Card ):void ///		..C		TEST CREATURE
				{
					c.name = "TEST TEST TEST TEST TEST";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = G.INIT_LP;
					c.propsC.haste = true;
					c.propsC.flippable = true;
					c.propsC.needTribute = true;
					
					///		_COMPLETE
					///		
					///		TURN_END		TURN_START			TURN_START_COMPLETE
					///		DRAW_CARD		DISCARD_CARD		
					///		SUMMON			ENTER_PLAY			LEAVE_PLAY
					///		ATTACK			CREATURE_DAMAGE		DIRECT_DAMAGE
					///		RELOCATE		RELOCATE_COMPLETE	DIE
					///		SET_TRAP		ACTIVATE_TRAP		ACTIVATE_TRAP_COMPLETE
					///		COMBAT_FLIP		SAFE_FLIP			ACTIVATE_SPECIAL
					
					///		inplay special
					c.propsC.inplaySpecial.watch( GameplayProcess.SUMMON );
					c.propsC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						//if ( c.indexedField.opposingCreature == null ) return false;
						//if ( c.controller.opponent != p.getPlayer() ) return false;
						return true;
					}
					c.propsC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						c.die();
					}
					
					///		grave special
					c.propsC.graveSpecial.watch( GameplayProcess.TURN_START );
					c.propsC.graveSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						c.returnToControllerHand();
					}
					
					///		grave special
					c.propsC.handSpecial.watch( GameplayProcess.TURN_END );
					c.propsC.handSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doDealDirectDamage( c.controller, 5, c );
					}
					
					///		combat-flip
					c.propsC.onCombatFlipFunc =
					function():void {
						if ( c.indexedField.opposingCreature != null )
						{
							c.die();
							c.indexedField.opposingCreature.die();
							return;
						}
					}
					
					///		safe-flip
					c.propsC.onCombatFlipFunc =
					function():void {
						if ( c.indexedField.opposingCreature != null )
						{
							c.propsC.basePower++;
							return;
						}
					}
					
					///		inplay ongoing
					c.propsC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):Boolean {
						trace ( p );
					}
				},
				/* * * / 
				function( c:Card ):void ///		..C		TEST TRAP
				{
					c.name = "TURAPO TESUTO";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.SUMMON );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						//if ( c.indexedField.index != p.getIndex() ) return false;
						//if ( c.controller.opponent != p.getSourceCard().controller ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						p.abort();
					}
					
					c.descr = ". . .";
				},
				/* * */