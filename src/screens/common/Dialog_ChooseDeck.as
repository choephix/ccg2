package screens.common 
{
	import chimichanga.common.display.Sprite;
	import data.decks.DeckBean;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Stage;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import global.CardPrimalData;
	import screens.deckbuilder.ListItem_Deck;
	import starling.display.Quad;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import text.FakeData;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Dialog_ChooseDeck extends Sprite 
	{
		private var callback_onDeckChosen:Function;
		
		private var bg:Quad;
		private var tf:TextField;
		private var listItems:Vector.<ListItem_Deck> = new Vector.<ListItem_Deck>();
		
		public function initialize( callback_onDeckChosen:Function, messageText:String ):void
		{
			this.callback_onDeckChosen = callback_onDeckChosen;
			
			/// VIEW
			
			bg = new Quad( 222, 500, 0x162534 );
			addChild( bg );
			
			tf = new TextField( bg.width, 50, messageText );
			tf.format.color = 0x799BB;
			addChild( tf );
			
			/// LOAD DECKS
			
			var decks:Vector.<DeckBean> = loadDecks();
			var yy:int = 50;
			for each ( var deck:DeckBean in decks )
			{
				var o:ListItem_Deck = new ListItem_Deck( callback_onDeckChosen, [deck] );
				o.x = 50;
				o.y = yy;
				o.commitData( deck );
				listItems.push( o );
				addChild( o );
				yy = o.bounds.bottom + 10;
			}
			
			bg.height = yy + 10;
			
			this.alignPivot();
		}
		
		override public function dispose():void 
		{
			callback_onDeckChosen = null;
			
			if ( listItems != null )
			{
				listItems.length = 0;
				listItems = null;
			}
			
			bg = null;
			
			super.dispose();
		}
		
		private static function loadDecks():Vector.<DeckBean>
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
		
		///
		
		public static function popOut( stage:Stage, onDeckChosen:Function, text:String = "Choose your deck" ):Dialog_ChooseDeck
		{
			var dialog:Dialog_ChooseDeck = new Dialog_ChooseDeck();
			
			dialog.initialize( __onDeckChosen_CloseDialog, text );
			
			dialog.x = stage.stageWidth  * .5;
			dialog.y = stage.stageHeight * .5;
			
			stage.addChild( dialog );
			
			
			
			dialog.alpha = 0.0;
			dialog.scaleX = .9;
			dialog.scaleY = .9;
			Starling.juggler.tween( dialog, .180, { alpha : 1.0, scaleX : 1.0, scaleY : 1.0, transition : Transitions.EASE_OUT } );
			
			function __onDeckChosen_CloseDialog( deck:DeckBean ):void
			{
				Starling.juggler.tween( dialog, .120, 
					{ 
						alpha : 0.0, 
						y : dialog.y + 60,
						//transition : Transitions.EASE_OUT,
						onComplete : onDialogDead,
						onCompleteArgs : [deck]
					} );
			}
			
			function onDialogDead( deck:DeckBean ):void
			{
				dialog.removeFromParent( true );
				onDeckChosen( deck );
			}
			
			
			
			
			return dialog;
		}
		
	}

}