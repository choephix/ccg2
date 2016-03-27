package data.decks 
{
	public class DeckBean 
	{
		public var name:String = "";
		public var cards:Vector.<uint> = new Vector.<uint>();
		
		public function toString():String 
		{ return "[DeckBean name=" + name + " cards=" + cards + "]"; }
		
		/// STATIC
		
		public static function fromJson( json:String ):DeckBean
		{
			var result:DeckBean = new DeckBean();
			var jsonData:Object = JSON.parse( json );
			
			result.name = jsonData["name"];
			for each ( var id:uint in jsonData["cards"] )
				result.cards.push( id );
			
			return result;
		}
	}
}