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
		
		private var pad:Quad;
		
		private var tTitle:TextArea;
		private var tDescr:TextArea;
		private var tExtra:TextArea;
		private var iFaction:OButton;
		private var iType:OButton;
		
		private var tagsQuad:Quad;
		private var tagsInput:TextArea;
		private var bOk:OButton;
		
		private var _faction:Faction;
		private var _type:int;
		
		public function CardThing()
		{
			pivotX = .5 * G.CARD_W;
			pivotY = .5 * G.CARD_H;
			
			pad = new Quad( W, H, 0xFFFFFF );
			pad.x = -BORDER;
			pad.y = -BORDER;
			pad.touchable = false;
			pad.alpha = .90;
			addChild( pad );
			
			Card.txtfTitle.align = "center";
			Card.txtfDescr.align = "center";
			
			
			
			tTitle = new TextArea();
			tTitle.textEditorProperties.textFormat = Card.txtfTitle;
			tTitle.width = G.CARD_W * 2.0;
			tTitle.height = 22;
			tTitle.x = -G.CARD_W * .5;
			tTitle.y = 0;
			addChild( tTitle );
			tTitle.validate();
			
			tDescr = new TextArea();
			tDescr.textEditorProperties.textFormat = Card.txtfDescr;
			tDescr.x = PADDING;
			tDescr.y = tTitle.y + tTitle.height;
			tDescr.width = G.CARD_W - PADDING - PADDING;
			tDescr.height = G.CARD_H - PADDING - PADDING - tDescr.y;
			tDescr.text = "...";
			addChild( tDescr );
			tDescr.validate();
			
			tExtra = new TextArea();
			tExtra.textEditorProperties.textFormat = Card.txtfExtra;
			tExtra.width = 100;
			tExtra.height = 50;
			tExtra.x = 0;
			tExtra.y = G.CARD_H - 40;
			addChild( tExtra );
			tExtra.validate();
			
			iFaction = new OButton( "", onButtonChangeFaction );
			iFaction.x = G.CARD_W - PADDING;
			iFaction.y = 10;
			iFaction.scaleX = .5;
			iFaction.scaleY = .5;
			addChild( iFaction );
			
			iType = new OButton( "", onButtonChangeType );
			iType.x = PADDING;
			iType.y = 10;
			iType.scaleX = .5;
			iType.scaleY = .5;
			addChild( iType );
			
			
			
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
			bOk.y = 10;
			addChild( bOk );
		}
		
		private function onButtonChangeType():void 
		{
			setType( ( _type+1 ) % 4 ); 
		}
		
		private function onButtonChangeFaction():void
		{
			if ( _faction == Faction.SCIENCE )
				setFaction( Faction.NATURE );
			else
			if ( _faction == Faction.NATURE )
				setFaction( Faction.MAGIC );
			else
			if ( _faction == Faction.MAGIC )
				setFaction( null );
			else
				setFaction( Faction.SCIENCE );
		}
		
		private function onButtonOk():void
		{
			context.selectedCard.setSelected( false );
		}
		
		public function loadDataFrom( source:Card ):void
		{
			tTitle.text = source.data.name;
			tDescr.text = source.data.description;
			tExtra.text = source.data.power.toString();
			tagsInput.text = source.tags.join( "\n" );
			
			setType( source.data.type );
			setFaction( source.data.faction );
		}
		
		public function saveDataTo( c:Card ):void
		{
			c.data.type = _type;
			c.data.faction = _faction;
			c.data.name = tTitle.text;
			c.data.description = tDescr.text;
			c.data.power = int( tExtra.text );
			c.tags.length = 0;
			c.tags.push.apply( null, tagsInput.text.split( "\n" ) );
			c.onDataChange();
		}
		
		public function setType( value:int ):void
		{
			_type = value;
			pad.color = CardType.toColor( _type ) + 0x101010;
			iType.color = CardType.toColor( _type );
		}
		
		public function setFaction( value:Faction ):void
		{
			_faction = value;
			iFaction.color = Faction.toColor( value );
		}
	
	}

}