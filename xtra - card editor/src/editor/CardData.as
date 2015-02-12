package editor 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class CardData 
	{
		public var id:int = -1;
		public var name:String = "Unnamed";
		public var slug:String = "unnamed";
		public var description:String = "...";
		public var power:int = 0;
		public var type:int = 0;
		public var faction:Faction = null;
		public var tags:Array = [];
		
		public function hasTag( txt:String):Boolean
		{
			return tags.indexOf( txt ) > -1;
		}
		
		public function hasText( txt:String):Boolean
		{
			if ( name.toLowerCase().search( txt ) > -1 ) return true;
			if ( description.toLowerCase().search( txt ) > -1 ) return true;
			return false;
		}
	}
}