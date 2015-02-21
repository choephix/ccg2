package global 
{
	import chimichanga.debug.logging.error;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.events.Event;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardsDataLoader 
	{
		public static const URL:String = "http://dev.thechoephix.com/ccg2/editor/read.php";
		
		private var _loader:URLLoader = new URLLoader();
		private var _busy:Boolean;
		
		private var _cards:Vector.<CardPrimalData> = new Vector.<CardPrimalData>();
		private var _numCards:int;
		
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
			
			function onRequestComplete( e:Event ):void 
			{
				_loader.removeEventListener( Event.COMPLETE, onRequestComplete );
				_busy = false;
				trace( "\nRECEIVED REMOTE DATA:\n" + _loader.data );
				
				// Populate cards primal data vector
				_cards.length = 0;
				var ca:Array = JSON.parse( _loader.data ).cards as Array;
				var o:Object;
				var cpd:CardPrimalData;
				for ( var i:int = 0; i < ca.length; i++ )
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
		
		public function get numCards():int 
		{ return _numCards }
		
		public function get busy():Boolean 
		{ return _busy }
	}
}