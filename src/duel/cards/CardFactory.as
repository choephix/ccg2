package duel.cards
{
	import duel.cards.behaviour.CardBehaviour;
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.behaviour.TrapCardBehaviour;
	import duel.cards.Card;
	
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
					
					setToCreature( c );
					c.behaviourC.attack = 10;
					c.behaviourC.haste = true;
				},
				function( c:Card ):void
				{
					c.name = "Bozo";
					
					setToCreature( c );
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
					c.name = "Gasoline";
					
					setToTrap( c );
					c.behaviourT.onActivateFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.die();
						}
					}
				},
				function( c:Card ):void
				{
					c.name = "Flippers";
					
					setToCreature( c );
					c.behaviourC.attack = 10;
					c.behaviourC.startFaceDown = true;
				},
				function( c:Card ):void
				{
					c.name = "Trap-hole";
					
					setToTrap( c );
					c.behaviourT.onActivateFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.die();
						}
					}
				},
				function( c:Card ):void
				{
					c.name = "Obelix";
					
					setToCreature( c );
					c.behaviourC.attack = 14;
				},
				function( c:Card ):void
				{
					c.name = "Flappy Bird";
					
					setToCreature( c );
					c.behaviourC.attack = 7;
					c.behaviourC.swift = true;
				},
				function( c:Card ):void
				{
					c.name = "Big Shield";
					
					setToCreature( c );
					c.behaviourC.attack = 14;
					c.behaviourC.noattack = true;
				},
				function( c:Card ):void
				{
					c.name = "Smelly sock";
					
					setToTrap( c );
					c.behaviourT.onActivateFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.returnToHand();
						}
					}
				},
				function( c:Card ):void
				{
					c.name = "Stunner";
					
					setToTrap( c );
					c.behaviourT.onActivateFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.behaviourC.noattack = true;
						}
					}
				},
				function( c:Card ):void
				{
					c.name = "Hulk";
					
					setToCreature( c );
					c.behaviourC.attack = 16;
					c.behaviourC.berserk = true;
				},
				function( c:Card ):void
				{
					c.name = "Draw";
					
					setToTrap( c );
					c.behaviourT.onActivateFunc = function():void {
						c.controller.draw();
					}
				},
				function( c:Card ):void
				{
					c.name = "Cozmo";
					
					setToCreature( c );
					c.behaviourC.attack = 8;
				},
				function( c:Card ):void
				{
					c.name = "Hard Surprise";
					
					setToCreature( c );
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
		
		public static function produceRandomCard():Card
		{
			uid++;
			var c:Card = new Card();
			//
			c.id = Math.random() * int.MAX_VALUE;
			c.type = chance( .67 ) ? CardType.CREATURE : CardType.TRAP;
			if ( c.type == CardType.CREATURE )
			{
				var b:CreatureCardBehaviour = new CreatureCardBehaviour();
				// true false
				b.haste		= chance( .3 );
				b.noattack	= chance( .1 );
				b.nomove	= chance( .1 );
				b.swift		= chance( .1 );
				b.berserk	= chance( .2 );
				//
				b.attack = 10 + Math.random() * 10;
				b.startFaceDown = chance( .27 );
				c.behaviour = b;
				c.name = "Creature "+uid+"";
				//c.name = "#" + uid + " Creature";
			}
			else
			if ( c.type == CardType.TRAP )
			{
				c.behaviour = new TrapCardBehaviour();
				c.name = "Trap "+uid+"";
				//c.name = "#" + uid + " Trap";
			}
			//
			c.initialize();
			return c;
		}
		
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}

}