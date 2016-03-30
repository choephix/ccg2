package screens.deckbuilder 
{
	import chimichanga.common.display.Sprite;
	import data.decks.DeckBean;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import global.CardPrimalData;
	import starling.display.Quad;
	import text.FakeData;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ScreenDeckbuilder extends Sprite 
	{
		public var bg:Quad;
		
		
		
		public function ScreenDeckbuilder() 
		{
			bg = new Quad( 1000, 1000, 0x162534 );
			addChild( bg );
			
			initialize();
		}
		
		public function initialize():void
		{
			var decks:Vector.<DeckBean> = loadDecks();
			
			trace ( decks );
			
			var i:int;
			for each ( var deck:DeckBean in decks )
			{
				var o:ListItem_Deck = new ListItem_Deck( trace, [deck] );
				o.x = 50;
				o.y = 50 + i * 100;
				o.commitData( deck );
				addChild( o );
				i++;
			}
			
		}
		
		public static function loadDecks():Vector.<DeckBean>
		{	
			var decks:Vector.<DeckBean> = new Vector.<DeckBean>();
			
			CONFIG::desktop
			{
				var files:Array = File.applicationDirectory.resolvePath( "decks/" ).getDirectoryListing();
				var stream:FileStream = new FileStream();
				var deckBean:DeckBean;
				
				for each ( var f:Object in files )
				{
					stream.open( File(f), FileMode.READ );
					try
					{
						deckBean = DeckBean.fromJson( stream.readUTFBytes( stream.bytesAvailable ) );
						decks.push( deckBean );
					}
					catch ( e:Error )
					{
						trace( "ERROR:" + e.message );
					}
					stream.close();
				}
				
				return decks;
			}
			
			decks.push( FakeData.DECK_TEST_1 );
			decks.push( FakeData.DECK_TEST_2 );
			decks.push( FakeData.DECK_DEMO_1 );
			
			return decks;
		}
		
	}

}