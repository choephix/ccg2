package duel.table {
	import duel.table.CardLotType;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapField extends IndexedField 
	{
		public function TrapField( index:int )
		{
			super( CardLotType.TRAP_FIELD, index );
		}
		
		//
		override public function toString():String 
		{ return "f_" + owner.id + "T" + index }
	}

}