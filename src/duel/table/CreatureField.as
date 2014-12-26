package duel.table {
	import duel.table.FieldType;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureField extends Field
	{
		private var _index:int;
		public function CreatureField( index:int )
		{
			_index = index;
			super( FieldType.CREATURE );
		}
		
		public function get index():int { return _index }
	}

}