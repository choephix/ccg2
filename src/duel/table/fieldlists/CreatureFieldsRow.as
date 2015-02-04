package duel.table.fieldlists 
{
	import duel.table.CreatureField;
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureFieldsRow 
	{
		private var _list:Vector.<CreatureField> = new Vector.<CreatureField>();
		private var _count:int = 0;
		
		public function CreatureFieldsRow( count:int ) 
		{
			while ( _count < count )
				_count = _list.push( new CreatureField( _count ) )
		}
		
		public function getAt( i:int ):CreatureField 
		{ 
			if ( i < 0 ) return null;
			if ( i >= _count ) return null;
			return _list[ i ] as CreatureField;
		}
		
		public function forEachCreature( f:Function ):void
		{ 
			for ( var i:int = 0; i < _count; i++ )
			{
				if ( _list[ i ].isEmpty )
					continue;
				
				_list[ i ].forEachCard( f );
			}
		}
		
		public function forEachField( f:Function ):void
		{ 
			for ( var i:int = 0; i < _count; i++ )
				f( _list[ i ] );
		}
		
		public function hasAnyFieldThat( f:Function ):Boolean 
		{
			for ( var i:int = 0; i < _count; i++ )
				if ( f( _list[ i ] ) )
					return true;
			return false;
		}
		
		public function get count():int 
		{ return _count }
		
		public function get countOccupied():int
		{ 
			var r:int = 0;
			for ( var i:int = 0; i < _count; i++ ) 
				if ( _list[ i ].topCard != null && _list[ i ].topCard.isCreature )
					r++;
			return r;
		}
		
	}

}