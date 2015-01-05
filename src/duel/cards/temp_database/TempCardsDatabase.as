package duel.cards.temp_database 
{
	import duel.cards.Card;
	import duel.cards.properties.cardprops;
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
				
				/* * */
				function( c:Card ):void ///		..C		Kamikaze Pao's Apprentice
				{
					c.name = "Kamikaze Pao's Apprentice";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 9;
					c.propsC.haste = true;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.watch( GameplayProcess.ATTACK_ABORT, GameplayProcess.ATTACK_COMPLETE );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c == p.getAttacker();
					}
					special.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doKill( c );
					}
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
				function ( c:Card ):void ///		..C		Caller of the Dead
				{
					c.name = "Caller of the Dead";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 5;
					c.propsC.flippable = true;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.GRAVEYARD );
					special.watch( GameplayProcess.ENTER_GRAVE_COMPLETE );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						if ( c != p.getSourceCard() ) return false;
						if ( c.controller.grave.findFirstCard( isViableTarget ) == null ) return false;
						return true;
					}
					special.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doResurrectCreature
							( c.controller.grave.findFirstCard( isViableTarget ), 
							c.history.lastIndexedField as CreatureField );
					}
					
					function isViableTarget( cc:Card ):Boolean {
						if ( cc == c ) return false;
						return cc.type.isCreature;
					}
				},
				/* * */
				function( c:Card ):void ///		..C		Summoner
				{
					c.name = "Summoner";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 4;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.watch( GameplayProcess.SUMMON_COMPLETE );
					special.funcCondition =
					function( p:GameplayProcess ):Boolean {
						return c == p.getSourceCard();
					}
					special.funcActivate =
					function( p:GameplayProcess ):Boolean {
						c.controller.fieldsC.forEachField( TempDatabaseUtils.doSpawnTokenCreatureIfEmpty );
						c.controller.opponent.fieldsC.forEachField( TempDatabaseUtils.doSpawnTokenCreatureIfEmpty );
					}
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
						c.propsC.basePower = c.controller.hand.cardsCount * 2;
					}
				},
				/* * */
				null,
				/* * * /
				
					PLAYER 2
				
				/* * */
				function( c:Card ):void ///		..C		Kamikaze Pao
				{
					c.name = "Kamikaze Pao";
					
					TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
					c.propsC.basePower = 9;
					c.propsC.haste = true;
					
					var special:SpecialEffect;
					special = c.propsC.addTriggered();
					special.allowIn( CardLotType.CREATURE_FIELD );
					special.watch( GameplayProcess.TURN_END );
					special.funcActivate =
					function( p:GameplayProcess ):Boolean {
						TempDatabaseUtils.doKill( c );
					}
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
					c.propsC.basePower = 7;
					
					var ongoing:OngoingEffect;
					ongoing = c.propsC.addOngoing();
					ongoing.funcUpdate =
					function( p:GameplayProcess ):void {
						if ( c.controller.opponent.deck.topCard == null ) return;
						c.controller.opponent.deck.topCard.faceDown = false;
					}
				},
				/* * */
				null,
			];
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
		static public const COUNT:uint = F.length;
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
	}

}