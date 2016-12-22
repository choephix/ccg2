package chimichanga.debug.logging
{
	
	
	
	public function error( msg:Object, caller:Object = null ):void
	{
		trace( "4:", msg, caller == null ? '' : caller );
	}

}