package duel.table {
	import duel.table.FieldType;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureField extends IndexedField
	{
		public function CreatureField( index:int )
		{
			super( FieldType.CREATURE, index );
		}
	}

}