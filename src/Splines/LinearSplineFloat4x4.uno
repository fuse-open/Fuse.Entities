using Uno.Math;

namespace Fuse.Content.Splines
{
    public class LinearSplineFloat4x4 : KeyframedSpline<float4x4, float4x4>
    {
        public LinearSplineFloat4x4()
        {
        }

        public LinearSplineFloat4x4(Key[] keys)
            : base(keys)
        {
        }

        public override void Sample(double t, out float4x4 result)
        {
            float4x4 a, b;
            float p;
            FindValues(t, out a, out b, out p);
            result = a + (b - a) * Saturate(p);
        }
    }
}
