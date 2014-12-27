package duel 
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import duel.gui.GuiJuggler;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameEntity 
	{
		protected function get juggler():GuiJuggler { return Game.current.juggler }
		protected function get jugglerGui():GuiJuggler { return Game.current.jugglerGui }
		protected function get jugglerStrict():GuiJuggler { return Game.current.jugglerStrict }
		protected function get game():Game { return Game.current }
		protected function get assets():AdvancedAssetManager{ return App.assets }
	}
}