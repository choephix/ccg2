package duel.table {
	import duel.G;
	import duel.table.FieldType;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureField extends IndexedField
	{
		public function CreatureField( index:int )
		{ super( FieldType.CREATURE, index ) }
		
		public function get adjacentLeft():CreatureField
		{
			if ( index <= 0 ) return null;
			return owner.fieldsC[ index - 1 ];
		}
		
		public function get adjacentRight():CreatureField
		{
			if ( index < 0 ) return null;
			if ( index >= G.FIELD_COLUMNS -1 ) return null;
			return owner.fieldsC[ index + 1 ];
		}
	}
}