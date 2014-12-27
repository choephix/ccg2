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
		static public const MAX:uint = 20;
		static private var uid:uint = 0;
		
		
		
		public static function produceCard( id:int ):Card
		{
			uid++;
			
			var c:Card = new Card();
			
			//
			c.id = id;
			var bc:CreatureCardBehaviour;
			var bt:TrapCardBehaviour;
			
			switch ( id )
			{
				case  0:
					c.name = "Gonzales";
					setToCreature();
					bc.attack = 10;
					bc.haste = true;
					break;
				case  1:
					c.name = "Flippers";
					setToCreature();
					bc.attack = 10;
					bc.startFaceDown = true;
					bc.onCombatFlipFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							//c.field.opposingCreature.die();
							//c.field.opposingCreature.behaviourC.attack -= 5;
							c.field.opposingCreature.behaviourC.noattack = true;
						}
					}
					break;
				case  2:
					c.name = "Gasoline";
					setToTrap();
					bt.onActivateFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.die();
						}
					}
					break;
				case  3:
					c.name = "Bozo";
					setToCreature();
					bc.attack = 6;
					bc.startFaceDown = true;
					break;
				case  4:
					c.name = "Obelix";
					setToCreature();
					bc.attack = 15;
					break;
				case  5:
					c.name = "Trap-hole";
					setToTrap();
					bt.onActivateFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.die();
						}
					}
					break;
				case  6:
					c.name = "Flappy Bird";
					setToCreature();
					bc.attack = 7;
					bc.swift = true;
					break;
				case  7:
					c.name = "Big Shield";
					setToCreature();
					bc.attack = 19;
					bc.noattack = true;
					bc.nomove = true;
					break;
				case  8:
					c.name = "Smelly sock";
					setToTrap();
					bt.onActivateFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.returnToHand();
						}
					}
					break;
				case  9:
					c.name = "Stunner";
					setToTrap();
					bt.onActivateFunc = function():void {
						if ( c.field.opposingCreature != null )
						{
							c.field.opposingCreature.behaviourC.noattack = true;
						}
					}
					break;
				case 10:
					c.name = "Hulk";
					setToCreature();
					bc.attack = 14;
					bc.berserk = true;
					break;
				case 11:
					c.name = "Draw";
					setToTrap();
					bt.onActivateFunc = function():void {
						c.controller.draw();
					}
					break;
				case 12:
					c.name = "Cozmo";
					setToCreature();
					bc.attack = 8;
					break;
				case 13:
					c.name = "Hard Surprise";
					setToCreature();
					bc.attack = 17;
					bc.noattack = true;
					bc.startFaceDown = true;
					break;
				case 14:
				case 15:
				case 16:
				case 17:
				case 18:
				case 19:
				default:
					c.name = "Unnamed #"+id;
					setToCreature();
					bc.attack = 5 + Math.random() * 10;
					break;
			}
			
			function setToCreature():void
			{
				c.type = CardType.CREATURE;
				c.behaviour = bc = new CreatureCardBehaviour();
			}
			
			function setToTrap():void
			{
				c.type = CardType.TRAP;
				c.behaviour = bt = new TrapCardBehaviour();
			}
			
			//
			
			c.initialize();
			return c;
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