using Uno;
using Uno.UX;
using Fuse.Drawing;

namespace Fuse.Entities
{
	public partial class Transform3D : Fuse.Transform
	{
		public void InvalidateLocal()
		{
			OnMatrixChanged();
		}

		public Entity Entity { get { return Parent as Entity; } }

		public override void AppendTo(FastMatrix m, float weight)
		{
			if (Scaling != float3(1)) m.AppendScale(Math.Lerp(float3(1),Scaling,weight));
			if (RotationQuaternion != float4(0,0,0,1)) m.AppendRotationQuaternion(RotationQuaternion*weight);
			if (Position != float3(0)) m.AppendTranslation(Position*weight);
		}

		public override void PrependTo(FastMatrix m)
		{
			if (Position != float3(0)) m.PrependTranslation(Position);
			if (RotationQuaternion != float4(0,0,0,1)) m.PrependRotationQuaternion(RotationQuaternion);
			if (Scaling != float3(1)) m.PrependScale(Scaling);
		}

		float3 position;

		float4 rotationQuaternion;
		float3 rotationDegrees;

		float3 scale;

		public Transform3D()
		{
			this.position = float3(0,0,0);
			this.rotationQuaternion = float4(0,0,0,1);
			this.scale = float3(1,1,1);
		}

		public Transform3D(float3 pos, float4 rot, float3 scale)
		{
			this.position = pos;
			this.rotationQuaternion = rot;
			this.scale = scale;
		}

		public Transform3D Clone()
		{
			return new Transform3D(Position, RotationQuaternion, Scaling);
		}

		public float3 Position
		{
			get
			{
				return position;
			}
			set
			{
				if (position != value)
				{
					position = value;
					InvalidateLocal();
				}
			}
		}

		public float4 RotationQuaternion
		{
			get
			{
				return rotationQuaternion;
			}
			set
			{
				rotationQuaternion = value;
				rotationDegrees = Quaternion.ToEulerAngleDegrees(value);
				InvalidateLocal();
			}
		}

		public float3 RotationDegrees
		{
			get
			{
				return rotationDegrees;
			}
			set
			{
				rotationDegrees = value;
				rotationQuaternion = Quaternion.FromEulerAngleDegrees(value);
				InvalidateLocal();
			}
		}

		public float3 Scaling
		{
			get
			{
				return scale;
			}
			set
			{
				scale = value;
				InvalidateLocal();
			}
		}

		public void LookAt(float3 worldTarget, float3 worldUp)
		{
			var view = Matrix.LookAtRH(Entity.WorldPosition, worldTarget, worldUp);

			float3 pos, scale;
			float4 rot;
			Matrix.Decompose(view, out scale, out rot, out pos);
			Entity.WorldRotationQuaternion = Quaternion.Invert(rot);
		}

		public override bool IsFlat
		{
			get
			{
				const float _zeroTolerance = 1e-05f;
				return Math.Abs(RotationDegrees.X) < _zeroTolerance &&
				Math.Abs(RotationDegrees.Y) < _zeroTolerance &&
				Math.Abs(Position.Z) < _zeroTolerance;
			}
		}
	}
}
