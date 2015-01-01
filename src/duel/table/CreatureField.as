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
			return owner.fieldsC.getAt( index - 1 );
		}
		
		public function get adjacentRight():CreatureField
		{
			return owner.fieldsC.getAt( index + 1 );
		}
	}
}