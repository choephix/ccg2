// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package dev
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.utils.VertexData;
	
	/** A Quad represents a rectangle with a uniform color or a color gradient.
	 *
	 *  <p>You can set one color per vertex. The colors will smoothly fade into each other over the area
	 *  of the quad. To display a simple linear color gradient, assign one color to vertices 0 and 1 and
	 *  another color to vertices 2 and 3. </p>
	 *
	 *  <p>The indices of the vertices are arranged like this:</p>
	 *
	 *  <pre>
	 *  0 - 1
	 *  | / |
	 *  2 - 3
	 *  </pre>
	 *
	 *  @see Image
	 */
	public class AuraModel extends DisplayObject
	{
		private static const PROGRAM_NAME:String = "aura";
		
		/** The raw vertex data of the quad. */
		private var mVertexData:VertexData;
		private var mVertexBuffer:VertexBuffer3D;
		
		// index data
		private var mIndexData:Vector.<uint>;
		private var mIndexBuffer:IndexBuffer3D;
		
		private var mNumTriangles:int = 0;
		
		/** Helper objects. */
		private static var sHelperPoint:Point = new Point();
		private static var sHelperMatrix:Matrix = new Matrix();
		private static var sRenderAlpha:Vector.<Number> = new <Number>[ 1.0, 1.0, 1.0, 1.0 ];
		
		/** Creates a quad with a certain size and color. The last parameter controls if the
		 *  alpha value should be premultiplied into the color values on rendering, which can
		 *  influence blending output. You can use the default value in most cases.  */
		public function AuraModel()
		{
			const W:Number = 15;
			const H:Number = 20;
			const S:Number = 10;
			
			mVertexData = new VertexData( 12, false );
			mVertexData.setPosition( 0, S * ( 3 ), S * ( 3 ) );
			mVertexData.setPosition( 1, S * ( 0 ), S * ( 2 ) );
			mVertexData.setPosition( 2, S * ( 2 ), S * ( 0 ) );
			mVertexData.setPosition( 3, S * ( W - 3 ), S * ( 3 ) );
			mVertexData.setPosition( 4, S * ( W - 2 ), S * ( 0 ) );
			mVertexData.setPosition( 5, S * ( W ), S * ( 2 ) );
			mVertexData.setPosition( 6, S * ( W - 3 ), S * ( H - 3 ) );
			mVertexData.setPosition( 7, S * ( W ), S * ( H - 2 ) );
			mVertexData.setPosition( 8, S * ( W - 2 ), S * ( H ) );
			mVertexData.setPosition( 9, S * ( 3 ), S * ( H - 3 ) );
			mVertexData.setPosition( 10, S * ( 2 ), S * ( H ) );
			mVertexData.setPosition( 11, S * ( 0 ), S * ( H - 2 ) );
			
			mVertexData.setUniformColor( 0xFFFF00 );
			
			// create indices that span up the triangles
			
			mIndexData = new <uint>[];
			mIndexData.push( 0, 1, 2 );
			mIndexData.push( 2, 4, 0 );
			mIndexData.push( 4, 3, 0 );
			mIndexData.push( 3, 4, 5 );
			mIndexData.push( 5, 7, 3 );
			mIndexData.push( 7, 6, 3 );
			mIndexData.push( 6, 7, 8 );
			mIndexData.push( 8, 10, 6 );
			mIndexData.push( 10, 9, 6 );
			mIndexData.push( 9, 10, 11 );
			mIndexData.push( 11, 1, 9 );
			mIndexData.push( 1, 0, 9 );
			//mIndexData.push( 0, 3, 9 );
			//mIndexData.push( 6, 9, 3 );
			
			mNumTriangles = int( mIndexData.length / 3 );
			
			onVertexDataChanged();
			registerPrograms();
			createBuffers();
			
			// handle lost context
			Starling.current.addEventListener( Event.CONTEXT3D_CREATE, onContextCreated );
		}
		
		/** Disposes all resources of the display object. */
		public override function dispose():void
		{
			Starling.current.removeEventListener( Event.CONTEXT3D_CREATE, onContextCreated );
			
			if ( mVertexBuffer )
				mVertexBuffer.dispose();
			
			if ( mIndexBuffer )
				mIndexBuffer.dispose();
			
			super.dispose();
		}
		
		private function onContextCreated( event:Event ):void
		{
			// the old context was lost, so we create new buffers and shaders.
			createBuffers();
			registerPrograms();
		}
		
		/** Creates vertex and fragment programs from assembly. */
		private static function registerPrograms():void
		{
			var target:Starling = Starling.current;
			
			if ( target.hasProgram( PROGRAM_NAME ) )
				return; // already registered
			
			// va0 -> position
			// va1 -> color
			// vc0 -> mvpMatrix (4 vectors, vc0 - vc3)
			// vc4 -> alpha
			
			var vertexProgramCode:String = "m44 op, va0, vc0 \n" + // 4x4 matrix transform to output space
				"mul v0, va1, vc4 \n"; // multiply color with alpha and pass it to fragment shader
			
			var fragmentProgramCode:String = "mov oc, v0"; // just forward incoming color
			
			var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexProgramAssembler.assemble( Context3DProgramType.VERTEX, vertexProgramCode );
			
			var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentProgramAssembler.assemble( Context3DProgramType.FRAGMENT, fragmentProgramCode );
			
			target.registerProgram( PROGRAM_NAME, vertexProgramAssembler.agalcode, fragmentProgramAssembler.agalcode );
		}
		
		/** Creates new vertex- and index-buffers and uploads our vertex- and index-data to those
		 *  buffers. */
		private function createBuffers():void {
			var context:Context3D = Starling.context;
			
			if ( context == null )
				throw new MissingContextError();
			
			if ( mVertexBuffer )
				mVertexBuffer.dispose();
			
			if ( mIndexBuffer )
				mIndexBuffer.dispose();
			
			mVertexBuffer = context.createVertexBuffer( mVertexData.numVertices, VertexData.ELEMENTS_PER_VERTEX );
			mVertexBuffer.uploadFromVector( mVertexData.rawData, 0, mVertexData.numVertices );
			
			mIndexBuffer = context.createIndexBuffer( mIndexData.length );
			mIndexBuffer.uploadFromVector( mIndexData, 0, mIndexData.length );
		}
		
		/** Call this method after manually changing the contents of 'mVertexData'. */
		protected function onVertexDataChanged():void
		{
			// override in subclasses, if necessary
		}
		
		/** @inheritDoc */
		public override function getBounds( targetSpace:DisplayObject, resultRect:Rectangle = null ):Rectangle
		{
			if ( resultRect == null )
				resultRect = new Rectangle();
			
			if ( targetSpace == this ) // optimization
			{
				mVertexData.getPosition( 3, sHelperPoint );
				resultRect.setTo( 0.0, 0.0, sHelperPoint.x, sHelperPoint.y );
			}
			else if ( targetSpace == parent && rotation == 0.0 ) // optimization
			{
				var scaleX:Number = this.scaleX;
				var scaleY:Number = this.scaleY;
				mVertexData.getPosition( 3, sHelperPoint );
				resultRect.setTo( x - pivotX * scaleX, y - pivotY * scaleY, sHelperPoint.x * scaleX, sHelperPoint.y * scaleY );
				if ( scaleX < 0 )
				{
					resultRect.width *= -1;
					resultRect.x -= resultRect.width;
				}
				if ( scaleY < 0 )
				{
					resultRect.height *= -1;
					resultRect.y -= resultRect.height;
				}
			}
			else
			{
				getTransformationMatrix( targetSpace, sHelperMatrix );
				mVertexData.getBounds( sHelperMatrix, 0, 4, resultRect );
			}
			
			return resultRect;
		}
		
		/** Sets the alpha value of a vertex at a certain index. */
		public function setVertexAlpha( vertexID:int, alpha:Number ):void
		{
			mVertexData.setAlpha( vertexID, alpha );
			onVertexDataChanged();
		}
		
		/** @inheritDoc **/
		public override function set alpha( value:Number ):void
		{
			super.alpha = value;
		}
		
		/** Copies the raw vertex data to a VertexData instance. */
		public function copyVertexDataTo( targetData:VertexData, targetVertexID:int = 0 ):void
		{
			mVertexData.copyTo( targetData, targetVertexID );
		}
		
		/** Transforms the vertex positions of the raw vertex data by a certain matrix and
		 *  copies the result to another VertexData instance. */
		public function copyVertexDataTransformedTo( targetData:VertexData, targetVertexID:int = 0, matrix:Matrix = null ):void
		{
			mVertexData.copyTransformedTo( targetData, targetVertexID, matrix, 0, 4 );
		}
		
		/** Renders the object with the help of a 'support' object and with the accumulated alpha
		 * of its parent object. */
		public override function render( support:RenderSupport, alpha:Number ):void
		{
			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			support.finishQuadBatch();
			
			// make this call to keep the statistics display in sync.
			support.raiseDrawCount();
			
			sRenderAlpha[ 0 ] = sRenderAlpha[ 1 ] = sRenderAlpha[ 2 ] = 1.0;
			sRenderAlpha[ 3 ] = alpha * this.alpha;
			
			var context:Context3D = Starling.context;
			
			if ( context == null )
				throw new MissingContextError();
			
			// apply the current blendmode
			support.applyBlendMode( false );
			
			// activate program (shader) and set the required buffers / constants 
			context.setProgram( Starling.current.getProgram( PROGRAM_NAME ) );
			context.setVertexBufferAt( 0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
			context.setVertexBufferAt( 1, mVertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4 );
			context.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true );
			context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 4, sRenderAlpha, 1 );
			
			// finally: draw the object!
			context.drawTriangles( mIndexBuffer, 0, mNumTriangles );
			
			// reset buffers
			context.setVertexBufferAt( 0, null );
			context.setVertexBufferAt( 1, null );
		}
		
		/** Returns true if the quad (or any of its vertices) is non-white or non-opaque. */
		public function get tinted():Boolean
		{
			return false;
		}
		
		/** Indicates if the rgb values are stored premultiplied with the alpha value; this can
		 *  affect the rendering. (Most developers don't have to care, though.) */
		public function get premultipliedAlpha():Boolean
		{
			return mVertexData.premultipliedAlpha;
		}
	}
}