package duel 
{
	import chimichanga.common.assets.AdvancedAssetManager;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameEntity 
	{
		protected function get game():Game { return Game.current }
		protected function get assets():AdvancedAssetManager{ return App.assets }
	}
}