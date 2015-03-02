package duel.cards.buffs 
{
	import duel.cards.Card;
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class BuffManager 
	{
		public var _buffs:Vector.<Buff> = new Vector.<Buff>();
		public var _numBuffs:int = 0;
		public var _card:Card;
		
		public function BuffManager( card:Card ) { _card = card }
		
		//{ get values
		
		public function get powerOffset():int
		{
			var r:int = 0;
			var o:*;
			for ( var i:int = 0; i < _numBuffs; i++ )
			{
				if ( !_buffs[ i ].getIsActive() ) continue;
				o = _buffs[ i ].powerOffset;
				if ( o == null ) continue;
				r += o is Function ? o( _card ) : int( o );
			}
			return r;
		}
		
		public function get cannotAttack():Boolean
		{
			var r:Boolean = false;
			var o:*;
			for ( var i:int = 0; i < _numBuffs; i++ )
			{
				if ( !_buffs[ i ].getIsActive() ) continue;
				o = _buffs[ i ].cannotAttack;
				if ( o == null ) continue;
				r ||= o is Function ? o( _card ) : Boolean( o );
			}
			return r;
		}
		
		public function get cannotRelocate():Boolean
		{
			var r:Boolean = false;
			var o:*;
			for ( var i:int = 0; i < _numBuffs; i++ )
			{
				if ( !_buffs[ i ].getIsActive() ) continue;
				o = _buffs[ i ].cannotRelocate;
				if ( o == null ) continue;
				r ||= o is Function ? o( _card ) : Boolean( o );
			}
			return r;
		}
		
		public function get cannotBeTribute():Boolean
		{
			var r:Boolean = false;
			var o:*;
			for ( var i:int = 0; i < _numBuffs; i++ )
			{
				if ( !_buffs[ i ].getIsActive() ) continue;
				o = _buffs[ i ].cannotBeTribute;
				if ( o == null ) continue;
				r ||= o is Function ? o( _card ) : Boolean( o );
			}
			return r;
		}
		
		public function get skipTribute():Boolean
		{
			var r:Boolean = false;
			var o:*;
			for ( var i:int = 0; i < _numBuffs; i++ )
			{
				if ( !_buffs[ i ].getIsActive() ) continue;
				o = _buffs[ i ].skipTribute;
				if ( o == null ) continue;
				r ||= o is Function ? o( _card ) : Boolean( o );
			}
			return r;
		}
		
		//}
		
		//{ MANAGEMENT
		
		public function onGameProcess( p:GameplayProcess ):void 
		{
			var i:int = 0;
			while ( i < _numBuffs )
			{
				if ( _buffs[ i ].getMustExpire( p ) )
					removeBuff( _buffs[ i ] )
				else
					i++;
			}
		}
		
		public function addBuff( o:Buff ):void 
		{
			_numBuffs = _buffs.push( o );
		}
		
		public function removeBuff( o:Buff ):void
		{
			_buffs.splice( _buffs.indexOf( o ), 1 );
			_numBuffs --;
		}
		
		public function removeAllWeak():void
		{
			var i:int = 0;
			while ( i < _numBuffs )
			{
				if ( _buffs[ i ].getIsWeak() )
					removeBuff( _buffs[ i ] )
				else
					i++;
			}
		}
		
		public function hasBuff ( o:Buff ):Boolean
		{
			return _buffs.indexOf( o ) > -1;
		}
		
		public function get isEmpty():Boolean 
		{
			return _numBuffs == 0;
		}
		
		//}
		
	}

}