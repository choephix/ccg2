package chimichanga.debug.logging
{
	
	
	public function log( msg:Object, condition:Boolean = true ):void
	{
		if ( condition )
			trace( msg );
	}

}