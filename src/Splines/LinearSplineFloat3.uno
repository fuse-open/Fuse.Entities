using Uno.Math;

namespace Fuse.Content.Splines
{
    public class LinearSplineFloat3 : KeyframedSpline<float3, float3>
    {
        public LinearSplineFloat3()
        {
        }

        public LinearSplineFloat3(Key[] keys)
            : base(keys)
        {
        }

        public override void Sample(double t, out float3 result)
        {
            float3 a, b;
            float p;
            FindValues(t, out a, out b, out p);
            result = a + (b - a) * Saturate(p);
        }
    }
}
