using System;
using System.Threading;
using System.Timers;
using UnityEngine;

public class Timer : MonoBehaviour
{
    void Start()
    {
        TimerCallback callback = Callback;
        System.Threading.Timer t = new System.Threading.Timer(callback, "Timer", 2000, 1000);

        System.Timers.Timer timer = new System.Timers.Timer(3000);
        timer.Start();
        timer.Elapsed += (a, b) => Debug.Log((a as System.Timers.Timer).Interval.ToString() + b.SignalTime);
        t.Dispose();
    }

    private void A(object sender, ElapsedEventArgs e)
    {
        throw new NotImplementedException();
    }

    private void Callback(object state)
    {
        Debug.Log(state.ToString() + ", TimerCallback");
    }
}
