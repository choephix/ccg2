package screens.deckbuilder 
{
	import chimichanga.common.display.Sprite;
	import data.decks.DeckBean;
	import starling.display.Button;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	
	public class ListItem_Deck extends Button 
	{
		private var callback_OnSelected:Function;
		private var callArgs_OnSelected:Array;
		
		private var bg:Quad;
		private var tf:TextField;
		
		public function ListItem_Deck( callback_OnSelected:Function, callArgs_OnSelected:Array ) 
		{
			super( App.assets.getTexture("btn"), "?" );
			
			this.callback_OnSelected = callback_OnSelected;
			this.callArgs_OnSelected = callArgs_OnSelected;
			
			textFormat.color = 0xAaBbCc;
			
			addEventListener( Event.TRIGGERED, onTriggered );
		}
		
		private function onTriggered( e:Event ):void 
		{
			callback_OnSelected.apply( null, callArgs_OnSelected );
		}
		
		public function commitData( o:DeckBean ):void
		{
			text = o.name + " (" + o.cards.length + ")";
		}
	}
}