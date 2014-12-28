package duel.cards
{
	import duel.cards.behaviour.CardBehaviour;
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.behaviour.TrapCardBehaviour;
	import duel.cards.Card;
	import duel.Game;
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
				function( c:Card ):void
				{
					c.name = "Gonzales";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 10;
					c.behaviourC.haste = true;
				},
				function( c:Card ):void
				{
					c.name = "Bozo";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 6;
					c.behaviourC.startFaceDown = true;
					c.behaviourC.onCombatFlipFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.die();
							//c.field.opposingCreature.behaviourC.attack -= 5;
							//c.field.opposingCreature.behaviourC.noattack = true;
						}
					}
				},
				function( c:Card ):void
				{
					c.name = "Surprise Motherfucker!";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "declareAttack" != p.name ) return false;
						if ( c.field.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getAttacker( p ).controller ) return false;
						if ( !c.field.samesideCreatureField.isEmpty ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.die();
						}
					}
					c.descr = "On opp. direct attack - kill attacking creature";
				},
				function( c:Card ):void
				{
					c.name = "Flippers";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 10;
					c.behaviourC.startFaceDown = true;
				},
				function( c:Card ):void
				{
					c.name = "Trap-hole";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "completeSummon" != p.name ) return false;
						if ( c.field.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getSummonedField( p ).owner ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.die();
						}
					}
					c.descr = "On opp. summon - kill summoned creature";
				},
				function( c:Card ):void
				{
					c.name = "Obelix";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 14;
				},
				function( c:Card ):void
				{
					c.name = "Flappy Bird";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 7;
					c.behaviourC.swift = true;
				},
				function( c:Card ):void
				{
					c.name = "Bro";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 13;
					c.behaviourC.haste = true;
				},
				function( c:Card ):void
				{
					c.name = "Smelly sock";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "performAttack" != p.name ) return false;
						if ( c.field.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getAttacker( p ).controller ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.returnToHand();
						}
					}
					c.descr = "On opp. attack - return attacking creature to hand";
				},
				function( c:Card ):void
				{
					c.name = "Stunner";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "performAttack" != p.name ) return false;
						if ( c.field.index != ProcessInterpreter.getIndex( p ) ) return false;
						if ( c.controller.opponent != ProcessInterpreter.getAttacker( p ).controller ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.behaviourC.noattack = true;
						}
					}
					c.descr = "On opp. attack - stun attacking creature forever\n\n(it's CONCEPT DEMO!)";
				},
				function( c:Card ):void
				{
					c.name = "Hulk";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 16;
					c.behaviourC.berserk = true;
				},
				function( c:Card ):void
				{
					c.name = "Draw";
					
					setToTrap( c );						// TRAP - - - - - - //
					c.behaviourT.activationConditionFunc = function( p:Process ):Boolean {
						if ( "turnStart" != p.name ) return false;
						if ( c.controller.hand.cardsCount > 0 ) return false;
						return true;
					}
					c.behaviourT.onActivateFunc = function( p:Process ):void {
						Game.current.performDraw( c.controller, 5 );
					}
					c.descr = "On turn start and controller hand is 0 - draw 5 cards";
				},
				function( c:Card ):void
				{
					c.name = "Random Dude";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void
				{
					c.name = "Big Shield";
					
					setToCreature( c );					// - - - - - CREATURE //
					c.behaviourC.attack = 17;
					c.behaviourC.noattack = true;
					c.behaviourC.startFaceDown = true;
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