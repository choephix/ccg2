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
		private var _description:String = "";
		private var _vars:Array = [];
		public var power:int = 0;
		public var type:int = 0;
		public var faction:Faction = null;
		private var _tags:Array = [];
		
		public var mark:uint;
		private var _prettyDescription:String = "";
		
		//
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
				_slug = _name.replace( new RegExp( / /g ), "_" );
				
			_slug = _slug
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
		
		public function updatePrettyDescription():void 
		{
			if ( vars == null )
				return;
			
			_prettyDescription = _description;
			var s:String;
			for ( var i:int = 0; i < vars.length; i++ )
			{
				s = vars[ i ];
				if ( s.charAt( 0 ) == "#" )
				{
					var c:Card = Space.findCardBySlug( s.substr( 1, s.length - 1 ) );
					s = c != null ? c.data.name : "!ERROR!";
				}
				_prettyDescription = _prettyDescription.split( "%%" + i ).join( s );
			}
		}
		
		//
		
		public function get slug():String 
		{ return _slug }
		
		public function set slug(value:String):void 
		{
			_slug = value;
			updateNameAndSlug();
		}
		
		public function get name():String 
		{ return _name }
		
		public function set name(value:String):void 
		{
			_name = value;
			updateNameAndSlug();
		}
		
		public function get vars():Array 
		{
			return _vars;
		}
		
		public function set vars(value:Array):void 
		{
			_vars = value.filter( testVar );
			updatePrettyDescription();
		}
		
		public function get description():String 
		{
			return _description;
		}
		
		public function set description(value:String):void 
		{
			_description = value;
			updatePrettyDescription();
		}
		
		public function get prettyDescription():String
		{
			return _prettyDescription;
		}
		
		public function get tags():Array 
		{
			return _tags;
		}
		
		public function set tags(value:Array):void 
		{
			_tags = value.filter( testTag );
		}
		
		//
		public function clone( id:int ):CardData 
		{
			var r:CardData = new CardData();
			r.id = id;
			r.name = name;
			r.slug = slug;
			r.vars = vars;
			r.description = description;
			r.power = power;
			r.type = type;
			r.faction = faction;
			r.tags = tags;
			return r;
		}
		
		//
		private static function testTag( tag:String, index:int, a:Array ):Boolean
		{ return Boolean( tag ) && tag.length > 0 }
		private static function testVar( val:String, index:int, a:Array ):Boolean
		{ return Boolean( val ) && val.length > 0 }
	}
}