using Uno;

namespace Fuse.Entities.Designer
{
	public static class AnimationHelpers
	{
		// TODO: optimize this - binary search + index caching
		public static float Sample(double[] times, float[] leftValues, float[] rightValues, int[] easing, float[] leftTangents, float[] rightTangents, double time)
		{
			if (times.Length == 0) return 0.0f;

			for (int i = 0; i < times.Length; i++)
			{
				var kTime = times[i];
				if (time >= kTime)
				{
					if (i == times.Length - 1)
						return rightValues[i];

					var k2time = times[i + 1];
					if (time < k2time)
					{
						float f = (float)((time - kTime) / (k2time - kTime));
						switch (easing[i])
						{
							case 1: f *= f; break;
							case 2: f = 1.0f - Math.Pow(1.0f - f, 2.0f); break;
							case 3:
								float f2 = f * f;
								float f3 = f2 * f;
								float h1 = 2.0f * f3 - 3.0f * f2 + 1.0f;
								float h2 = -2.0f * f3 + 3.0f * f2;
								float h3 = f3 - 2.0f * f2 + f;
								float h4 = f3 - f2;
								return (float)rightValues[i] * h1 +
								       (float)leftValues[i+1] * h2 +
								       rightTangents[i] * h3 +
								       leftTangents[i+1] * h4;
						}
						return rightValues[i] * (1.0f - f) + leftValues[i+1] * f;
					}
				}
				else if (i == 0)
				{
					return leftValues[i];
				}
			}
			return 0.0f;
		}
	}
}
