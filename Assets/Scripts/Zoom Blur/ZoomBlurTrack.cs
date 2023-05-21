using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
[TrackColor(0, 1, 0)]
[TrackClipType(typeof(ZoomBlurClip))]
public class ZoomBlurTrack : TrackAsset
{
    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
        var scriptPlayable = ScriptPlayable<ZoomBlurMixedBehaviour>.Create(graph, inputCount);
        return scriptPlayable;
    }
}
