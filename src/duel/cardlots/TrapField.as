package duel.cardlots 
{
	import duel.table.FieldType;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapField extends Field 
	{
		private var _index:int;
		public function TrapField( index:int )
		{
			_index = index;
			super( FieldType.TRAP );
		}
		
		public function get index():int { return _index }
	}

}