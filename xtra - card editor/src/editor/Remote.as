package editor 
{
	import chimichanga.debug.logging.error;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * ...
	 * @author choephix
	 */
	public class Remote 
	{
		private var loader:URLLoader;
		private var _busy:Boolean;
		private var onComplete:Function;
		
		public function Remote() 
		{
			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, onRequestComplete );
		}
		
		private function onRequestComplete( e:Event ):void 
		{
			_busy = false;
			
			trace( "\nRECEIVED REMOTE DATA:\n" + loader.data );
			
			if ( onComplete != null ) 
				onComplete( loader.data );
			this.onComplete = null;
		}
		
		public function load( onComplete:Function ):void
		{
			if ( _busy )
			{
				error( "LOADER IS BUSY" );
				return;
			}
			_busy = true;
			this.onComplete = onComplete;
			
			var request:URLRequest = new URLRequest( G.URL_BASE + G.URL_LOAD );
			loader.load( request );
		}
		
		public function save( space:Space ):void
		{
			if ( _busy )
			{
				error( "LOADER IS BUSY" );
				return;
			}
			_busy = true;
			
			var request:URLRequest = new URLRequest( G.URL_BASE + G.URL_SAVE );
			request.method = URLRequestMethod.POST;
			var vars:URLVariables = new URLVariables();
			vars[ "data" ] = space.toJson();
			request.data = vars;
			loader.load( request );
			
			trace( "\nSENT REMOTE DATA:\n" + vars[ "data" ] );
		}
		
		public function get busy():Boolean 
		{ return _busy }
	}
}