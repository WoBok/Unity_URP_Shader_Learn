//using Unity.XR.PXR;
using UnityEngine;
using UnityEngine.UI;

public class FPS : MonoBehaviour
{
    float updateInterval = 1.0f;
    float timeLeft = 0.0f;
    string strFps = null;
    Text fpsText;
    void Start()
    {
        fpsText = GetComponent<Text>();
    }
    void Update()
    {
        ShowFps();
    }

    void ShowFps()
    {
        timeLeft -= Time.unscaledDeltaTime;

        if (timeLeft <= 0.0)
        {
            float fps = 0;//PXR_Plugin.System.UPxr_GetConfigInt(ConfigType.RenderFPS);

            strFps = string.Format("FPS: {0:f0}", fps);

            fpsText.text = strFps;

            timeLeft += updateInterval;
        }
    }
}