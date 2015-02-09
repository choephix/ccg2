package chimichanga.debug.logging
{
	/**
	 * ...
	 * @author choephix
	 */
	
	public function log( msg:Object, condition:Boolean = true ):void
	{
		if ( condition )
			trace( msg );
	}

}