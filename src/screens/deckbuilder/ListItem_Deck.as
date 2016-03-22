package screens.deckbuilder 
{
	import chimichanga.common.display.Sprite;
	import data.decks.DeckBean;
	import starling.display.Quad;
	import starling.text.TextField;
	
	public class ListItem_Deck extends Sprite 
	{
		private var bg:Quad;
		private var tf:;
		
		public function ListItem_Deck() 
		{
			bg = new Quad( 800, 60, 0x9999CC );
			addChild( bg );
			
			tf = new TextField( 800, 69, "", "Calibri", 12, 0x335577, true );
			addChild( tf );
		}
		
		public function commitData( o:DeckBean ):void
		{
			tf.text = o.name;
		}
	}
}