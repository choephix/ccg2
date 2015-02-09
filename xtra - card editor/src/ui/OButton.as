package ui
{
	import starling.display.Button;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class OButton extends Button
	{
		public function OButton( text:String = "", callback:Function = null )
		{
			super( App.assets.getTexture( "b" ), text, null );
			alignPivot();
			if ( callback != null )
				addEventListener( Event.TRIGGERED, callback );
		}
	}
}