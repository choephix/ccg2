package duel.cards.temp_database 
{
	import duel.cards.buffs.Buff;
	import duel.cards.Card;
	import duel.cards.properties.cardprops;
	import duel.G;
	import duel.otherlogic.OngoingEffect;
	import duel.otherlogic.SpecialEffect;
	import duel.processes.GameplayProcess;
	import duel.processes.gameprocessgetter;
	import duel.table.CardLotType;
	import duel.table.CreatureField;
	
	use namespace gameprocessgetter;
	use namespace cardprops;
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
				
				/* * */
				function( c:Card ):void ///		..C		Jane Doe
				{
					c.name = "Jane Doe";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 5;
					c.propsC.flippable = true;
				},
				/* * */
				function( c:Card ):void ///		T..		Trap-hole
				{
					c.name = "Trap-hole";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.SUMMON_COMPLETE );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.samesideCreature != null ) return false;
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSummonedField().owner ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doKill( p.getSourceCard() );
					}
					
					c.descr = "When enemy creature is summoned to he opposing field and there is no friendly creature on your side of it - destroy enemy creature.";
				},
				/* * */
				function( c:Card ):void ///		.`C		Cowardly Golem
				{
					c.name = "Cowardly Golem";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 13;
					c.propsC.needTribute = true;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.watch( GameplayProcess.ATTACK );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						if ( ! c.isInPlay ) return false;
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						return true;
					}
					special.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doPutInHand( c, c.controller );
					}
					
					c.descr = "When this card is attacked - return it to your hand.";
				},
				/* * */
				function( c:Card ):void ///		..C		Eternal Bob
				{
					c.name = "Eternal Bob";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 2;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.GRAVEYARD );
					special.watch( GameplayProcess.TURN_END );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c.controller.hand.cardsCount == 0;
					}
					special.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doPutInHand( c, c.controller );
					}
					
					c.descr = "If this card is in your graveyard, the moment you have no cards in your hand - return this card to your hand.";
				},
				/* * */
				function( c:Card ):void ///		..C		Trap Diffuser
				{
					c.name = "Trap Diffuser";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 2;
					c.propsC.flippable = true;
					c.propsC.onSafeFlipFunc =
					function():void {
						TempDatabaseUtils.doDestroyTrapsRow( c.controller.opponent );
					}
					
					c.descr = "Safe-Flip: destroy all enemy traps";
				},
				/* * */
				function( c:Card ):void ///		T..		Smelly socks
				{
					c.name = "Smelly socks";
					
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
						var oc:Card = c.indexedField.opposingCreature;
						if ( oc != null )
							TempDatabaseUtils.doPutInHand( oc, oc.controller )
					}
					
					c.descr = "When enemy creature on this column attacks - return it to the opponent's hand";
				},
				/* * */
				function( c:Card ):void ///		..C		Spying Joe
				{
					c.name = "Spying Joe";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 4;
					
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
					ongoing.funcUpdate =
					function( p:GameplayProcess ):void {
						if ( !c.isInPlay ) return;
						if ( c.controller.opponent.deck.topCard == null ) return;
						c.controller.opponent.deck.topCard.faceDown = false;
					}
					
					c.descr = "While this card is in play - opponent keeps the top card in his deck face up.";
				},
				/* * */
				function( c:Card ):void ///		..C		Furious Lea
				{
					c.name = "Furious Lee";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 0;
					
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
					ongoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.basePower = c.controller.opponent.creatureCount * 2;
					}
					
					c.descr = "Base Power = 2 x number of enemy creatures in play.";
				},
				/* * */
				function( c:Card ):void ///		T..		Stun
				{
					c.name = "Stun";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					var b:Buff = Buff.generateFlagBuff( Buff.NO_ATTACK );
					var target:Card;
					
					c.propsT.persistent = true;
					
					// ACTIVATION
					c.propsT.effect.watchForActivation( GameplayProcess.ATTACK );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						c.statusT.persistenceLink = 
						target = c.indexedField.opposingCreature;
						if ( target != null )
							target.statusC.addBuff( b );
					}
					
					// DEACTIVATION
					c.propsT.effect.watchForDeactivation( GameplayProcess.TURN_START );
					c.propsT.effect.funcDeactivateCondition =
					function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					c.propsT.effect.funcDeactivate =
					function( p:GameplayProcess ):void {
						if ( target != null )
							target.statusC.removeBuff( b );
						target = null;
					}
					
					c.descr = "When opposing enemy creature attacks - stun it until the start of its controller's next turn.";
				},
				/* * */
				function( c:Card ):void ///		.`C		Dick Johnson
				{
					c.name = "Dick Johnson";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 5;
					c.propsC.needTribute = true;
					c.propsC.haste = true;
					
					c.descr = "Can attack during the same turn it was summoned.";
				},
				/* * */
				function( c:Card ):void ///		..C		Yin
				{
					c.name = "Yin";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 4;
					
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
					ongoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.basePower = buffUp() ? 6 : 4;
					}
					function buffUp():Boolean {
						if ( !c.isInPlay ) return false;
						if ( c.fieldC.adjacentCreatureLeft != null )
							if ( c.fieldC.adjacentCreatureLeft.name == "Yang" ) return true;
						if ( c.fieldC.adjacentCreatureRight != null )
							if ( c.fieldC.adjacentCreatureRight.name == "Yang" ) return true;
						return false;
					}
					
					c.descr = "Base power = 6 while Yang is adjacent";
				},
				/* * */
				function( c:Card ):void ///		..C		Berserker
				{
					c.name = "Berserker";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 6;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.watch( GameplayProcess.TURN_START_COMPLETE );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c.controller == p.getPlayer();
					}
					special.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doForceAttack( c, false );
					}
					
					c.descr = "This creature attacks automatically at the start of your turn";
				},
				/* * */
				function( c:Card ):void ///		T..		Trap-Steal
				{
					c.name = "Trap-Steal";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.ACTIVATE_TRAP_COMPLETE );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getSourceCard().controller ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doPutInHand( p.getSourceCard(), c.controller )
					}
					
					c.descr = "When opposing enemy trap's activation finishes - add that trap to your hand.";
				},
				/* * */
				function( c:Card ):void ///		.`C		Lonely Golem
				{
					c.name = "Lonely Golem";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 13;
					c.propsC.needTribute = true;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.watch( GameplayProcess.LEAVE_INDEXED_FIELD_COMPLETE, GameplayProcess.SUMMON_COMPLETE );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						if ( ! c.isInPlay ) return false;
						if ( c.owner.creatureCount > 1 ) return false;
						return true;
					}
					special.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doKill( c );
					}
					
					c.descr = "This creature dies the moment there are no other friendly creatures in play";
				},
				/* * */
				function( c:Card ):void ///		..C		Yang
				{
					c.name = "Yang";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 3;
					
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
					ongoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.basePower = buffUp() ? 7 : 3;
					}
					function buffUp():Boolean {
						if ( !c.isInPlay ) return false;
						if ( c.fieldC.adjacentCreatureLeft != null )
							if ( c.fieldC.adjacentCreatureLeft.name == "Yin" ) return true;
						if ( c.fieldC.adjacentCreatureRight != null )
							if ( c.fieldC.adjacentCreatureRight.name == "Yin" ) return true;
						return false;
					}
					
					c.descr = "Base power = 7 while Yin is adjacent";
				},
				/* * */
				function( c:Card ):void ///		..C		The Producer
				{
					c.name = "The Producer";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 0;
					
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
					ongoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.basePower = c.controller.hand.cardsCount * 1;
					}
					
					c.descr = "Base Power = 1 x cards in your hand";
				},
				/* * */
				null,
				/* * * /
				
					PLAYER 2
				
				/* * */
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 5;
					c.propsC.flippable = true;
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
					
					c.descr = "When opposing enemy creature attacks you directly - kill attacking creature";
				},
				/* * */
				function( c:Card ):void ///		.`C		Colossal Chicken
				{
					c.name = "Colossal Chicken";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 13;
					c.propsC.needTribute = true;
					
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
					ongoing.funcUpdate =
					function( p:GameplayProcess ):void {
						if ( !c.isInPlay ) return;
						if ( c.fieldC.adjacentCreatureLeft != null ) return;
						if ( c.fieldC.adjacentCreatureRight != null ) return;
						TempDatabaseUtils.doKill( c );
					}
					
					c.descr = "The moment there are no adjacent friendly creatures to this card, return it from play to your hand";
				},
				/* * */
				function( c:Card ):void ///		..C		Immortal Bob
				{
					c.name = "Immortal Bob";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 3;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.GRAVEYARD );
					special.watch( GameplayProcess.TURN_END );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c.owner.creatureCount == 0;
					}
					special.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doPutInHand( c, c.controller );
					}
					
					c.descr = "While in your graveyard, if you have no creatures in play this card returns to your hand";
				},
				/* * */
				function( c:Card ):void ///		..C		Harrassing Mia
				{
					c.name = "Harrassing Mia";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.haste = true;
					c.propsC.basePower = 1;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.watch( GameplayProcess.TURN_END );
					special.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doPutInHand( c, c.controller );
					}
					
					c.descr = "Can attack the same turn it was summoned. Return this card from play to your hand at the end of the turn";
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
						TempDatabaseUtils.doDestroyTrap( p.getSourceCard() );
					}
					
					c.descr = "When opposing enemy trap activates - negate activation and destroy trap";
				},
				/* * */
				function( c:Card ):void ///		..C		Saboteur
				{
					c.name = "Saboteur";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 3;
					c.propsC.flippable = true;
					c.propsC.onCombatFlipFunc =
					function():void {
						TempDatabaseUtils.doPutInHandTrapsRow( c.controller.opponent );
					}
					
					c.descr = "Combat-Flip: return all of your opponent's traps to their hand";
				},
				/* * */
				function( c:Card ):void ///		..C		Provoked Nina
				{
					c.name = "Provoked Nina";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 8;
					
					c.propsC.flippable = true;
					c.propsC.onSafeFlipFunc =
					function():void {
						TempDatabaseUtils.doKill( c );
					}
					
					c.descr = "Safe-Flip: Die.";
				},
				/* * */
				function( c:Card ):void ///		T..		Field Lock
				{
					c.name = "Field Lock";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.persistent = true;
					
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
					
					c.descr = "When opponent is summoning an opposing creature - lock opposing creature field until the start of your next turn. (summoning cannot continue and all tributes, if any, do not return)";
				},
				/* * */
				function( c:Card ):void ///		.`C		Compromising Bill
				{
					c.name = "Compromising Bill";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 10;
					c.propsC.needTribute = true;
					
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
					ongoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.needTribute = c.owner.creatureCount > 0;
					}
					
					c.descr = "This creature does not need a tribute if you have no creatures in play.";
				},
				/* * */
				function( c:Card ):void ///		..C		Exploding Frog
				{
					c.name = "Exploding Frog";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 2;
					
					c.propsC.flippable = true;
					c.propsC.onCombatFlipFunc =
					function():void {
						TempDatabaseUtils.doKill( c.indexedField.opposingCreature );
						TempDatabaseUtils.doKill( c.fieldC.adjacentCreatureLeft );
						TempDatabaseUtils.doKill( c.fieldC.adjacentCreatureRight );
						TempDatabaseUtils.doKill( c );
					}
					
					c.descr = "Combat-Flip: Die. Destroy opposing enemy creature and adjacent friendly creatures if any.";
				},
				/* * */
				function( c:Card ):void ///		..C		Taunter
				{
					c.name = "Taunter";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 5;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.watch( GameplayProcess.TURN_START_COMPLETE );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.opposingCreature == null ) return false;
						return c.controller.opponent == p.getPlayer();
					}
					special.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doForceAttack( c.indexedField.opposingCreature, false );
					}
					
					c.descr = "Opposing enemy creatures attack automatically at the start of the enemy turn";
				},
				/* * */
				function( c:Card ):void ///		T..		Fatal Sacrifice
				{
					c.name = "Fatal Sacrifice";
					
					TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
					
					c.propsT.effect.watchForActivation( GameplayProcess.ATTACK );
					c.propsT.effect.funcActivateCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c.indexedField.index != p.getIndex() ) return false;
						if ( c.controller.opponent != p.getAttacker().controller ) return false;
						if ( c.indexedField.opposingCreature != null ) return false;
						if ( c.indexedField.samesideCreature != null ) return false;
						return true;
					}
					c.propsT.effect.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doKill( c.indexedField.opposingCreature );
						TempDatabaseUtils.doKill( c.indexedField.samesideCreature );
					}
					
					c.descr = "When opposing creature attacks your creature - destroy both creatures";
				},
				/* * */
				function( c:Card ):void ///		.`C		The Black Hood
				{
					c.name = "The Black Hood";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 15;
					c.propsC.needTribute = true;
					
					c.propsC.summonCondition = 
					function( f:CreatureField ):Boolean {
						return c.controller.creatureCount >= 3;
					}
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.watch( GameplayProcess.SUMMON );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c == p.getSourceCard();
					}
					special.funcActivate =
					function( p:GameplayProcess ):void {
						TempDatabaseUtils.doKillCreaturesRow( c.controller );
					}
					
					c.descr = "Cannot be summoned while you have less than 3 creatures in play. Destroy all other friendly creatures when summoned.";
				},
				/* * */
				function( c:Card ):void ///		..C		Flappy Bird
				{
					c.name = "Flappy Bird";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 4;
					c.propsC.swift = true;
				},
				/* * */
				function( c:Card ):void ///		.`C		Very Social Fiend
				{
					c.name = "Very Social Fiend";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 0;
					c.propsC.needTribute = true;
					
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
					ongoing.funcUpdate =
					function( p:GameplayProcess ):void {
						c.propsC.basePower = c.owner.creatureCount * 4;
					}
					
					c.descr = "Base power = number of friendly creatures in play x 4.";
				},
				/* * */
				null,
				/* * * /
				
					BOTH PLAYERS
				
				/* * */
				function( c:Card ):void ///		..C		John Doe
				{
					c.name = "John Doe";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 5;
					c.propsC.flippable = true;
				},
				/* * */
				null,
			];
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
		static public const COUNT:uint = F.length;
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
	}

}