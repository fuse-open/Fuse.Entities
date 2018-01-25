namespace Fuse.Content.Splines
{
    public abstract class Spline<T> where T : struct
    {
        public abstract double Start { get; }
        public abstract double End { get; }
        public abstract void Sample(double time, out T result);

        public virtual T First
        {
            get { return Sample(Start); }
        }

        public virtual T Last
        {
            get { return Sample(End); }
        }

        public T Sample(double time)
        {
            T result;
            Sample(time, out result);
            return result;
        }
    }
}
