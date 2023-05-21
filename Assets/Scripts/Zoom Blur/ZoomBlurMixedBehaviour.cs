using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
[Serializable]
public class ZoomBlurMixedBehaviour : PlayableBehaviour
{
    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
        int inputCount = playable.GetInputCount();
        for (int i = 0; i < inputCount; i++)
        {
            var playableInput = (ScriptPlayable<ZoomBlurBehaviour>)playable.GetInput(i);
            ZoomBlurBehaviour input = playableInput.GetBehaviour();
            float inputWeight = playable.GetInputWeight(i);
            if (Mathf.Approximately(inputWeight, 0f))
            {
                continue;
            }
            float normalizedTime = (float)(playableInput.GetTime() / playableInput.GetDuration());
            input.ChangeWeight(normalizedTime);
        }
    }
}
