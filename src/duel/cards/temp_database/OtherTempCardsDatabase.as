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
	
	public class OtherTempCardsDatabase 
	{
			
		private static function initialize():void
		{
			// // // // // // // // // // // // // // // // // // // 
		
			"CREATURE" = 
			function CREATURE( c:Card ):void
			{
				// // // THINGS THINGS THINGS
				
				c.primalData.getVarInt( 0 )
				
				// SUMMON CONDITION
				// While you have no creatures
				c.propsC.summonConditionManual = 
				c.propsC.summonConditionAutomatic = 
				function( f:CreatureField ):Boolean {
					return c.controller.creatureCount == 0;
				}
				
				
				
				// // // SAFE FLIP EFFECTS
				c.propsC.onSafeFlipFunc =
				function():void {
				}
				
				// // // OMBAT FLIP EFFECTS
				c.propsC.onCombatFlipFunc =
				function():void {
				}
				
				// // // ONGOING EFFECTS
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void {
				}
				
				// // // STICKY BUFF
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.isActive = 
				function( p:GameplayProcess ):Boolean {
				}
				buff.powerOffset =
				function( c:Card ):int {
				}
				
				// // // BUFF
					var buff:Buff = c.statusC.addNewBuff( true )
					buff.isActive = 
					function():Boolean {
					}
					buff.powerOffset =
					function( c:Card ):int {
					}
					buff.expiryCondition = 
					function( p:GameplayProcess ):Boolean {
						return p.name == GameplayProcess.TURN_END;
					}
				
				// // // TRIGGERED EFFECTS
				
				// When I am summoned
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
				}
				
				// When I leave play
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
				}
				
				// When I die
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
				}
				
				// When I attack
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
				}
				
				// When opposing enemy creature is summoned
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
				}
				
				// When your turn starts
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
				}
				
				// 
				var b:Buff = new Buff( true );
				b.cannotAttack = true;
				b.cannotRelocate = true;
				b.expiryCondition =
				function( p:GameplayProcess ):Boolean {
					return p.name == GameplayProcess.TURN_END;
				}
				
				c.propsC.onCombatFlipFunc =
				function():void {
					if ( c.indexedField.opposingCreature == null )
						return;
					c.indexedField.opposingCreature.statusC.addBuff( b );
				}
				
				// While I am in play - GLOBAL BUFF
				var gb:GlobalBuff = new GlobalBuff( c );
				gb.setEffect( c.primalData.getVarInt( 0 ), null, null, null );
				gb.appliesTo = c.faq.isFriendly;
				
				var special:SpecialEffect;
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.registerGlobalBuff( gb );
				}
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.removeGlobalBuff( gb );
				}
				
			}
			
			// // // // // // // // // // // // // // // // // // // 
			
			"TRAP" =
			function( c:Card ):void
			{
				c.propsT.effect.watchForActivation( GameplayProcess.ATTACK );
				c.propsT.effect.funcActivateCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.samesideCreature != null ) return false;
					return true;
				}
				c.propsT.effect.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			// // // // // // // // // // // // // // // // // // //
			
			F[ "____" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				c.propsC.onSafeFlipFunc =
				function():void {
				}
			}
			 
		}
		
		
		
		
		
		static public const F:Array = [
			/* * * /
			
				PLAYER 1
			
			/* * * /
			
			/* * */
			function( c:Card ):void ///		..C		Flippers
			{
				c.name = "Flippers";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 4;
				c.propsC.flippable = true;
				c.propsC.onCombatFlipFunc =
				function():void {
					if ( c.indexedField.opposingCreature == null ) return;
					TempDatabaseUtils.doPutInHand( 
						c.indexedField.opposingCreature,
						c.indexedField.opposingCreature.owner );
				}
				c.descr = "Combat-Flip: Return opposing creature to its owner's hand.";
			},
			/* * */
			function( c:Card ):void ///		T..		Super Healing
			{
				c.name = "Super Healing";
				
				TempDatabaseUtils.setToTrap( c );						// TRAP - - - - - - //
				
				c.propsT.effect.watchForActivation( GameplayProcess.DIRECT_DAMAGE );
				c.propsT.effect.funcActivateCondition =
				function( p:GameplayProcess ):Boolean {
					if ( p.getDamage() == null ) return false;
					if ( p.getDamage().source as Card == null ) return false;
					if ( Card( p.getDamage().source ).indexedField == null ) return false;
					if ( c.indexedField.index != Card( p.getDamage().source ).indexedField.index ) return false;
					if ( !c.indexedField.samesideCreatureField.isEmpty ) return false;
					return true;
				}
				c.propsT.effect.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doHeal( c.controller, p.getDamage().amount );
				}
				
				c.descr = "When you receive direct damage from an opposing card and you have no card on your own side - heal yourself instead.";
			},
			/* * */
			function( c:Card ):void ///		..C		Lonely Golem
			{
				c.name = "Lonely Golem";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 7;
				
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
			},
			/* * */
			function( c:Card ):void ///		..C		Links Tester
			{
				c.name = "Links Tester";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 7;
				
				c.propsC.summonCondition = 
				function( f:CreatureField ):Boolean {
					return c.controller.creatureCount > 0;
				}
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var f:CreatureField;
					var a:Array = []
					for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
					{
						f = c.owner.fieldsC.getAt( i );
						if ( f.isEmpty ) continue;
						if ( f.topCard == c ) continue;
						a.push( f.topCard );
					}
					if ( a.length == 0 ) return;
					c.statusC.setLifeLinks.apply( null, a );
				}
			},
			/* * */
			function( c:Card ):void ///		..C		Zig
			{
				c.name = "Zig";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 7;
				c.propsC.flippable = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return ( c.owner.grave.findByName( "Zag" ) != null );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c.owner.grave.findByName( "Zag" ), c.owner );
				}
			},
			/* * */
			function( c:Card ):void ///		..C		Zag
			{
				c.name = "Zag";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 7;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return ( c.owner.grave.findByName( "Zig" ) != null );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c.owner.grave.findByName( "Zig" ), c.owner );
				}
			},
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
				function( p:GameplayProcess ):void {
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
					if ( c.indexedField.samesideCreature != null ) return false;
					if ( c.indexedField.index != p.getIndex() ) return false;
					if ( c.controller.opponent != p.getSummonedField().owner ) return false;
					return true;
				}
				c.propsT.effect.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( p.getSourceCard() );
				}
				
				c.descr = "On opp. summon and no own cr. - kill summoned creature";
			},
			/* * */
			function ( c:Card ):void ///	..C		Caller of the Dead
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
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doResurrectCreature
						( c.controller.grave.findFirstCard( isViableTarget ), 
						c.history.lastIndexedField as CreatureField );
				}
				
				function isViableTarget( cc:Card ):Boolean {
					if ( cc == c ) return false;
					return cc.isCreature;
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
				function( p:GameplayProcess ):void {
					c.controller.fieldsC.forEachField( TempDatabaseUtils.doSpawnTokenCreatureIfEmpty );
					c.controller.opponent.fieldsC.forEachField( TempDatabaseUtils.doSpawnTokenCreatureIfEmpty );
				}
			},
			/* * */
			function( c:Card ):void ///		T..		Stunner
			{
				c.name = "Stunner";
				
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
				
				c.descr = "On opp. attack - stun attacking creature";
			},
			/* * */
			function( c:Card ):void ///		..C		Immortal Bob
			{
				c.name = "Immortal Bob";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 2;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.TURN_END );
				special.funcActivate =
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
			function( c:Card ):void ///		..C		Bozo
			{
				c.name = "Bozo";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 9;
				c.propsC.flippable = true;
			},
			/* * */
			function( c:Card ):void ///		..C		Flippers
			{
				c.name = "Flippers";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 6;
				c.propsC.flippable = true;
				c.propsC.onCombatFlipFunc =
				function():void {
					if ( c.indexedField.opposingCreature != null )
					{
						//c.indexedField.opposingCreature.returnToControllerHand();
						//return;
						
						TempDatabaseUtils.doKill( c );
						TempDatabaseUtils.doKill( c.indexedField.opposingCreature );
						return;
					}
				}
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
				
				c.descr = "Lock opposing creature field until the start of your next turn.";
			},
			/* * */
			function( c:Card ):void ///		..C		Yang
			{
				c.name = "Yang";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 5;
				
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void {
					c.propsC.basePower = buffUp() ? 15 : 5;
				}
				function buffUp():Boolean {
					if ( !c.isInPlay ) return false;
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
				c.propsC.basePower = 6;
				
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void {
					c.propsC.basePower = buffUp() ? 14 : 6;
				}
				function buffUp():Boolean {
					if ( !c.isInPlay ) return false;
					var cf:CreatureField;
					cf = CreatureField( c.indexedField ).adjacentLeft as CreatureField;
					if ( cf != null && cf.topCard != null && cf.topCard.name == "Yang" ) return true;
					cf = CreatureField( c.indexedField ).adjacentRight as CreatureField;
					if ( cf != null && cf.topCard != null && cf.topCard.name == "Yang" ) return true;
					return false;
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
				
				c.descr = "On opp. attack - return attacking creature to hand";
			},
			/* * */
			function( c:Card ):void ///		..C		Impatient Jeff
			{
				c.name = "Impatient Jeff";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 13;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.HAND );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDiscard( c.controller, c );
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
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c );
				}
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
			function( c:Card ):void ///		..C		Arch-Taunter
			{
				c.name = "Arch-Taunter";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 8;
				c.propsC.needTribute = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( !c.indexedField.opposingCreature.canAttack ) return false;
					return c.controller.opponent == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceAttack( c.indexedField.opposingCreature, false );
				}
			},
			/* * */
			function( c:Card ):void ///		..C		Ragnarok
			{
				c.name = "Ragnarok";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 0;
				c.propsC.needTribute = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ENTER_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDestroyTrapsRow( c.controller.opponent );
					TempDatabaseUtils.doDestroyTrapsRow( c.controller );
					TempDatabaseUtils.doKillCreaturesRow( c.controller.opponent );
					TempDatabaseUtils.doKillCreaturesRow( c.controller );
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.controller.lifePoints / 2, c );
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
					TempDatabaseUtils.doDestroyTrap( p.getSourceCard() );
				}
				
				c.descr = "On opp. trap activation - negate and destroy trap";
			},
			/* * */
			function( c:Card ):void ///		..C		Taunter
			{
				c.name = "Taunter";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 8;
				
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
			},
			/* * */
			function( c:Card ):void ///		..C		Berserker
			{
				c.name = "Berserker";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 9;
				
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
			},
			/* * */
			function( c:Card ):void ///		..C		Flappy Bird
			{
				c.name = "Flappy Bird";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 7;
				c.propsC.swift = true;
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
			function( c:Card ):void ///		..C		Insistent Goeff
			{
				c.name = "Insistent Goeff";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 14;
				c.propsC.needTribute = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.HAND );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInDeck( c, c.controller, false, false );
				}
			},
			/* * */
			function( c:Card ):void ///		..C		Mr Miracle
			{
				c.name = "Mr Miracle";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 0;
				c.propsC.needTribute = true;
				
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void {
					c.propsC.basePower = c.controller.opponent.creatureCount * 5;
				}
			},
			/* * */
			function( c:Card ):void ///		..C		Big Shield
			{
				c.name = "Big Shield";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 17;
				c.propsC.noAttack = true;
				c.propsC.flippable = true;
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
			function( c:Card ):void ///		..C		Random Dude
			{
				c.name = "Random Dude";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 5;
			},
			/* * */
			function( c:Card ):void ///		..C		John Doe
			{
				c.name = "John Doe";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 5;
			},
			/* * */
			function( c:Card ):void ///		..C		Jane Doe
			{
				c.name = "Jane Doe";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 5;
			},
			/* * */
			function( c:Card ):void ///		..C		Immortal Bob
			{
				c.name = "Immortal Bob";
				
				TempDatabaseUtils.setToCreature( c );					// - - - - - CREATURE //
				c.propsC.basePower = 2;
				
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
			},
			/* * */
			null,
		];
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
		static public const COUNT:uint = F.length;
		
		//  - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - //
		
		static private function doNothing( p:GameplayProcess ):void {}
	}

}