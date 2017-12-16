package editor 
{
	public class Local 
	{
		public function load( onComplete:Function ):void
		{
			
			
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
	}
}