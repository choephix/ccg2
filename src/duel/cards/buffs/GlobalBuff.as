package duel.cards.buffs 
{
	import duel.cards.Card;
	/**
	 * ...
	 * @author choephix
	 */
	public class GlobalBuff 
	{
		// : : : VALUES : : : 
		private var _powerOffset:*;
		private var _cannotAttack:*;
		private var _cannotRelocate:*;
		private var _skipTribute:*;
		
		/// c:Card
		public var appliesTo:Function = APPLIES_TO_ALL;
		public var isActive:Function = null;
		public var source:Card;
		
		public function GlobalBuff( source:Card )
		{
			this.source = source;
			this.isActive = source.faq.amInPlay;
		}
		
		public function setEffect( powerOffset:* = null, cannotAttack:* = null, cannotRelocate:* = null, skipTribute:* = null ):void
		{
			_powerOffset 	= powerOffset;
			_cannotAttack 	= cannotAttack;
			_cannotRelocate = cannotRelocate;
			_skipTribute 	= skipTribute;
		}
		
		public function getPowerOffset( c:Card ):int
		{
			if ( !isActive() ) return 0;
			if ( !appliesTo( c ) ) return 0;
			return _powerOffset is Function ? _powerOffset( c ) : int( _powerOffset )
		}
		
		public function getCannotAttack( c:Card ):Boolean
		{
			if ( !isActive() ) return false;
			if ( !appliesTo( c ) ) return false;
			return _cannotAttack is Function ? _cannotAttack( c ) : Boolean( _cannotAttack )
		}
		
		public function getCannotRelocate( c:Card ):Boolean
		{
			if ( !isActive() ) return false;
			if ( !appliesTo( c ) ) return false;
			return _cannotRelocate is Function ? _cannotRelocate( c ) : Boolean( _cannotRelocate )
		}
		
		public function getSkipTribute( c:Card ):Boolean
		{ 
			if ( !isActive() ) return false;
			if ( !appliesTo( c ) ) return false;
			return _skipTribute is Function ? _skipTribute( c ) : Boolean( _skipTribute );
		}
		
		//
		private static function APPLIES_TO_ALL( c:Card ):Boolean { return true }
	}
}