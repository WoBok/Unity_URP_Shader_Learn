using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PostProgressPass : ScriptableRenderPass
{
    Material m_RenderMaterial;
    Material RenderMaterial
    {
        get
        {
            if (m_RenderMaterial == null)
            {
                m_RenderMaterial = new Material(Shader.Find("URP Shader/PostProgress"));
            }
            return m_RenderMaterial;
        }
    }
    static readonly int TempTargetId = Shader.PropertyToID("_TempTarget");

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        var source = renderingData.cameraData.renderer.cameraColorTargetHandle;

        var w = renderingData.cameraData.camera.scaledPixelWidth;
        var h = renderingData.cameraData.camera.scaledPixelHeight;

        var cmd = CommandBufferPool.Get("Poat Progress");
        cmd.Clear();
        cmd.GetTemporaryRT(TempTargetId, w, h, 0, FilterMode.Bilinear, RenderTextureFormat.Default);
        cmd.Blit(source, TempTargetId);
        cmd.Blit(TempTargetId, source, RenderMaterial, 0);
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
        CommandBufferPool.Release(cmd);
    }
    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        base.OnCameraCleanup(cmd);
        cmd.ReleaseTemporaryRT(TempTargetId);
    }
}