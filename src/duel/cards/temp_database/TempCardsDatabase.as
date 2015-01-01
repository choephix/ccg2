package duel.cards.temp_database 
{
	import duel.cards.Card;
	import duel.G;
	import duel.Game;
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
				function( c:Card ):void ///		..C		TEST
				{
					c.name = "TEST";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 0;
					c.behaviourC.haste = true;
					
					c.behaviourC.inplayOngoingFunc = function( p:Process ):Boolean {
						c.behaviourC.attack = c.controller.opponent.hand.cardsCount * 3;
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
					
					c.behaviourT.effect.watch( GameplayProcess.COMBAT_FLIP_EFFECT );
					c.behaviourT.effect.funcCondition = function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSourceCard().controller ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate = function( p:GameplayProcess ):void {
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
					c.behaviourC.graveSpecial.funcActivate = function( p:GameplayProcess ):void {
						c.returnToControllerHand();
					}
				},
				/* * */
				function( c:Card ):void ///		T..		Surprise Motherfucker!
				{
					c.name = "Surprise Motherfucker!";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.behaviourT.effect.watch( GameplayProcess.ATTACK );
					c.behaviourT.effect.funcCondition = function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						if ( !c.indexedField.samesideCreatureField.isEmpty ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate = function( p:GameplayProcess ):void {
						TempDatabaseUtils.doKill( p.getAttacker() );
					}
					
					c.descr = "On opp. direct attack - kill attacking creature";
				},
				/* * */
				null,
				/* * * /
				function( c:Card ):void ///		..C		TEST
				{
					c.name = "TEST";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 0;
					c.behaviourC.haste = true;
					
					c.behaviourC.inplayOngoingFunc = function( p:Process ):Boolean {
						c.behaviourC.attack = c.controller.opponent.hand.cardsCount * 3;
					}
				},
				/* * */
				function( c:Card ):void ///		T..		Destiny 
				{
					c.name = "Destiny, Fate, all that Shit";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.behaviourT.effect.watch( GameplayProcess.TURN_START );
					c.behaviourT.effect.funcCondition = function( p:GameplayProcess ):Boolean {
						if ( c.controller != p.getPlayer() ) return false;
						if ( c.controller.hand.cardsCount > 0 ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate = function( p:GameplayProcess ):void {
						Game.current.processes.prepend_Draw( c.controller, 5 );
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
					c.behaviourC.inplaySpecial.funcActivate = function( p:GameplayProcess ):Boolean {
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
					c.behaviourC.onCombatFlipFunc = function():void {
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
					
					c.behaviourT.effect.watch( GameplayProcess.ACTIVATE_TRAP );
					c.behaviourT.effect.funcCondition = function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSourceCard().controller ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate = function( p:GameplayProcess ):void {
						p.abort();
						Game.current.processes.prepend_EnterGrave( p.getSourceCard() );
					}
					
					c.descr = "On opp. trap activation - negate and destroy trap";
				},
				/* * */
				function( c:Card ):void ///		T..		Trap-hole
				{
					c.name = "Trap-hole";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.behaviourT.effect.watch( GameplayProcess.SUMMON_COMPLETE );
					c.behaviourT.effect.funcCondition = function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSummonedField().owner ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate = function( p:GameplayProcess ):void {
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
				/* * */
				function( c:Card ):void ///		..C		Spying Joe
				{
					c.name = "Spying Joe";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 7;
					
					c.behaviourC.inplayOngoingFunc = function( p:GameplayProcess ):void {
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
					c.behaviourC.inplaySpecial.funcCondition = function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.opposingCreature == null ) return false;
						return c.controller.opponent == p.getPlayer();
					}
					c.behaviourC.inplaySpecial.funcActivate = function( p:GameplayProcess ):Boolean {
						Game.current.processes.append_Attack( c.indexedField.opposingCreature );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Berserker
				{
					c.name = "Berserker";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 9;
					
					c.behaviourC.inplaySpecial.watch( GameplayProcess.TURN_START_COMPLETE );
					c.behaviourC.inplaySpecial.funcCondition = function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					c.behaviourC.inplaySpecial.funcActivate = function( p:GameplayProcess ):Boolean {
						Game.current.processes.append_Attack( c );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Mr Miracle
				{
					c.name = "Mr Miracle";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 0;
					c.behaviourC.needsTribute = true;
					
					c.behaviourC.inplayOngoingFunc = function( p:GameplayProcess ):void {
						c.behaviourC.attack = c.controller.opponent.creatureCount * 5;
					}
				},
				/* * */
				function( c:Card ):void ///		..C		The Producer
				{
					c.name = "The Producer";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 0;
					
					c.behaviourC.inplayOngoingFunc = function( p:GameplayProcess ):void {
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
					c.behaviourC.handSpecial.funcCondition = function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					c.behaviourC.handSpecial.funcActivate = function( p:GameplayProcess ):void {
						Game.current.processes.prepend_Discard( c.controller, c );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Yang
				{
					c.name = "Yang";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 5;
					
					c.behaviourC.inplayOngoingFunc = function( p:GameplayProcess ):void {
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
					
					c.behaviourC.inplayOngoingFunc = function( p:GameplayProcess ):void {
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
					c.behaviourC.onSafeFlipFunc = function():void {
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
					c.behaviourC.inplaySpecial.funcCondition = function( p:GameplayProcess ):Boolean {
						return ( c.owner.grave.findByName( "Zag" ) != null );
					}
					c.behaviourC.inplaySpecial.funcActivate = function( p:GameplayProcess ):Boolean {
						Game.current.processes.prepend_EnterHand( c.owner.grave.findByName( "Zag" ), c.owner );
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Zag
				{
					c.name = "Zag";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 7;
					
					c.behaviourC.inplaySpecial.watch( GameplayProcess.TURN_END );
					c.behaviourC.inplaySpecial.funcCondition = function( p:GameplayProcess ):Boolean {
						return ( c.owner.grave.findByName( "Zig" ) != null );
					}
					c.behaviourC.inplaySpecial.funcActivate = function( p:GameplayProcess ):Boolean {
						Game.current.processes.prepend_EnterHand( c.owner.grave.findByName( "Zig" ), c.owner );
					}
				},
				/* * */
				function( c:Card ):void ///		T..		Smelly sock
				{
					c.name = "Smelly sock";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.behaviourT.effect.watch( GameplayProcess.ATTACK );
					c.behaviourT.effect.funcCondition = function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate = function( p:GameplayProcess ):void {
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
					
					c.behaviourT.effect.watch( GameplayProcess.ATTACK );
					c.behaviourT.effect.funcCondition = function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						return true;
					}
					c.behaviourT.effect.funcActivate = function( p:GameplayProcess ):void {
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