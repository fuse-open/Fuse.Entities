using Uno.Math;

namespace Fuse.Content.Splines
{
    public class LinearSplineFloat2 : KeyframedSpline<float2, float2>
    {
        public LinearSplineFloat2()
        {
        }

        public LinearSplineFloat2(Key[] keys)
            : base(keys)
        {
        }

        public override void Sample(double t, out float2 result)
        {
            float2 a, b;
            float p;
            FindValues(t, out a, out b, out p);
            result = a + (b - a) * Saturate(p);
        }
    }
}
