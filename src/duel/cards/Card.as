package duel.cards
{
	import duel.cards.behaviour.CardBehaviour;
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.behaviour.TrapCardBehaviour;
	import duel.cards.CardListBase;
	import duel.display.CardSprite;
	import duel.GameEntity;
	import duel.GameEvents;
	import duel.Player;
	import duel.processes.GameplayProcess;
	import duel.table.Field;
	import duel.table.Hand;
	import duel.table.IndexedField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Card extends GameEntity
	{
		// PERSISTENT
		public var id:int;
		public var name:String;
		public var descr:String;
		public var type:CardType;
		private var _behaviour:CardBehaviour;
		
		// BATTLE
		public var owner:Player;
		public var lot:CardListBase;
		
		public var actionsRelocate:int = 0;
		public var actionsAttack:int = 0;
		public var summonedThisTurn:Boolean = false;
		
		private var _faceDown:Boolean = true;
		
		//
		public var sprite:CardSprite;
		
		//
		public function initialize():void
		{
			CONFIG::development
			{
				if ( type == null )
					throw VerifyError( "You left " + this + "'s type = NULL, you cunt." );
				if ( _behaviour == null )
					throw VerifyError( "You left " + this + "'s behaviour = NULL, you cunt." );
			}
			
			sprite = new CardSprite();
			sprite.initialize( this );
		}
		
		//
		public function onTurnEnd():void
		{
			
		}
		
		public function onTurnStart():void
		{
			if ( game.currentPlayer == controller )
				resetState();
		}
		
		// -.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'
		
		// GAMEPLAY SHIT
		
		//
		
		public function onGameProcess( p:GameplayProcess ):void
		{
			CONFIG::development { if ( p.isInterrupted ) throw new Error( "HANDLE PROCESS INTERRUPTIONS!" ) }
			
			if ( lot is Hand && behaviour.hasHandSpecial )
			{
				if ( behaviour.hasHandSpecial && behaviour.handSpecial.mustInterrupt( p ) )
				{
					p.interrupt();
					processes.prepend_InHandSpecialActivation( this );
					return;
				}
			}
			
			if ( field && field.type.isGraveyard && behaviour.hasGraveSpecial )
			{
				if ( behaviour.hasGraveSpecial && behaviour.graveSpecial.mustInterrupt( p ) )
				{
					p.interrupt();
					processes.prepend_InGraveSpecialActivation( this );
					return;
				}
			}
			
			// ONLY IN-PLAY CHECKS BEYOND THIS POINT!
			
			if ( !isInPlay )
				return;
			
			if ( p.name == GameplayProcess.TURN_START )
				onTurnStart();
			
			if ( p.name == GameplayProcess.TURN_END )
				onTurnEnd();
			
			if ( type.isTrap )
			{
				if ( behaviourT.effect.mustInterrupt( p ) )
				{
					p.interrupt();
					processes.prepend_TrapActivation( this );
					return;
				}
			}
			else
			if ( type.isCreature )
			{
				if ( behaviourC.hasInPlayOngoingEffect )
				{
					behaviourC.inplayOngoing.update( p );
				}
				if ( behaviourC.hasInPlaySpecialEffect && behaviourC.inplaySpecial.mustInterrupt( p ) )
				{
					p.interrupt();
					processes.prepend_InPlaySpecialActivation( this );
					return;
				}
			}
			
		}
		
		/// This must be called on turn start as well as when the card leaves play
		public function resetState():void
		{
			actionsRelocate = 0;
			actionsAttack = 0;
			summonedThisTurn = false;
		}
		
		// 
		
		public function die():void 
		{
			processes.prepend_Death( this );
		}
		
		public function returnToControllerHand():void 
		{
			processes.prepend_EnterHand( this, controller );
		}
		
		// -.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'
		
		// GETTERS & SETTERS - 0
		
		// GETTERS & SETTERS - 1
		
		public function get behaviour():CardBehaviour { return _behaviour }
		public function set behaviour(value:CardBehaviour):void 
		{
			_behaviour = value;
			_behaviour.card = this;
		}
		
		public function get behaviourC():CreatureCardBehaviour { return behaviour as CreatureCardBehaviour }
		public function get behaviourT():TrapCardBehaviour { return behaviour as TrapCardBehaviour }
		
		public function get field():Field { return lot as Field }
		public function get indexedField():IndexedField { return lot as IndexedField }
		public function get controller():Player { return lot == null ? null : lot.owner }
		
		public function get isInPlay():Boolean { return lot is IndexedField }
		public function get isInHand():Boolean { return lot is Hand }
		public function get isInGrave():Boolean { return field != null && field.type.isGraveyard }
		public function get isInDeck():Boolean { return field != null && field.type.isDeck }
		
		// GETTERS & SETTERS - 2
		public function get faceDown():Boolean{return _faceDown}
		public function set faceDown( value:Boolean ):void
		{
			if ( _faceDown == value )
				return;
			_faceDown = value;
		}
		
		public function get exhausted():Boolean {
			if ( summonedThisTurn && !behaviourC.haste ) return true;
			if ( behaviourC.swift ) return actionsAttack > 0 && actionsRelocate > 0;
			return actionsRelocate + actionsAttack > 0;
		}
		
		// GETTERS & SETTERS - 3
		public function get canAttack():Boolean { 
			if ( !type.isCreature ) return false;
			if ( !isInPlay ) return false;
			if ( exhausted ) return false;
			if ( behaviourC.noattack ) return false;
			return actionsAttack == 0;
		}
		public function get canRelocate():Boolean { 
			if ( !type.isCreature ) return false;
			if ( !isInPlay ) return false;
			if ( exhausted ) return false;
			if ( behaviourC.nomove ) return false;
			return actionsRelocate == 0;
		}
		
		//
		public function toString():String 
		{
			return "[" + name + "]";
		}
	}
}