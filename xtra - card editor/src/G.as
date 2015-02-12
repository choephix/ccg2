package 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class G 
	{
		public static const URL_BASE:String = CONFIG::air||CONFIG::sandbox?"http://dev.thechoephix.com/ccg2/editor/":"";
		public static const URL_SAVE:String = "write.php";
		public static const URL_LOAD:String = "read.php";
		
		
		public static const CARD_W:Number = 150;
		public static const CARD_H:Number = 200;
		
		//private static const DAMP_MULT:Number = .75;
		private static const DAMP_MULT:Number = 1;
		public static const DAMP1:Number = DAMP_MULT * .250;
		public static const DAMP2:Number = DAMP_MULT * .320;
		public static const DAMP3:Number = DAMP_MULT * .440;
	}
}