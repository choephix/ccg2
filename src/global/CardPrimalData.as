package global 
{
	import chimichanga.debug.logging.error;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardPrimalData 
	{
		public static const FACTION_SCIENCE:int = 0;
		public static const FACTION_NATURE:int 	= 1;
		public static const FACTION_MAGIC:int 	= 2;
		public static const FACTION_NEUTRAL:int = 3;
		public static const FACTION_NONE:int 	= 4;
		
		public static const TYPE_CREATURE_NORMAL:int = 1;
		public static const TYPE_CREATURE_FLIPPABLE:int = 2;
		public static const TYPE_CREATURE_GRAND:int = 3;
		public static const TYPE_TRAP:int = 4;
		
		public var id:int;
		public var slug:String;
		public var name:String;
		public var description:String;
		public var power:int;
		public var faction:int;
		public var type:int;
		public var vars:Array;
		
		private var _prettyDescription:String;
		public function get prettyDescription():String { return _prettyDescription }
		
		public function updatePrettyDescription( all:CardsDataLoader ):void 
		{
			_prettyDescription = description;
		
			if ( vars == null || vars.length == 0 )
				return;
			
			var s:String;
			for ( var i:int = 0; i < vars.length; i++ )
			{
				s = vars[ i ];
				if ( s.charAt( 0 ) == "#" )
				{
					s = s.substr( 1, s.length - 1 );
					var c:CardPrimalData = all.findBySlug( s );
					if ( c == null )
					{
						s = s.toUpperCase();
						CONFIG::development
						{ error ( "card " + s + " not found!!" ) }
					}
					else
						s = c.name;
				}
				_prettyDescription = _prettyDescription.split( "%%" + i ).join( s );
			}
		}
		
		public function getVarSlug( index:int ):String
		{ 
			if ( vars.length <= index )
			{
				return slug;
				CONFIG::development
				{ throw new Error( "VAR #" + index + " NOT FOUND" ) };
			}
			return String( vars[ index ] ).substr( 1, vars[index].length - 1 );
		}
		
		public function getVarString( index:int ):String
		{ return vars.length > index ? vars[ index ] as String : "!ERROR!" }
		
		public function getVarInt( index:int ):int
		{ return vars.length > index ? int( vars[ index ] ) : 0 }
	}
}