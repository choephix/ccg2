package duel.cards
{
	import duel.cards.behaviour.CardBehaviour;
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.behaviour.TrapCardBehaviour;
	import duel.cards.Card;
	import duel.G;
	import duel.Game;
	import duel.Player;
	import duel.processes.Process;
	import duel.processes.ProcessInterpreter;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardFactory
	{
		static private var uid:uint = 0;
		
		static private const ARRAY:Array = [
				function( c:Card ):void ///		..C		Gonzales
				{
					c.name = "Gonzales";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 10;
					c.behaviourC.haste = true;
				},
				function( c:Card ):void ///		..C		Bozo
				{
					c.name = "Bozo";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 10;
					c.behaviourC.startFaceDown = true;
				},
				function( c:Card ):void ///		T..		Surprise Motherfucker!
				{
					c.name = "Surprise Motherfucker!";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "declareAttack" != p.name ) return false;
						if ( c.indexedField.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getAttacker( p ).controller ) return false;
						if ( !c.indexedField.samesideCreatureField.isEmpty ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						if ( c.indexedField.opposingCreature != null )
						{
							c.indexedField.opposingCreature.die();
						}
					}
					c.descr = "On opp. direct attack - kill attacking creature";
				},
				function( c:Card ):void ///		..C		Flippers
				{
					c.name = "Flippers";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 6;
					c.behaviourC.startFaceDown = true;
					c.behaviourC.onCombatFlipFunc = function():void {
						if ( c.indexedField.opposingCreature != null )
						{
							c.die();
							c.indexedField.opposingCreature.die();
							//c.indexedField.opposingCreature.behaviourC.attack -= 5;
							//c.indexedField.opposingCreature.behaviourC.noattack = true;
						}
					}
				},
				function( c:Card ):void ///		T..		Trap-hole
				{
					c.name = "Trap-hole";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "completeSummon" != p.name ) return false;
						if ( c.indexedField.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getSummonedField( p ).owner ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						if ( c.indexedField.opposingCreature != null )
						{
							c.indexedField.opposingCreature.die();
						}
					}
					c.descr = "On opp. summon - kill summoned creature";
				},
				function( c:Card ):void ///		..C		Obelix
				{
					c.name = "Obelix";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 14;
				},
				function( c:Card ):void ///		..C		Flappy Bird
				{
					c.name = "Flappy Bird";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 7;
					c.behaviourC.swift = true;
				},
				function( c:Card ):void ///		..C		Bro
				{
					c.name = "Bro";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 13;
					c.behaviourC.haste = true;
				},
				function( c:Card ):void ///		T..		No Flippers!
				{
					c.name = "No Flippers!";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "performCombatFlipEffect" != p.name ) return false;
						if ( c.indexedField.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getSourceCard( p ).controller ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						//ProcessInterpreter.getSourceCard( p ).die();
						p.abort();
					}
					c.descr = "On opp. creature combat-flip effect - negate effect";
				},
				function( c:Card ):void ///		..C		Saboteur
				{
					c.name = "Saboteur";
					
					setToCreature( c );					// - - - - - CREATURE //
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
				function( c:Card ):void ///		T..		Trap-Trap
				{
					c.name = "Trap-Trap";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "performTrapActivation" != p.name ) return false;
						if ( c.indexedField.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getSourceCard( p ).controller ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						Game.current.processes.enterGrave( ProcessInterpreter.getSourceCard( p ) );
					}
					c.descr = "On opp. trap activation - negate and destroy trap";
				},
				function( c:Card ):void ///		..C		Hulk
				{
					c.name = "Hulk";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 16;
					c.behaviourC.berserk = true;
				},
				function( c:Card ):void ///		T..		Destiny 
				{
					c.name = "Destiny, Fate, all that Shit";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "turnStart" != p.name ) return false;
						if ( c.controller != ProcessInterpreter.getPlayer( p ) ) return false;
						if ( c.controller.hand.cardsCount > 0 ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						Game.current.performDraw( c.controller, 5 );
					}
					c.descr = "On turn start and controller hand is 0 - draw 5 cards";
				},
				function( c:Card ):void ///		T..		Smelly sock
				{
					c.name = "Smelly sock";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "performAttack" != p.name ) return false;
						if ( c.indexedField.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getAttacker( p ).controller ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						if ( c.indexedField.opposingCreature != null )
						{
							c.indexedField.opposingCreature.returnToControllerHand();
						}
					}
					c.descr = "On opp. attack - return attacking creature to hand";
				},
				function( c:Card ):void ///		..C		Big Shield
				{
					c.name = "Big Shield";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 17;
					c.behaviourC.noattack = true;
					c.behaviourC.startFaceDown = true;
				},
				function( c:Card ):void ///		T..		Stunner
				{
					c.name = "Stunner";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "performAttack" != p.name ) return false;
						if ( c.indexedField.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getAttacker( p ).controller ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						if ( c.indexedField.opposingCreature != null )
						{
							c.indexedField.opposingCreature.behaviourC.noattack = true;
						}
					}
					c.descr = "On opp. attack - stun attacking creature forever\n(it's CONCEPT DEMO!)";
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #1";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #2";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #3";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #4";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #5";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void ///		..C		Random Dude
				{
					c.name = "Random Dude #6";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
			];
		static public const MAX:uint = ARRAY.length;
		
		public static function produceCard( id:int ):Card
		{
			uid++;
			
			var c:Card = new Card();
			
			c.id = id;
			ARRAY[ id ]( c );
			
			c.initialize();
			return c;
		}
		
		public static function setToCreature( c ):void
		{
			c.type = CardType.CREATURE;
			c.behaviour = new CreatureCardBehaviour();
		}
			
		public static function setToTrap( c ):void
		{
			c.type = CardType.TRAP;
			c.behaviour = new TrapCardBehaviour();
		}
		
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}

}