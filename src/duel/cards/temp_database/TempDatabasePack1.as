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
	public class TempDatabasePack1 
	{
		static public const F:Array = [
				/* * * * * * * * * * *  * * * * * * /// TEST CARD YO
				function( c:Card ):void ///		..C		TEST
				{
					c.name = "TEST";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 0;
					c.behaviourC.haste = true;
					
					c.behaviourC.inplayOngoingFunc = function( p:Process ):Boolean {
						c.behaviourC.attack = c.controller.opponent.hand.cardsCount * 3;
					}
				}, 	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
				function( c:Card ):void ///		..C		Taunter
				{
					c.name = "Spying Joe";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 7;
					
					c.behaviourC.inplayOngoingFunc = function( p:GameplayProcess ):void {
						if ( c.controller.opponent.deck.topCard == null ) return;
						c.controller.opponent.deck.topCard.faceDown = false;
					}
				},
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
				function( c:Card ):void ///		..C		Pao the Confused
				{
					c.name = "Pao the Confused";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 9;
					c.behaviourC.haste = true;
					
					c.behaviourC.inplaySpecial.watch( GameplayProcess.TURN_END );
					c.behaviourC.inplaySpecial.funcActivate = function( p:GameplayProcess ):Boolean {
						c.die();
					}
				},
				function( c:Card ):void ///		..C		The Producer
				{
					c.name = "The Producer";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 0;
					
					c.behaviourC.inplayOngoingFunc = function( p:GameplayProcess ):void {
						c.behaviourC.attack = c.controller.hand.cardsCount * 2;
					}
				},
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
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #1";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #2";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #3";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #4";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #5";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #6";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
			];
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
		static public const COUNT:uint = F.length;
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
	}

}