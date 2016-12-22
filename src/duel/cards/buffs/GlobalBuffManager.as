package duel.cards.buffs 
{
	import duel.cards.Card;
	
	public class GlobalBuffManager 
	{
		public var _buffs:Vector.<GlobalBuff> = new Vector.<GlobalBuff>();
		public var _numBuffs:int = 0;
		
		public function destroy():void
		{ _buffs.length = 0 }
		
		//{ get values
		
		public function getPowerOffset( c:Card ):int
		{
			var r:int = 0;
			if ( _numBuffs > 0 ) 
				for ( var i:int = 0; i < _numBuffs; i++ )
					r += _buffs[ i ].getPowerOffset( c );
			return r;
		}
		
		public function getCannotAttack( c:Card ):Boolean
		{
			var r:Boolean = false;
			if ( _numBuffs > 0 ) 
				for ( var i:int = 0; i < _numBuffs; i++ )
					r ||= _buffs[ i ].getCannotAttack( c );
			return r;
		}
		
		public function getCannotRelocate( c:Card ):Boolean
		{
			var r:Boolean = false;
			if ( _numBuffs > 0 ) 
				for ( var i:int = 0; i < _numBuffs; i++ )
					r ||= _buffs[ i ].getCannotRelocate( c );
			return r;
		}
		
		public function getSkipTribute( c:Card ):Boolean
		{
			var r:Boolean = false;
			if ( _numBuffs > 0 ) 
				for ( var i:int = 0; i < _numBuffs; i++ )
					r ||= _buffs[ i ].getSkipTribute( c );
			return r;
		}
		
		//}
		
		//{ MANAGEMENT
		
		public function registerBuff( o:GlobalBuff ):void 
		{
			_numBuffs = _buffs.push( o );
		}
		
		public function removeBuff( o:GlobalBuff ):void
		{
			_buffs.splice( _buffs.indexOf( o ), 1 );
			_numBuffs --;
		}
		
		public function hasBuff( gb:GlobalBuff ):Boolean 
		{
			return _buffs.indexOf( gb ) > -1;
		}
		
		//}
		
	}

}