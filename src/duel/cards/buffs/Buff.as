package duel.cards.buffs 
{
	import duel.cards.Card;
	import duel.processes.GameplayProcess;
	
	public class Buff 
	{
		/// c:Card
		public var isActive:*;
		/// p:GameplayProccess
		public var expiryCondition:Function;
		
		// : : : VALUES : : : 
		/// c:Card
		public var powerOffset:*;
		/// c:Card
		public var cannotAttack:*;
		/// c:Card
		public var cannotRelocate:*;
		/// c:Card
		public var cannotBeTribute:*;
		/// c:Card
		public var skipTribute:*;
		
		//
		private var _isWeak:Boolean;
		
		public function Buff( destroyOutOfPlay:Boolean = false ) 
		{
			_isWeak = destroyOutOfPlay;
			isActive = true;
		}
		
		public function getMustExpire( p:GameplayProcess ):Boolean
		{ return expiryCondition == null ? false : expiryCondition( p ) }
		
		public function getIsActive( c:Card ):Boolean
		{ return isActive is Function ? isActive( c ) : Boolean( isActive ) }
		
		public function getIsWeak():Boolean
		{ return _isWeak }
		
		CONFIG::heavytest
		public function heavyTest( c:Card ):void
		{
			heavyTestProp( c, isActive, Boolean );
			heavyTestProp( c, powerOffset, int );
			heavyTestProp( c, cannotAttack, Boolean );
			heavyTestProp( c, cannotRelocate, Boolean );
			heavyTestProp( c, cannotBeTribute, Boolean );
			heavyTestProp( c, skipTribute, Boolean );
			
			if ( expiryCondition != null )
				if ( expiryCondition.length == 1 )
					//if ( expiryCondition( testProcess ) is Boolean )
						return;
					//else
						//throw TypeError( "expiryCondition must return Boolean" );
				else
					throw ArgumentError( "expiryCondition must accept exactly 1 arg of type GameplayProcess" );
		}
		CONFIG::heavytest
		public function heavyTestProp( c:Card, prop:*, type:Class ):void
		{
			if ( prop == null ) return;
			if ( prop == undefined ) return;
			if ( prop is Function )
				if ( prop.length == 1 )
					//if ( prop( c ) is type )
						return;
					//else
						//throw TypeError( prop + " must return " + type );
				else
					throw ArgumentError( prop + " must accept exactly 1 arg of type Card" );
			else
				if ( !( prop is type ) )
					throw TypeError( prop + " must be or return type " + type );
		}
		CONFIG::heavytest
		private static const testProcess:GameplayProcess = new GameplayProcess();
		
		// REUSABLE FUNCTIONS
		public static function CANNOT_ATTACK_DIRECTLY( c:Card ):Boolean
		{ return c.isInPlay && c.indexedField.opposingCreatureField.isEmpty }
	}
}