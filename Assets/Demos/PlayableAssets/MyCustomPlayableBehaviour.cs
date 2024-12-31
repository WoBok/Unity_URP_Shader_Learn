using UnityEngine;
using UnityEngine.Playables;

public class MyCustomPlayableBehaviour : PlayableBehaviour
{
    public float someValue;

    // 在播放时更新
    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
        base.ProcessFrame(playable, info, playerData);

        // 在这里你可以控制你的脚本如何在时间轴中播放
        Debug.Log("Time: " + playable.GetTime() + " Value: " + someValue);
    }
}
