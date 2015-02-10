package editor 
{
	import chimichanga.common.display.Sprite;
	import feathers.controls.TextArea;
	import flash.text.TextFormat;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardThing extends Sprite 
	{
		static public const BORDER:Number = 2.0;
		static public const W:Number = G.CARD_W + BORDER + BORDER;
		static public const H:Number = G.CARD_H + BORDER + BORDER;
		
		private var border:Quad;
		private var tagsQuad:Quad;
		private var tagsInput:TextArea;
		
		public function CardThing() 
		{
			border = new Quad( W, H, 0xFFFFFF );
			border.touchable = false;
			border.alpha = .15;
			border.alignPivot();
			addChild( border );
			
			tagsQuad = new Quad( W, 100, 0x0 );
			tagsQuad.alpha = .60;
			tagsQuad.x = -.5 * W;
			tagsQuad.y =  .5 * H;
			addChild( tagsQuad );
			
			tagsInput = new TextArea();
			tagsInput.textEditorProperties.textFormat = new TextFormat( "Lucida Console", 16, 0xFFFFFF );
			tagsInput.x = tagsQuad.x;
			tagsInput.y = tagsQuad.y;
			tagsInput.width = tagsQuad.width;
			tagsInput.height = tagsQuad.height;
			addChild( tagsInput );
			tagsInput.validate();
		}
		
		public function updateData( source:Card ):void
		{
			tagsInput.text = source.tags.join("\n");
		}
		
	}

}