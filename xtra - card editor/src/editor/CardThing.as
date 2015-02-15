package editor
{
	import feathers.controls.TextArea;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import starling.animation.Transitions;
	import starling.core.Starling;
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
		public static const FORMAT_SLUG:TextFormat = new TextFormat( "Arial", 11, 0xFFFFFF );
		public static const FORMAT_TAGS:TextFormat = new TextFormat( "Lucida Console", 14, 0xFFFFFF );
		
		private var pad:Quad;
		
		public var tTitle:TextArea;
		public var tDescr:TextArea;
		public var tExtra:TextArea;
		public var tSlug:TextArea;
		public var iFaction:OButton;
		public var iType:OButton;
		
		private var slugQuad:Quad;
		private var tagsQuad:Quad;
		private var tTags:TextArea;
		private var bOk:OButton;
		private var bX:OButton;
		
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
			
			Card.FORMAT_TITLE.align = "center";
			Card.FORMAT_DESCR.align = "center";
			FORMAT_SLUG.align = "center";
			
			//
			
			slugQuad = new Quad( W, 22, 0x0 );
			slugQuad.alpha = .60;
			slugQuad.x = 0;
			slugQuad.y = -22;
			addChild( slugQuad );
			
			tSlug = new TextArea();
			tSlug.textEditorProperties.textFormat = FORMAT_SLUG
			tSlug.width = G.CARD_W;
			tSlug.height = 22;
			tSlug.y = -22;
			addChild( tSlug );
			tSlug.validate();
			
			tTitle = new TextArea();
			tTitle.textEditorProperties.textFormat = Card.FORMAT_TITLE;
			tTitle.width = G.CARD_W * 1.5;
			tTitle.height = 22;
			tTitle.x = -G.CARD_W * .25;
			tTitle.y = 0;
			addChild( tTitle );
			tTitle.validate();
			
			tDescr = new TextArea();
			tDescr.textEditorProperties.textFormat = Card.FORMAT_DESCR;
			tDescr.x = PADDING;
			tDescr.y = tTitle.y + tTitle.height;
			tDescr.width = G.CARD_W - PADDING - PADDING;
			tDescr.height = G.CARD_H - PADDING - PADDING - tDescr.y;
			tDescr.text = "...";
			addChild( tDescr );
			tDescr.validate();
			
			tExtra = new TextArea();
			tExtra.textEditorProperties.textFormat = Card.FORMAT_EXTRA;
			tExtra.width = 100;
			tExtra.height = 50;
			tExtra.x = 0;
			tExtra.y = G.CARD_H - 40;
			tExtra.maxChars = 2;
			tExtra.restrict = "0-9";
			addChild( tExtra );
			tExtra.validate();
			
			tTitle.nextTabFocus = tDescr;
			tDescr.nextTabFocus = tExtra;
			tExtra.nextTabFocus = tTitle;
			tSlug.nextTabFocus = tTitle;
			
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
			
			//
			
			tagsQuad = new Quad( W, 48, 0x0 );
			tagsQuad.alpha = .40;
			tagsQuad.x = 0;
			tagsQuad.y = H;
			addChild( tagsQuad );
			
			tTags = new TextArea();
			tTags.textEditorProperties.textFormat = FORMAT_TAGS;
			tTags.x = tagsQuad.x;
			tTags.y = tagsQuad.y;
			tTags.width = tagsQuad.width;
			tTags.height = tagsQuad.height;
			addChild( tTags );
			tTags.validate();
			
			bOk = new OButton( "OK", onButtonOk );
			bOk.x = W + 20;
			bOk.y = 10;
			addChild( bOk );
			
			bX = new OButton( "", onButtonDiscard );
			bX.x = W + 38;
			bX.y = -5;
			bX.scaleX = .33;
			bX.scaleY = .33;
			addChild( bX );
		}
		
		public function animateIn():void
		{
			touchable = false;
			
			alpha = .0;
			Starling.juggler.tween( this, .150, { alpha : 1.0, onComplete : f } );
			
			bOk.scaleX = .1;
			bOk.scaleY = .1;
			Starling.juggler.tween( bOk, .250, { scaleX : 1.0, scaleY : 1.0, transition : Transitions.EASE_OUT_BACK } );
			
			tagsQuad.scaleY = .1;
			Starling.juggler.tween( tagsQuad, .150, { scaleY : 1.0, transition : Transitions.EASE_OUT } );
			
			slugQuad.scaleY = .0;
			slugQuad.y = .0;
			Starling.juggler.tween( slugQuad, .150, { scaleY : 1.0, y : -22, transition : Transitions.EASE_OUT } );
			
			function f():void
			{ touchable = true }
		}
		
		public function setFocus( p:Point ):void
		{
			var o:TextArea;
			if ( tTitle.getBounds( stage ).containsPoint( p ) )
				o = tTitle;
			else
			if ( tDescr.getBounds( stage ).containsPoint( p ) )
				o = tDescr;
			else
			if ( tExtra.getBounds( stage ).containsPoint( p ) )
				o = tExtra;
			else
				return;
			
			o.setFocus();
			o.selectRange( 0, o.text.length );
		}
		
		private function onButtonChangeType():void 
		{
			setType( ( _type % 4 ) + 1 ); 
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
				setFaction( Faction.NEUTRAL );
			else
			if ( _faction == Faction.NEUTRAL )
				setFaction( null );
			else
			if ( _faction == null )
				setFaction( Faction.SCIENCE );
		}
		
		private function onButtonOk():void
		{
			saveDataTo( context.selectedCard );
			context.selectedCard.setSelected( false );
		}
		
		private function onButtonDiscard():void
		{
			context.selectedCard.setSelected( false );
		}
		
		public function loadDataFrom( source:Card ):void
		{
			tDescr.text = source.data.description;
			tSlug.text = CONFIG::sandbox ? source.data.name : source.data.slug;
			tTitle.text = CONFIG::sandbox ? source.data.slug : source.data.name;
			tExtra.text = source.data.power.toString();
			tTags.text = source.data.tags.join( "\n" );
			
			setType( source.data.type );
			setFaction( source.data.faction );
		}
		
		public function saveDataTo( c:Card ):void
		{
			tTitle.text = tTitle.text.split( "\n" ).join( "" );
			tSlug.text = tSlug.text.split( "\n" ).join( "" );
			
			c.data.type = _type;
			c.data.faction = _faction;
			c.data.slug = CONFIG::sandbox ? tTitle.text : tSlug.text;
			c.data.name = CONFIG::sandbox ? tSlug.text : tTitle.text;
			c.data.description = tDescr.text;
			c.data.power = int( tExtra.text );
			c.data.tags = tTags.text.split( "\n" );
			c.onDataChange();
		}
		
		public function setType( value:int ):void
		{
			_type = value;
			pad.color = CardType.toColor( _type ) + 0x101010;
			iType.color = CardType.toColor( _type );
			tExtra.visible = _type != CardType.TRAP;
		}
		
		public function setFaction( value:Faction ):void
		{
			_faction = value;
			iFaction.color = Faction.toColor( value );
		}
	
	}

}