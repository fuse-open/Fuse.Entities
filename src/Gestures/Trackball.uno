using Uno;
using Uno.Diagnostics;

using Fuse.Entities;
using Fuse.Input;

namespace Fuse.Gestures
{
	public class Trackball : Behavior
	{
		Transform3D _transform = new Transform3D();

		IViewport _viewport;
		bool _hasViewport;
		public IViewport Viewport
		{
			get { return _viewport; }
			set
			{
				_viewport = value;
				_hasViewport = true;
			}
		}

		const float hardCaptureThreshold = 10f;

		float _radius = 100;

		protected override void OnRooted()
		{
			base.OnRooted();

			Parent.Children.Add(_transform);

			Pointer.Pressed.AddHandler(Parent, OnPointerPressed);
			Pointer.Released.AddHandler(Parent, OnPointerReleased);
			Pointer.Moved.AddHandler(Parent, OnPointerMoved);

			if (!_hasViewport)
				_viewport = Parent.Viewport;
		}

		protected override void OnUnrooted()
		{
			Pointer.Pressed.RemoveHandler(Parent, OnPointerPressed);
			Pointer.Released.RemoveHandler(Parent, OnPointerReleased);
			Pointer.Moved.RemoveHandler(Parent, OnPointerMoved);

			Parent.Children.Remove(_transform);

			base.OnUnrooted();
		}

		//user for user MoceMOve
		bool _captured, _soft;
		float2 _pressLoc;
		int _pressIndex;
		float4 _pressQ;
		float4x4 _pressInvView;

		void OnPointerPressed(object s, PointerPressedArgs args)
		{
			if (_captured || !args.IsPrimary)
				return;

			if (args.TrySoftCapture(this, OnLostCapture))
			{
				_captured = true;
				_soft = true;
				_pressLoc = args.WindowPoint;
				_pressIndex = args.PointIndex;
				_pressQ = _transform.RotationQuaternion;
				_transform.RotationQuaternion = float4(0,0,0,1);

				_pressInvView = InverseViewProjection;

				_transform.RotationQuaternion = _pressQ;
			}
		}

		void OnLostCapture()
		{
			_captured = false;
			_transform.RotationQuaternion = _pressQ;
		}

		void OnPointerReleased(object s, PointerReleasedArgs args)
		{
			if (!_captured || args.PointIndex != _pressIndex)
				return;

			if (_soft)
				args.ReleaseCapture(this);
			else
				args.ReleaseCapture(this);
			_captured = false;
		}

		void OnPointerMoved(object s, PointerMovedArgs args)
		{
			if (!_captured || args.PointIndex != _pressIndex)
				return;

			//get normal to movement vector in the object's local space
			var dir0 = args.WindowPoint - _pressLoc;
			var dir = float2(dir0.X,-dir0.Y);
			var norm = Vector.Normalize(float3(-dir.Y,dir.X,0));
			var length = Vector.Length(dir);
			var angular = length / (2*_radius);

			var localNorm = Vector.Normalize( Vector.TransformNormal( norm, _pressInvView ) ).XYZ;

			//rotate around that vector
			var q = Quaternion.RotationAxis(localNorm,angular);
			var cq = Quaternion.Mul( _pressQ, q );
			_transform.RotationQuaternion = cq;

			if (_soft && length > hardCaptureThreshold)
			{
				if (!args.TryHardCapture(this, OnLostCapture))
					OnLostCapture();
				_soft = false;
			}
		}

		float4x4 InverseViewProjection
		{
			get
			{
				var at = Parent.WorldTransform;
				var vp = Viewport.ViewTransform;
				return Matrix.Invert( Matrix.Mul( at, vp ) );
			}
		}

		float3 _forwardVector = float3(0,0,1);
		/**
			The direction used to to put things in the front of the view.
		*/
		public float3 ForwardVector
		{
			get { return _forwardVector; }
			set { _forwardVector = value; }
		}
	}
}
