using Uno.Math;

namespace Fuse.Content.Splines
{
    public class FullsampledSpline<T> : Spline<T> where T : struct
    {
        double _start, _fps;
        T[] _frames;

        public FullsampledSpline(double start, double fps, T[] frames)
        {
            _start = start;
            _fps = fps;
            _frames = frames;
        }

        public override double Start
        {
            get { return _start; }
        }

        public override double End
        {
            get { return _start + (double)(_frames.Length - 1) / _fps; }
        }

        public override void Sample(double time, out T result)
        {
            int index = Clamp((int)((time - _start) * _fps), 0, _frames.Length - 1);
            result = _frames[index];
        }
    }
}
