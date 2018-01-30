using Uno.Math;

namespace Fuse.Content.Splines
{
    public class LinearSplineFloat4 : KeyframedSpline<float4, float4>
    {
        public LinearSplineFloat4()
        {
        }

        public LinearSplineFloat4(Key[] keys)
            : base(keys)
        {
        }

        public override void Sample(double t, out float4 result)
        {
            float4 a, b;
            float p;
            FindValues(t, out a, out b, out p);
            result = a + (b - a) * Saturate(p);
        }
    }
}
