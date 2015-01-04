package duel.table {
	import duel.G;
	import duel.table.CardLotType;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureField extends IndexedField
	{
		public function CreatureField( index:int )
		{ super( CardLotType.CREATURE_FIELD, index ) }
		
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