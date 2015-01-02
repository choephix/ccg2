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
					c.behaviourC.attack = G.INIT_LP;
					c.behaviourC.haste = true;
					c.behaviourC.startFaceDown = true;
					c.behaviourC.needsTribute = true;
					
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
					c.behaviourC.inplaySpecial.watch( GameplayProcess.SUMMON );
					c.behaviourC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						//if ( c.indexedField.opposingCreature == null ) return false;
						//if ( c.controller.opponent != p.getPlayer() ) return false;
						return true;
					}
					c.behaviourC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						c.die();
					}
					
					///		grave special
					c.behaviourC.graveSpecial.watch( GameplayProcess.TURN_START );
					c.behaviourC.graveSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						c.returnToControllerHand();
					}
					
					///		grave special
					c.behaviourC.handSpecial.watch( GameplayProcess.TURN_END );
					c.behaviourC.handSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doDealDirectDamage( c.controller, 5, c );
					}
					
					///		combat-flip
					c.behaviourC.onCombatFlipFunc =
					function():void {
						if ( c.indexedField.opposingCreature != null )
						{
							c.die();
							c.indexedField.opposingCreature.die();
							return;
						}
					}
					
					///		safe-flip
					c.behaviourC.onCombatFlipFunc =
					function():void {
						if ( c.indexedField.opposingCreature != null )
						{
							c.behaviourC.attack++;
							return;
						}
					}
					
					///		inplay ongoing
					c.behaviourC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):Boolean {
						trace ( p );
					}
				},
				/* * * / 
				function( c:Card ):void ///		..C		TEST TRAP
				{
					c.name = "TURAPO TESUTO";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.behaviourT.effect.watchForActivation( GameplayProcess.SUMMON );
					c.behaviourT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						//if ( c.indexedField.index != p.getIndex() ) return false;
						//if ( c.controller.opponent != p.getSourceCard().controller ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						p.abort();
					}
					
					c.descr = ". . .";
				},
				/* * */
				
				/* * */
				function( c:Card ):void ///		..C		Insistent Goeff
				{
					c.name = "Insistent Goeff";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 14;
					c.behaviourC.needsTribute = true;
					
					///		grave special
					c.behaviourC.handSpecial.watch( GameplayProcess.TURN_END );
					c.behaviourC.handSpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					c.behaviourC.handSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doPutInDeck( c, c.controller, false, false );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Ragnarok
				{
					c.name = "Ragnarok";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 0;
					c.behaviourC.needsTribute = true;
					
					c.behaviourC.inplaySpecial.watch( GameplayProcess.ENTER_PLAY_COMPLETE );
					c.behaviourC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c == p.getSourceCard();
					}
					c.behaviourC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						c.controller.fieldsC.forEachCreature( TempDatabaseUtils.doPutToGrave );
						c.controller.opponent.fieldsC.forEachCreature( TempDatabaseUtils.doPutToGrave );
						c.controller.fieldsT.forEachTrap( TempDatabaseUtils.doPutToGrave );
						c.controller.opponent.fieldsT.forEachTrap( TempDatabaseUtils.doPutToGrave );
						TempDatabaseUtils.doDealDirectDamage( c.controller, c.controller.lifePoints / 2, c );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Bozo
				{
					c.name = "Bozo";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 9;
					c.behaviourC.startFaceDown = true;
				},
				/* * */
				function( c:Card ):void ///		T..		No Flippers!
				{
					c.name = "No Flippers!";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.behaviourT.effect.watchForActivation( GameplayProcess.COMBAT_FLIP_EFFECT );
					c.behaviourT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSourceCard().controller ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate =
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
					c.behaviourC.attack = 3;
					c.behaviourC.haste = true;
				},
				/* * */
				function( c:Card ):void ///		..C		Immortal Bob
				{
					c.name = "Immortal Bob";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 2;
					
					c.behaviourC.graveSpecial.watch( GameplayProcess.TURN_END );
					c.behaviourC.graveSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doPutInHand( c, c.controller );
					}
				},
				/* * */
				function( c:Card ):void ///		T..		Surprise Motherfucker!
				{
					c.name = "Surprise Motherfucker!";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.behaviourT.effect.watchForActivation( GameplayProcess.ATTACK );
					c.behaviourT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						if ( !c.indexedField.samesideCreatureField.isEmpty ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate =
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
					c.behaviourT.effect.watchForActivation( GameplayProcess.SUMMON );
					c.behaviourT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.samesideCreature != null ) return false;
						if ( c.indexedField.opposingCreature != null ) return false;
						if ( c.indexedField.index != p.getSummonedField().index ) return false;
						return c.controller.opponent == p.getSummonedField().owner;
					}
					c.behaviourT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						c.indexedField.opposingCreatureField.addLock();
					}
					
					// UPDATE
					c.behaviourT.effect.funcUpdate =
					function( p:GameplayProcess ):void {
					}
					
					// DEACTIVATION
					c.behaviourT.effect.watchForDeactivation( GameplayProcess.TURN_START );
					c.behaviourT.effect.funcDeactivateCondition =
					function( p:GameplayProcess ):Boolean{
						return c.controller == p.getPlayer();
					}
					c.behaviourT.effect.funcDeactivate =
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
					
					c.behaviourT.effect.watchForActivation( GameplayProcess.TURN_START );
					c.behaviourT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.controller != p.getPlayer() ) return false;
						if ( c.controller.hand.cardsCount > 0 ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate =
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
					c.behaviourC.attack = 9;
					c.behaviourC.haste = true;
					
					c.behaviourC.inplaySpecial.watch( GameplayProcess.TURN_END );
					c.behaviourC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						c.die();
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Flippers
				{
					c.name = "Flippers";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 6;
					c.behaviourC.startFaceDown = true;
					c.behaviourC.onCombatFlipFunc =
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
					
					c.behaviourT.effect.watchForActivation( GameplayProcess.ACTIVATE_TRAP );
					c.behaviourT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSourceCard().controller ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate =
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
					
					c.behaviourT.effect.watchForActivation( GameplayProcess.SUMMON_COMPLETE );
					c.behaviourT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSummonedField().owner ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate =
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
					c.behaviourC.attack = 7;
					c.behaviourC.swift = true;
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
					c.behaviourC.attack = 7;
					
					c.behaviourC.inplayOngoing.funcUpdate =
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
					c.behaviourC.attack = 8;
					
					c.behaviourC.inplaySpecial.watch( GameplayProcess.TURN_START_COMPLETE );
					c.behaviourC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.opposingCreature == null ) return false;
						return c.controller.opponent == p.getPlayer();
					}
					c.behaviourC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doForceAttack( c.indexedField.opposingCreature );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Berserker
				{
					c.name = "Berserker";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 9;
					
					c.behaviourC.inplaySpecial.watch( GameplayProcess.TURN_START_COMPLETE );
					c.behaviourC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					c.behaviourC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doPutToGrave( c );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Mr Miracle
				{
					c.name = "Mr Miracle";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 0;
					c.behaviourC.needsTribute = true;
					
					c.behaviourC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.behaviourC.attack = c.controller.opponent.creatureCount * 5;
					}
				},
				/* * */
				function( c:Card ):void ///		..C		The Producer
				{
					c.name = "The Producer";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 0;
					
					c.behaviourC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.behaviourC.attack = c.controller.hand.cardsCount * 2;
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Impatient Jeff
				{
					c.name = "Impatient Jeff";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 13;
					
					c.behaviourC.handSpecial.watch( GameplayProcess.TURN_END );
					c.behaviourC.handSpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					c.behaviourC.handSpecial.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doDiscard( c.controller, c );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Yang
				{
					c.name = "Yang";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 5;
					
					c.behaviourC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.behaviourC.attack = hasAdjacentYin() ? 15 : 5;
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
					c.behaviourC.attack = 6;
					
					c.behaviourC.inplayOngoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.behaviourC.attack = hasAdjacentYang() ? 14 : 6;
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
					c.behaviourC.attack = 14;
				},
				/* * */
				function( c:Card ):void ///		..C		Bro
				{
					c.name = "Bro";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 13;
					c.behaviourC.haste = true;
				},
				/* * */
				function( c:Card ):void ///		..C		Saboteur
				{
					c.name = "Saboteur";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 3;
					c.behaviourC.startFaceDown = true;
					c.behaviourC.onSafeFlipFunc =
					function():void {
						var opp:Player = c.controller.opponent;
						for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
						{
							if ( opp.fieldsT[ i ].isEmpty ) continue;
							opp.fieldsT[ i ].topCard.returnToControllerHand();
						}
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Hulk
				{
					c.name = "Hulk";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 16;
					c.behaviourC.berserk = true;
				},
				/* * */
				function( c:Card ):void ///		..C		Zig
				{
					c.name = "Zig";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 7;
					c.behaviourC.startFaceDown = true;
					
					c.behaviourC.inplaySpecial.watch( GameplayProcess.TURN_END );
					c.behaviourC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return ( c.owner.grave.findByName( "Zag" ) != null );
					}
					c.behaviourC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doPutInHand( c.owner.grave.findByName( "Zag" ), c.owner );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Zag
				{
					c.name = "Zag";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 7;
					
					c.behaviourC.inplaySpecial.watch( GameplayProcess.TURN_END );
					c.behaviourC.inplaySpecial.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return ( c.owner.grave.findByName( "Zig" ) != null );
					}
					c.behaviourC.inplaySpecial.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doPutInHand( c.owner.grave.findByName( "Zig" ), c.owner );
					}
				},
				/* * */
				function( c:Card ):void ///		T..		Smelly sock
				{
					c.name = "Smelly sock";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.behaviourT.effect.watchForActivation( GameplayProcess.ATTACK );
					c.behaviourT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate =
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
					c.behaviourC.attack = 17;
					c.behaviourC.noattack = true;
					c.behaviourC.startFaceDown = true;
				},
				/* * */
				function( c:Card ):void ///		T..		Stunner
				{
					c.name = "Stunner";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.behaviourT.effect.watchForActivation( GameplayProcess.ATTACK );
					c.behaviourT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						if ( c.indexedField.opposingCreature != null )
							c.indexedField.opposingCreature.behaviourC.noattack = true;
					}
					
					c.descr = "On opp. attack - stun attacking creature forever\n(it's CONCEPT DEMO!)";
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #1";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #2";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #3";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #4";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #5";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #6";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				/* * */
				null,
			];
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
		static public const COUNT:uint = F.length;
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
	}

}