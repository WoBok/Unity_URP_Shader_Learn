using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering.Universal;

//--------------------------------------------------RendererFeature----------------------------------------//
public class FurRenderer : ScriptableRendererFeature
{
    public RenderPassEvent renderPassEvent;
    public RenderQueueType renderQueueType;
    public LayerMask LayerMask;
    public Material furMaterial;
    public int furLayers;
    public float step = 0.05f;

    FurRenderPass m_FurRenderPass;
    public override void Create()
    {
        m_FurRenderPass = new FurRenderPass(renderQueueType, LayerMask, furMaterial, furLayers, step);
        m_FurRenderPass.renderPassEvent = renderPassEvent;
    }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_FurRenderPass);
    }
}
//--------------------------------------------------RendererFeature----------------------------------------//

//--------------------------------------------------Pass----------------------------------------//
public class FurRenderPass : ScriptableRenderPass
{
    RenderQueueType renderQueueType;
    Material furMaterial;
    int furLayers;
    float step;

    SortingCriteria m_SortingCriteria;
    DrawingSettings m_DrawingSettings;
    FilteringSettings m_FilteringSettings;

    public FurRenderPass(RenderQueueType renderQueueType, int layerMask, Material furMaterial, int furLayers, float step)
    {
        this.renderQueueType = renderQueueType;
        this.furMaterial = furMaterial;
        this.furLayers = furLayers;
        this.step = step;

        RenderQueueRange renderQueueRange = (renderQueueType == RenderQueueType.Transparent)
        ? RenderQueueRange.transparent
        : RenderQueueRange.opaque;
        m_FilteringSettings = new FilteringSettings(renderQueueRange, layerMask);
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        m_SortingCriteria = (renderQueueType == RenderQueueType.Transparent)
                ? SortingCriteria.CommonTransparent
                : renderingData.cameraData.defaultOpaqueSortFlags;
        m_DrawingSettings = CreateDrawingSettings(new ShaderTagId("UniversalForward"), ref renderingData, m_SortingCriteria);
        //m_DrawingSettings.overrideMaterial = furMaterial;
        CommandBuffer cmd = CommandBufferPool.Get("Fur Renderer");
        cmd.Clear();
        for (int i = 0; i <= furLayers; i++)
        {
            cmd.Clear();
            cmd.SetGlobalFloat("_FURSTEP", i * step);
            context.ExecuteCommandBuffer(cmd);
            context.DrawRenderers(renderingData.cullResults, ref m_DrawingSettings, ref m_FilteringSettings);
        }
        CommandBufferPool.Release(cmd);
    }
}
//--------------------------------------------------Pass----------------------------------------//