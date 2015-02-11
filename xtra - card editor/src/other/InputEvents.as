package other 
{
	import starling.events.EventDispatcher;
	
	[Event(name="mouseWheel", type="other.InputEvents")] 
	[Event(name="middleClick", type="other.InputEvents")] 
	[Event(name="rightClick", type="other.InputEvents")] 
	/**
	 * ...
	 * @author choephix
	 */
	public class InputEvents extends EventDispatcher 
	{
		static public const MOUSE_WHEEL:String = "mouseWheel";
		static public const MIDDLE_CLICK:String = "middleClick";
		static public const RIGHT_CLICK:String = "rightClick";
	}
}