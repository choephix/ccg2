package editor 
{
	import chimichanga.common.display.Sprite;
	import feathers.controls.TextArea;
	import flash.text.TextFormat;
	import starling.display.Quad;
	import ui.OButton;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardThing extends SpaceObject 
	{
		static public const PADDING:Number = Card.PADDING;
		static public const BORDER:Number = 2.0;
		static public const W:Number = G.CARD_W + BORDER + BORDER;
		static public const H:Number = G.CARD_H + BORDER + BORDER;
		
		private var border:Quad;
		
		private var tTitle:TextArea;
		private var tDescr:TextArea;
		private var tExtra:TextArea;
		
		private var tagsQuad:Quad;
		private var tagsInput:TextArea;
		private var bOk:OButton;
		
		public function CardThing() 
		{
			pivotX = .5 * W;
			pivotY = .5 * H;
			
			border = new Quad( W, H, 0xFFFFFF );
			border.touchable = false;
			border.alpha = .75;
			addChild( border );
			
			Card.txtfTitle.align = "center";
			Card.txtfDescr.align = "center";
			
			tTitle = new TextArea();
			tTitle.textEditorProperties.textFormat = Card.txtfTitle;
			tTitle.x = PADDING;
			tTitle.y = 0;
			tTitle.width = G.CARD_W - PADDING - PADDING;
			tTitle.height = 22;
			addChild( tTitle );
			tTitle.validate();
			
			tDescr = new TextArea();
			tDescr.textEditorProperties.textFormat = Card.txtfDescr;
			tDescr.x = PADDING;
			tDescr.y = tTitle.y + tTitle.height;
			tDescr.width = G.CARD_W - PADDING - PADDING;
			tDescr.height = G.CARD_H - PADDING - PADDING - tDescr.y;
			tDescr.text = "...\n...\n...\n...\n...";
			addChild( tDescr );
			tDescr.validate();
			
			tagsQuad = new Quad( W, 100, 0x0 );
			tagsQuad.alpha = .60;
			tagsQuad.x = 0;
			tagsQuad.y = H;
			addChild( tagsQuad );
			
			tagsInput = new TextArea();
			tagsInput.textEditorProperties.textFormat = new TextFormat( "Lucida Console", 16, 0xFFFFFF );
			tagsInput.x = tagsQuad.x;
			tagsInput.y = tagsQuad.y;
			tagsInput.width = tagsQuad.width;
			tagsInput.height = tagsQuad.height;
			addChild( tagsInput );
			tagsInput.validate();
			
			bOk = new OButton( "OK", onButtonOk );
			bOk.x = W + 20;
			bOk.y = 20;
			addChild( bOk );
		}
		
		private function onButtonOk():void 
		{
			context.selectedCard.setSelected( false );
		}
		
		public function loadDataFrom( source:Card ):void
		{
			tTitle.text = source.data.name;
			tDescr.text = source.data.description;
			tagsInput.text = source.tags.join("\n");
		}
		
		public function saveDataTo( c:Card ):void
		{
			c.data.name = tTitle.text;
			c.data.description = tDescr.text;
			c.tags.length = 0;
			c.tags.push.apply( null, tagsInput.text.split("\n") );
			c.onDataChange();
		}
		
	}

}