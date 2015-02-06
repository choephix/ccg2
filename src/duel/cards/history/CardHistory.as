package duel.cards.history 
{
	import duel.table.IndexedField;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardHistory 
	{
		
		public var lastIndexedField:IndexedField = null;
		
		public function get lastFieldIndex():int 
		{ return lastIndexedField == null ? -1 : lastIndexedField.index }
		
	}

}