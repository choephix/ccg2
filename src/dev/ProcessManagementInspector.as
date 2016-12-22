package dev 
{
	import chimichanga.common.display.Sprite;
	import duel.processes.ProcessManager;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.text.TextField;
	
	
	public class ProcessManagementInspector extends Sprite implements IAnimatable
	{
		private var manager:ProcessManager;
		
		private const W:Number = 400;
		private const H:Number = 500;
		private const PADDING_X:Number = 50;
		private const PADDING_Y:Number = 50;
		
		private var bg:Quad;
		private var tf:TextField;
		
		public function ProcessManagementInspector( manager:ProcessManager ) 
		{
			this.manager = manager;
			Starling.juggler.add( this );
			
			bg = new Quad( W, H, 0x0 );
			bg.alpha = .5;
			addChild( bg );
			
			//tf = new TextField( W, H, "", "Lucida Console", 10, 0x22BBFF, true );
			//tf.hAlign = "left";
			//tf.vAlign = "top";
			//addChild( tf );
			
			this.touchable = false;
		}
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime(time:Number):void 
		{
			//tf.text = manager.toString();
			
			visible = tf.text != "";
			
			if ( !visible ) return;
			
			//tf.x = PADDING_X;
			//tf.y = PADDING_Y;
			
			bg.x = .0;
			bg.y = .0;
			bg.width  = W;
			bg.height = PADDING_Y * 2.0 + tf.textBounds.height;
		}
	}
}