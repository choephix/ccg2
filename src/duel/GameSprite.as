package duel 
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import chimichanga.common.display.Sprite;
	import duel.gui.GuiJuggler;
	import starling.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameSprite extends Sprite
	{
		protected function get juggler():GuiJuggler
		{ return Game.current.juggler }
		
		protected function get jugglerGui():GuiJuggler
		{ return Game.current.jugglerGui }
		
		protected function get jugglerStrict():GuiJuggler
		{ return Game.current.jugglerStrict }
		
		protected function get game():Game
		{ return Game.current }
		
		protected function get assets():AdvancedAssetManager
		{ return App.assets }
		
		///
		
		/** Returns interlpolated value between two other. **/
		public static function lerp( a:Number, b:Number, r:Number ):Number
		{ return a + r * ( b - a ) }
		
	}

}