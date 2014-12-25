package duel 
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import starling.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameSprite extends DisplayObjectContainer
	{
		protected function get game():Game { return Game.current }
		protected function get assets():AdvancedAssetManager{ return App.assets }
	}

}