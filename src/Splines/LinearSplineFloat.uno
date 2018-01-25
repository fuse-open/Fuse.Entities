using Uno.Math;

namespace Fuse.Content.Splines
{
    public class LinearSplineFloat : KeyframedSpline<float, float>
    {
        public LinearSplineFloat()
        {
        }

        public LinearSplineFloat(Key[] keys)
            : base(keys)
        {
        }

        public override void Sample(double t, out float result)
        {
            float a, b, p;
            FindValues(t, out a, out b, out p);
            result = a + (b - a) * Saturate(p);
        }
    }
}
