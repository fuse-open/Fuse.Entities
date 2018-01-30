using Uno;
using Uno.Collections;

namespace Fuse.Content.Splines
{
    public abstract class KeyframedSpline<TValue, TData> : Spline<TValue>
        where TValue : struct
        where TData : struct
    {
        public struct Key
        {
            public double Time;
            public TData Value;

            public Key(double time, TData value)
            {
                Time = time;
                Value = value;
            }
        }

        List<Key> keys = new List<Key>();
        int cache = 0;

        protected KeyframedSpline()
        {
        }

        protected KeyframedSpline(Key[] keys)
        {
            foreach (var k in keys)
                AddKey(k.Time, k.Value);
        }

        public override double Start
        {
            get { return keys[0].Time; }
        }

        public override double End
        {
            get { return keys[keys.Count - 1].Time; }
        }

        public int FindLeftIndex(double time)
        {
            if (keys.Count > 0)
            {
                while (time >= keys[cache].Time)
                {
                    if (cache == keys.Count - 1) return cache;
                    if (time < keys[cache + 1].Time) return cache;
                    cache++;
                }

                while (time < keys[cache].Time)
                {
                    if (cache == 0) return -1;
                    cache--;
                    if (time >= keys[cache].Time) return cache;
                }
            }

            return -1;
        }

        public int FindNearestIndex(double time)
        {
            int l = FindLeftIndex(time);
            int r = l + 1;

            if (l < 0)
            {
                return r;
            }

            if (r < keys.Count)
            {
                double ldif = time - keys[l].Time;
                double rdif = keys[r].Time - time;
                if (rdif < ldif) return r;
            }

            return l;
        }

        public int AddKey(double time, TData value)
        {
            int i = FindLeftIndex(time) + 1;
            keys.Insert(i, new Key(time, value));
            return i;
        }

        public void RemoveKey(int index)
        {
            if (cache == keys.Count - 1 && cache > 0) cache--;
            keys.RemoveAt(index);
        }

        public void ClearKeys()
        {
            keys.Clear();
            cache = 0;
        }

        public int KeyCount
        {
            get { return keys.Count; }
        }

        public TData GetValue(int index)
        {
            return keys[index].Value;
        }

        public double GetTime(int index)
        {
            return keys[index].Time;
        }

        public void SetValue(int index, TData value)
        {
            keys[index] = new Key(keys[index].Time, value);
        }

        public int SetTime(int index, double time)
        {
            if ((index > 0 && keys[index - 1].Time > time) ||
                (index < keys.Count - 1 && keys[index + 1].Time < time))
            {
                var v = GetValue(index);
                RemoveKey(index);
                return AddKey(time, v);
            }
            else
            {
                keys[index] = new Key(time, keys[index].Value);
                return index;
            }
        }

        public TData FindValue(double time)
        {
            return keys[Math.Max(0, FindLeftIndex(time))].Value;
        }

        public static float Map(double a, double b, double t)
        {
            return (float)((t - a) / (b - a));
        }

        /**
            Finds two Keyframe-values and a interpolation factor.
            @param p Interpolation Factor is in [0..1] except in cases before start or after end.
        */
        public void FindValues(double time, out TData a, out TData b, out float p)
        {
            int i = FindLeftIndex(time);
            var ka = keys[Math.Max(i, 0)];
            var kb = keys[Math.Min(i + 1, keys.Count - 1)];
            a = ka.Value;
            b = kb.Value;
            if (ka.Time == kb.Time) p = 0.0f;
            else p = Map(ka.Time, kb.Time, time);
        }

        /**
            Finds four Keyframe-values and a interpolation factor.
            @param p Interpolation Factor is in [0..1] except in cases before start or after end.
        */
        public void FindValues(double time, out TData a, out TData b, out TData c, out TData d, out float p)
        {
            int i = FindLeftIndex(time);
            var ka = keys[Math.Max(i - 1, 0)];
            var kb = keys[Math.Max(i, 0)];
            var kc = keys[Math.Min(i + 1, keys.Count - 1)];
            var kd = keys[Math.Min(i + 2, keys.Count - 1)];
            a = ka.Value;
            b = kb.Value;
            c = kc.Value;
            d = kd.Value;
            if (kb.Time == kc.Time) p = 0.0f;
            else p = Map(kb.Time, kc.Time, time);
        }
    }
}
