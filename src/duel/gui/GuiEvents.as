package duel.gui
{
	import starling.events.EventDispatcher;
	
	[Event( name="cardClick",type="duel.gui.GuiEvents" )]
	[Event( name="fieldClick",type="duel.gui.GuiEvents" )]
	[Event( name="cardFocus",type="duel.gui.GuiEvents" )]
	[Event( name="cardUnfocus",type="duel.gui.GuiEvents" )]
	/**
	 * ...
	 * @author choephix
	 */
	public class GuiEvents extends EventDispatcher
	{
		
		static public const CARD_FOCUS:String = "cardFocus";
		static public const CARD_UNFOCUS:String = "cardUnfocus";
		static public const CARD_CLICK:String = "cardClick";
		static public const FIELD_CLICK:String = "fieldClick";
		
		
		
	}
}