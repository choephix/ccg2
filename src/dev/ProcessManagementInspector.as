package dev 
{
	import chimichanga.common.display.Sprite;
	import duel.processes.ProcessManager;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class ProcessManagementInspector extends Sprite implements IAnimatable
	{
		private var manager:ProcessManager;
		
		private var tf:TextField;
		
		public function ProcessManagementInspector( manager:ProcessManager ) 
		{
			this.manager = manager;
			Starling.juggler.add( this );
			
			var q:Quad = new Quad( 500, 500, 0x0 );
			q.alpha = .25;
			addChild( q );
			
			tf = new TextField( 500, 500, "", "Lucida Console", 11, 0x22BBFF, true );
			addChild( tf );
		}
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime(time:Number):void 
		{
			var s:String = "";
			s += manager.queue.join("\n");
			tf.text = s;
		}
	}
}