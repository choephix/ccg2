package editor 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class CardData 
	{
		public var id:int = -1;
		private var _name:String = "";
		private var _slug:String = "";
		public var description:String = "";
		public var power:int = 0;
		public var type:int = 0;
		public var faction:Faction = null;
		public var tags:Array = [];
		
		public function hasTag( txt:String):Boolean
		{ return tags.indexOf( txt ) > -1 }
		
		public function hasText( txt:String):Boolean
		{
			if ( name.toLowerCase().search( txt ) > -1 ) return true;
			if ( description.toLowerCase().search( txt ) > -1 ) return true;
			return false;
		}
		
		public function updateNameAndSlug():void 
		{
			if ( _name == "" && _slug != "" )
				_name = _slug.replace( new RegExp( /_/g ), " " );
			
			if ( _slug == "" && _name != "" )
				_slug = _name;
				
			_slug = _slug
					.replace( new RegExp( / /g ), "_" )
					.replace( new RegExp( /[^a-zA-Z_0-9]+/g ), "" )
					.toLowerCase();
			
			if ( description.length > 0 )
			{
				var s:String = int( Math.random() * int.MAX_VALUE ).toString( 36 );
				if ( _name.length == 0 )
					_name = s;
				if ( _slug.length == 0 )
					_slug = s;
			}
		}
		
		public function get name():String 
		{ return _name }
		
		public function set name(value:String):void 
		{
			if ( value == "Unnamed" ) value = "";
			_name = value;
			updateNameAndSlug();
		}
		
		public function get slug():String 
		{ return _slug }
		
		public function set slug(value:String):void 
		{
			if ( value == "unnamed" ) value = "";
			if ( value == "nameless" ) value = "";
			_slug = value;
			updateNameAndSlug();
		}
		
		public function clone( id:int ):CardData 
		{
			var r:CardData = new CardData();
			r.id = id;
			r.name = name;
			r.slug = slug;
			r.description = description;
			r.power = power;
			r.type = type;
			r.faction = faction;
			r.tags = tags;
			return r;
		}
	}
}