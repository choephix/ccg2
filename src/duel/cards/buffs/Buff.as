package duel.cards.buffs 
{
	import duel.cards.Card;
	/**
	 * ...
	 * @author choephix
	 */
	public class Buff 
	{
		public var active:Boolean;
		public var hidden:Boolean;
		
		// : : : VALUES : : : 
		public var powerOffset:*;
		public var cannotAttack:*;
		public var cannotRelocate:*;
		public var skipTribute:*;
		
		//
		private var _description:String;
		private var _name:String;
		private var _isWeak:Boolean;
		
		public function Buff( name:String, description:String = "", destroyOutOfPlay:Boolean = false ) 
		{
			_name = name;
			_description = description;
			_isWeak = destroyOutOfPlay;
			active = true;
		}
		
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