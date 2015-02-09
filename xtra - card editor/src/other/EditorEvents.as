package other 
{
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author choephix
	 */
	public class EditorEvents  extends EventDispatcher 
	{
		static public const CARD_DRAG_START:String = "cardDragStart";
		static public const CARD_DRAG_STOP:String = "cardDragStop";
		static public const CARD_DRAG_UPDATE:String = "cardDragUpdate";
	}
}