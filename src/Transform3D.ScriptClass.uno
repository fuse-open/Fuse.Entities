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
				new ScriptMethod<Transform3D>("lookAt", lookAt, ExecutionThread.MainThread));
		}

		static void lookAt(Context c, Transform3D s, object[] args)
		{
			if (args.Length != 2)
			{
				Fuse.Diagnostics.UserError( "Transform3D.lookAt requires 2 arguments", s );
				return;
			}

			var where = Marshal.ToType<float3>(args[0]);
			var up = Marshal.ToType<float3>(args[1]);
			s.LookAt(where,up);
		}
	}
}
