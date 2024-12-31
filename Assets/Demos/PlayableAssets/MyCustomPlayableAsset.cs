using UnityEngine;
using UnityEngine.Playables;

[System.Serializable]
public class MyCustomPlayableAsset : PlayableAsset
{
    // 你可以在这里定义要播放的任何内容，像是数组、时间等
    public float someValue = 1.0f;

    public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
    {
        // 创建并返回一个PlayableBehaviour实例
        var playable = ScriptPlayable<MyCustomPlayableBehaviour>.Create(graph);

        MyCustomPlayableBehaviour behaviour = playable.GetBehaviour();
        behaviour.someValue = someValue;  // 将参数传递给Behaviour

        return playable;
    }
}
