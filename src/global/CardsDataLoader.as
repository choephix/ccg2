package global 
{
	import chimichanga.debug.logging.error;
	import dev.Temp;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.events.Event;
	
	CONFIG::desktop
	{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	}
	/**
	 * ...
	 * @author choephix
	 */
	public class CardsDataLoader 
	{
		CONFIG::desktop
		public static const URL:String = "http://dev.thechoephix.com/ccg2/editor/read.php";
		
		CONFIG::web
		public static const URL:String = "cards.txt";
		
		private var _loader:URLLoader = new URLLoader();
		private var _busy:Boolean;
		
		private var _cards:Vector.<CardPrimalData> = new Vector.<CardPrimalData>();
		private var _numCards:int;
		
		private var _data:Object;
		
		public function load( onComplete:Function ):void
		{
			if ( _busy )
			{
				error( "LOADER IS BUSY" );
				return;
			}
			_busy = true;
			
			_loader.addEventListener( Event.COMPLETE, onRequestComplete );
			_loader.load( new URLRequest( URL ) );
			
			var _this:CardsDataLoader = this;
			function onRequestComplete( e:Event ):void 
			{
				_loader.removeEventListener( Event.COMPLETE, onRequestComplete );
				_busy = false;
				trace( "\nRECEIVED REMOTE DATA:\n" + _loader.data );
				
				// Populate cards primal data vector
				_data = JSON.parse( _loader.data );
				_cards.length = 0;
				var ca:Array = _data.cards as Array;
				var i:int;
				var o:Object;
				var cpd:CardPrimalData;
				for ( i = 0; i < ca.length; i++ )
				{
					o = ca[ i ];
					cpd = new CardPrimalData();
					cpd.id = o.id;
					cpd.slug = o.slug;
					cpd.name = o.name;
					cpd.description = o.desc;
					cpd.power = o.pwr;
					cpd.faction = o.fctn;
					cpd.type = o.type;
					cpd.vars = o.vars;
					_cards.push( cpd );
				}
				_numCards = _cards.length;
				
				for ( i = 0; i < _numCards; i++ )
					_cards[ i ].updatePrettyDescription( _this );
				
				try
				{
					Temp.DECK2 = _data.views[ 6 ].groups[ 1 ].cards;
					Temp.DECK1 = _data.views[ 6 ].groups[ 2 ].cards;
					Temp.DECK1.reverse();
					Temp.DECK2.reverse();
				}
				catch ( e:Error )
				{ error( e.message ) }
				
				onComplete();
			}
		}
		
		public function findBySlug( slug:String ):CardPrimalData
		{
			for ( var i:int = 0; i < _numCards; i++ ) 
				if ( _cards[ i ].slug == slug )
					return _cards[ i ];
			return null;
		}
		
		public function findByID( id:int ):CardPrimalData
		{
			for ( var i:int = 0; i < _numCards; i++ ) 
				if ( _cards[ i ].id == id )
					return _cards[ i ];
			return null;
		}
		
		public function saveBackup( data:String ):void
		{
			CONFIG::desktop
			{
				var f:File = File.desktopDirectory.resolvePath( "cards.txt" );
				var s:FileStream = new FileStream();
				s.open( f, FileMode.WRITE );
				s.writeUTFBytes( data );
				s.close();
			}
		}
		
		public function get numCards():int 
		{ return _numCards }
		
		public function get busy():Boolean 
		{ return _busy }
	}
}