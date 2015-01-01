package duel.table.fieldlists 
{
	import duel.table.TrapField;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapFieldsRow 
	{
		private var _list:Vector.<TrapField> = new Vector.<TrapField>();
		private var _count:int = 0;
		
		public function TrapFieldsRow( count:int ) 
		{
			while ( _count < count ) 
				_count = _list.push( new TrapField( _count ) )
		}
		
		public function getAt( i:int ):TrapField 
		{ 
			if ( i < 0 ) return null;
			if ( i >= _count ) return null;
			return _list[ i ] as TrapField;
		}
		
		public function get count():int 
		{ return _count }
		
		public function get countOccupied():int
		{ 
			var r:int = 0;
			for ( var i:int = 0; i < _count; i++ ) 
				if ( !_list[ i ].isEmpty )
					r++;
			return r;
		}
		
	}

}