using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[TrackColor(0.25f, 0.5f, 1.0f)]
[TrackClipType(typeof(MyCustomPlayableAsset))]  // 允许你的PlaybleAsset类型在此Track中使用
public class MyCustomTrack : TrackAsset
{
    // Track的行为可以在这里添加
    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
        var scriptPlayable = ScriptPlayable<MyCustomPlayableBehaviour>.Create(graph, inputCount);
        return scriptPlayable;
    }
}
