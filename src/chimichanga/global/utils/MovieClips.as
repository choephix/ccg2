package chimichanga.global.utils
{
	import starling.display.MovieClip;
	import starling.errors.AbstractClassError;
	import starling.events.Event;
	
	
	public class MovieClips
	{
		
        /** @private */
        public function MovieClips() { throw new AbstractClassError(); }
		
		/** Remove from the stage and dispose target MovieClip as soon as it
		 * reached the end of its animation */
		public static function makeWeak( target:MovieClip ):MovieClip
		{
			target.addEventListener( Event.COMPLETE, killWeakMovieClip );
		}
		
		private static function killWeakMovieClip( e:Event ):void 
		{
			e.currentTarget.removeEventListener( Event.COMPLETE, killWeakMovieClip );
			MovieClip(e.currentTarget).removeFromParent( true );
		}
		
	}

}