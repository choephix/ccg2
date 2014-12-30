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
		
		private var _faceDown:Boolean = true;
		private var _exhausted:Boolean;
		//
		public var sprite:CardSprite;
		
		//
		public function initialize():void
		{
			sprite = new CardSprite();
			sprite.initialize( this );
		}
		
		//
		public function onTurnEnd():void
		{
			
		}
		
		public function onTurnStart():void
		{
			if ( game.currentPlayer == controller ) exhausted = false;
		}
		
		// -.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'
		
		// GAMEPLAY SHIT
		
		//
		
		public function onGameProcess( p:GameplayProcess ):void
		{
			CONFIG::development { if ( p.isInterrupted ) throw new Error( "HANDLE PROCESS INTERRUPTIONS!" ) }
			
			if ( lot is Hand && behaviour.hasHandSpecial )
			{
				if ( behaviourC.hasHandSpecial && behaviour.handSpecialConditionFunc( p ) )
				{
					p.interrupt();
					processes.startChain_SpecialActivation( this, behaviour.handSpecialActivateFunc );
					return;
				}
			}
			
			if ( field && field.type.isGraveyard && behaviour.hasGraveSpecial )
			{
				if ( behaviourC.hasGraveSpecial && behaviour.graveSpecialConditionFunc( p ) )
				{
					p.interrupt();
					processes.startChain_SpecialActivation( this, behaviour.graveSpecialActivateFunc );
					return;
				}
			}
			
			// ONLY IN-PLAY CHECKS BEYOND THIS POINT!
			
			if ( !isInPlay )
				return;
			
			if ( p.name == "turnStart" )
				onTurnStart();
			
			if ( p.name == "turnEnd" )
				onTurnEnd();
			
			if ( type.isTrap )
			{
				if ( behaviourT.activationConditionMet( p ) )
				{
					p.interrupt();
					processes.startChain_TrapActivation( this );
					return;
				}
			}
			else
			if ( type.isCreature )
			{
				if ( behaviourC.hasInPlayOngoingEffect )
				{
					behaviourC.inplayOngoingFunc( p );
					return;
				}
				if ( behaviourC.hasInPlaySpecialEffect && behaviourC.inplaySpecialConditionFunc( p ) )
				{
					p.interrupt();
					processes.startChain_SpecialActivation( this, behaviourC.inplaySpecialActivateFunc );
					return;
				}
			}
			
		}
		
		// 
		
		public function die():void 
		{
			processes.startChain_death( this );
		}
		
		public function returnToControllerHand():void 
		{
			processes.enterHand( this, controller );
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
		
		// GETTERS & SETTERS - 2
		public function get faceDown():Boolean{return _faceDown}
		public function set faceDown( value:Boolean ):void
		{
			if ( _faceDown == value )
				return;
			_faceDown = value;
		}
		
		public function get exhausted():Boolean {return _exhausted}
		public function set exhausted(value:Boolean):void 
		{
			_exhausted = value;
			juggler.xtween( sprite.exhaustClock, .500, { alpha : value ? 1 : 0 } );
		}
		
		// GETTERS & SETTERS - 3
		public function get canAttack():Boolean { 
			return type.isCreature && isInPlay && !exhausted && !behaviourC.noattack
		}
		public function get canRelocate():Boolean { 
			return type.isCreature && isInPlay && !exhausted && !behaviourC.nomove
		}
		public function get canActivate():Boolean { 
			return type.isTrap && isInPlay
		}
	}
}