using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PostProgressRendererFeature : ScriptableRendererFeature
{
    PostProgressPass m_PostProgressPass;
    public override void Create()
    {
        m_PostProgressPass = new PostProgressPass();
        m_PostProgressPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.cameraType == CameraType.Preview || renderingData.cameraData.cameraType == CameraType.Reflection)
            return;

        renderer.EnqueuePass(m_PostProgressPass);
    }
}