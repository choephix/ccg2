package duel.cards.buffs 
{
	import duel.cards.Card;
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class Buff 
	{
		public var isActive:*;
		/// 
		public var expiryCondition:Function;
		
		// : : : VALUES : : : 
		public var powerOffset:*;
		public var cannotAttack:*;
		public var cannotRelocate:*;
		public var cannotBeTribute:*;
		public var skipTribute:*;
		
		//
		private var _description:String;
		private var _name:String;
		private var _isWeak:Boolean;
		
		public function Buff( destroyOutOfPlay:Boolean = false ) 
		{
			_name = "";
			_description = "";
			_isWeak = destroyOutOfPlay;
			isActive = true;
		}
		
		public function getMustExpire( p:GameplayProcess ):Boolean
		{ return expiryCondition == null ? false : expiryCondition( p ) }
		
		public function getIsActive():Boolean
		{ return isActive is Function ? isActive() : Boolean( isActive ) }
		
		public function getIsWeak():Boolean
		{ return _isWeak }
		
		public function getName():String 
		{ return _name }
		
		public function getDescription():String 
		{ return _name }
		
		// REUSABLE FUNCTIONS
		public static function CANNOT_ATTACK_DIRECTLY( c:Card ):Boolean
		{ return c.isInPlay && c.indexedField.opposingCreatureField.isEmpty }
	}
}