package duel.cards.temp_database 
{
	import duel.cards.Card;
	import duel.Damage;
	import duel.DamageType;
	import duel.G;
	import duel.otherlogic.TrapEffect;
	import duel.Player;
	import duel.processes.GameplayProcess;
	import duel.table.CreatureField;
	/**
	 * ...
	 * @author choephix
	 */
	public class TempCardsDatabase 
	{
		static public const F:Array = [
				/* * * /
				
					PLAYER 1
				
				/* * * /
				function( c:Card ):void ///		..C		TEST CREATURE
				{
					c.name = "TEST TEST TEST TEST TEST";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = G.INIT_LP;
					c.propsC.haste = true;
					c.propsC.startFaceDown = true;
					c.propsC.needsTribute = true;
					
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
							c.propsC.attack++;
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
				
				/* * */
				function( c:Card ):void ///		..C		The Producer
				{
					c.name = "The Producer";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 0;
					
					c.propsC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.attack = c.controller.hand.cardsCount * 2;
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Insistent Goeff
				{
					c.name = "Insistent Goeff";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 14;
					c.propsC.needsTribute = true;
					
					///		grave special
					c.propsC.handSpecial.watch( GameplayProcess.TURN_END );
					c.propsC.handSpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					c.propsC.handSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doPutInDeck( c, c.controller, false, false );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Ragnarok
				{
					c.name = "Ragnarok";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 0;
					c.propsC.needsTribute = true;
					
					c.propsC.inplaySpecial.watch( GameplayProcess.ENTER_PLAY_COMPLETE );
					c.propsC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c == p.getSourceCard();
					}
					c.propsC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doDestroyTrapsRow( c.controller.opponent );
						TempDatabaseUtils.doDestroyTrapsRow( c.controller );
						TempDatabaseUtils.doKillCreaturesRow( c.controller.opponent );
						TempDatabaseUtils.doKillCreaturesRow( c.controller );
						TempDatabaseUtils.doDealDirectDamage( c.controller, c.controller.lifePoints / 2, c );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Bozo
				{
					c.name = "Bozo";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 9;
					c.propsC.startFaceDown = true;
				},
				/* * */
				function( c:Card ):void ///		T..		No Flippers!
				{
					c.name = "No Flippers!";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.COMBAT_FLIP_EFFECT );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSourceCard().controller ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						p.abort();
					}
					
					c.descr = "On opp. creature combat-flip effect - negate effect";
				},
				/* * */
				function( c:Card ):void ///		..C		Gonzales
				{
					c.name = "Gonzales";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 3;
					c.propsC.haste = true;
				},
				/* * */
				function( c:Card ):void ///		..C		Immortal Bob
				{
					c.name = "Immortal Bob";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 2;
					
					c.propsC.graveSpecial.watch( GameplayProcess.TURN_END );
					c.propsC.graveSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doPutInHand( c, c.controller );
					}
				},
				/* * */
				function( c:Card ):void ///		T..		Surprise Motherfucker!
				{
					c.name = "Surprise Motherfucker!";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.ATTACK );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						if ( !c.indexedField.samesideCreatureField.isEmpty ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doKill( p.getAttacker() );
					}
					
					c.descr = "On opp. direct attack - kill attacking creature";
				},
				/* * */
				null,
				/* * * /
				
					PLAYER 2
				
				/* * */
				function( c:Card ):void ///		..C		Field Lock
				{
					c.name = "Field Lock";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					// ACTIVATION
					c.propsT.effect.watchForActivation( GameplayProcess.SUMMON );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.samesideCreature != null ) return false;
						if ( c.indexedField.opposingCreature != null ) return false;
						if ( c.indexedField.index != p.getSummonedField().index ) return false;
						return c.controller.opponent == p.getSummonedField().owner;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						c.indexedField.opposingCreatureField.addLock();
					}
					
					// UPDATE
					c.propsT.effect.funcUpdate =
					function( p:GameplayProcess ):void {
					}
					
					// DEACTIVATION
					c.propsT.effect.watchForDeactivation( GameplayProcess.TURN_START );
					c.propsT.effect.funcDeactivateCondition =
					function( p:GameplayProcess ):Boolean{
						return c.controller == p.getPlayer();
					}
					c.propsT.effect.funcDeactivate =
					function( p:GameplayProcess ):void {
						c.indexedField.opposingCreatureField.removeLock();
					}
					
					c.descr = "Lock opposing creature field until the start of your next turn.";
				},
				/* * */
				function( c:Card ):void ///		T..		Destiny 
				{
					c.name = "Destiny, Fate, all that Shit";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.TURN_START );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.controller != p.getPlayer() ) return false;
						if ( c.controller.hand.cardsCount > 0 ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doDraw( c.controller, 3 );
					}
					
					c.descr = "On turn start and controller hand is 0 - draw 5 cards";
				},
				/* * */
				function( c:Card ):void ///		..C		Kamikaze Pao
				{
					c.name = "Kamikaze Pao";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 9;
					c.propsC.haste = true;
					
					c.propsC.inplaySpecial.watch( GameplayProcess.TURN_END );
					c.propsC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						c.die();
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Flippers
				{
					c.name = "Flippers";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 6;
					c.propsC.startFaceDown = true;
					c.propsC.onCombatFlipFunc =
					function():void {
						if ( c.indexedField.opposingCreature != null )
						{
							//c.indexedField.opposingCreature.returnToControllerHand();
							//return;
							
							c.die();
							c.indexedField.opposingCreature.die();
							return;
						}
					}
				},
				/* * */
				function( c:Card ):void ///		T..		Trap-Trap
				{
					c.name = "Trap-Trap";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.ACTIVATE_TRAP );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSourceCard().controller ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						p.abort();
						TempDatabaseUtils.doPutToGrave( p.getSourceCard() );
					}
					
					c.descr = "On opp. trap activation - negate and destroy trap";
				},
				/* * */
				function( c:Card ):void ///		T..		Trap-hole
				{
					c.name = "Trap-hole";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.SUMMON_COMPLETE );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSummonedField().owner ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doKill( p.getSourceCard() );
					}
					
					c.descr = "On opp. summon - kill summoned creature";
				},
				/* * */
				function( c:Card ):void ///		..C		Flappy Bird
				{
					c.name = "Flappy Bird";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 7;
					c.propsC.swift = true;
				},
				/* * */
				null,
				/* * * /
				
					BOTH PLAYERS
				
				/* * */
				function( c:Card ):void ///		..C		Spying Joe
				{
					c.name = "Spying Joe";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 7;
					
					c.propsC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):void {
						if ( c.controller.opponent.deck.topCard == null ) return;
						c.controller.opponent.deck.topCard.faceDown = false;
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Taunter
				{
					c.name = "Taunter";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 8;
					
					c.propsC.inplaySpecial.watch( GameplayProcess.TURN_START_COMPLETE );
					c.propsC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.opposingCreature == null ) return false;
						return c.controller.opponent == p.getPlayer();
					}
					c.propsC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doForceAttack( c.indexedField.opposingCreature, false );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Berserker
				{
					c.name = "Berserker";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 9;
					
					c.propsC.inplaySpecial.watch( GameplayProcess.TURN_START_COMPLETE );
					c.propsC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					c.propsC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doForceAttack( c, false );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Mr Miracle
				{
					c.name = "Mr Miracle";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 0;
					c.propsC.needsTribute = true;
					
					c.propsC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.attack = c.controller.opponent.creatureCount * 5;
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Impatient Jeff
				{
					c.name = "Impatient Jeff";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 13;
					
					c.propsC.handSpecial.watch( GameplayProcess.TURN_END );
					c.propsC.handSpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					c.propsC.handSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doDiscard( c.controller, c );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Yang
				{
					c.name = "Yang";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 5;
					
					c.propsC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.attack = hasAdjacentYin() ? 15 : 5;
					}
					function hasAdjacentYin():Boolean {
						var cf:CreatureField;
						cf = CreatureField( c.indexedField ).adjacentLeft as CreatureField;
						if ( cf != null && cf.topCard != null && cf.topCard.name == "Yin" ) return true;
						cf = CreatureField( c.indexedField ).adjacentRight as CreatureField;
						if ( cf != null && cf.topCard != null && cf.topCard.name == "Yin" ) return true;
						return false;
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Yin
				{
					c.name = "Yin";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 6;
					
					c.propsC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.attack = hasAdjacentYang() ? 14 : 6;
					}
					function hasAdjacentYang():Boolean {
						var cf:CreatureField;
						cf = CreatureField( c.indexedField ).adjacentLeft as CreatureField;
						if ( cf != null && cf.topCard != null && cf.topCard.name == "Yang" ) return true;
						cf = CreatureField( c.indexedField ).adjacentRight as CreatureField;
						if ( cf != null && cf.topCard != null && cf.topCard.name == "Yang" ) return true;
						return false;
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Obelix
				{
					c.name = "Obelix";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 14;
				},
				/* * */
				function( c:Card ):void ///		..C		Bro
				{
					c.name = "Bro";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 13;
					c.propsC.haste = true;
				},
				/* * */
				function( c:Card ):void ///		..C		Saboteur
				{
					c.name = "Saboteur";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 3;
					c.propsC.startFaceDown = true;
					c.propsC.onSafeFlipFunc =
					function():void {
						TempDatabaseUtils.doPutInHandTrapsRow( c.controller.opponent );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Hulk
				{
					c.name = "Hulk";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 16;
					c.propsC.berserk = true;
				},
				/* * */
				function( c:Card ):void ///		..C		Zig
				{
					c.name = "Zig";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 7;
					c.propsC.startFaceDown = true;
					
					c.propsC.inplaySpecial.watch( GameplayProcess.TURN_END );
					c.propsC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return ( c.owner.grave.findByName( "Zag" ) != null );
					}
					c.propsC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doPutInHand( c.owner.grave.findByName( "Zag" ), c.owner );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Zag
				{
					c.name = "Zag";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 7;
					
					c.propsC.inplaySpecial.watch( GameplayProcess.TURN_END );
					c.propsC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return ( c.owner.grave.findByName( "Zig" ) != null );
					}
					c.propsC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doPutInHand( c.owner.grave.findByName( "Zig" ), c.owner );
					}
				},
				/* * */
				function( c:Card ):void ///		T..		Smelly sock
				{
					c.name = "Smelly sock";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.ATTACK );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						if ( c.indexedField.opposingCreature != null )
							c.indexedField.opposingCreature.returnToControllerHand();
					}
					
					c.descr = "On opp. attack - return attacking creature to hand";
				},
				/* * */
				function( c:Card ):void ///		..C		Big Shield
				{
					c.name = "Big Shield";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 17;
					c.propsC.noattack = true;
					c.propsC.startFaceDown = true;
				},
				/* * */
				function( c:Card ):void ///		T..		Stunner
				{
					c.name = "Stunner";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.ATTACK );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						if ( c.indexedField.opposingCreature != null )
							c.indexedField.opposingCreature.propsC.noattack = true;
					}
					
					c.descr = "On opp. attack - stun attacking creature forever\n(it's CONCEPT DEMO!)";
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #1";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #2";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #3";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #4";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #5";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #6";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.attack = 8;
				},
				/* * */
				null,
			];
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
		static public const COUNT:uint = F.length;
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
	}

}