using Uno;
using Uno.Collections;

namespace Fuse.Entities.Designer
{
	public static class PreloadedResources
	{
		static Dictionary<string, object> resources = new Dictionary<string, object>();

		public static T Add<T>(string descriptor, T data)
		{
			resources[descriptor] = data;
			return data;
		}

		public static object Get(string descriptor)
		{
			object resource;
			if (resources.TryGetValue(descriptor, out resource))
			return resource;
			return null;
		}
	}
}
