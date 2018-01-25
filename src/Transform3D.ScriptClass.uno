using Uno;
using Uno.UX;

using Fuse.Scripting;

namespace Fuse.Entities
{
	public partial class Transform3D
	{
		static Transform3D()
		{
			ScriptClass.Register(typeof(Transform3D),
				new ScriptMethod<Transform3D>("lookAt", lookAt));
		}

		static object lookAt(Context c, Transform3D s, object[] args)
		{
			if (args.Length != 2)
			{
				Fuse.Diagnostics.UserError( "Transform3D.lookAt requires 2 arguments", s );
				return null;
			}

			var where = Marshal.ToType<float3>(args[0]);
			var up = Marshal.ToType<float3>(args[1]);

			UpdateManager.PostAction(new LookAtClosure(s, where, up).Run);
			return null;
		}

		class LookAtClosure
		{
			readonly Transform3D _transform;
			readonly float3 _where;
			readonly float3 _up;
			public LookAtClosure(Transform3D transform, float3 where, float3 up)
			{
				_transform = transform;
				_where = where;
				_up = up;
			}

			public void Run()
			{
				_transform.LookAt(_where, _up);
			}
		}
	}
}
