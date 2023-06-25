using System;
using UnityEngine;
using UnityEngine.Experimental.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ReflectionObjects : ScriptableRendererFeature
{
    [Serializable]
    public class ReflectionObjectSettings
    {
        public LayerMask LayerMask = 0;
        [Range(0.1f, 1f)]
        public float resolutionRatio = 1;
    }
    class ReflectionObjectsRenderPass : ScriptableRenderPass
    {
        DrawingSettings m_DrawingSettings;
        FilteringSettings m_FilteringSettings;
        //RenderStateBlock m_RenderStateBlock;
        SortingCriteria m_SortingCriteria;

        public float resolutionRatio;
        static ShaderTagId shaderTagId = new ShaderTagId("UniversalForward");
        static readonly int reflectionTexture_pid = Shader.PropertyToID("_ReflectionRT");
        RenderTargetIdentifier currentTarget;

        public ReflectionObjectsRenderPass(LayerMask layerMask)
        {
            m_FilteringSettings = new FilteringSettings(RenderQueueRange.all, layerMask);
            m_SortingCriteria = SortingCriteria.CommonTransparent;
            //m_RenderStateBlock = new RenderStateBlock() { mask = RenderStateMask.Depth, depthState = new DepthState(true, CompareFunction.Equal) };
        }
        public void Setup(in RenderTargetIdentifier currentTarget)
        {
            this.currentTarget = currentTarget;
        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            cmd.GetTemporaryRT(reflectionTexture_pid, (int)(Screen.width * resolutionRatio), (int)(Screen.height * resolutionRatio));
            ConfigureTarget(reflectionTexture_pid);
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {

            CommandBuffer cmd = CommandBufferPool.Get("Render Reflection Object");
            cmd.ClearRenderTarget(true, true, Color.clear);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);

            //m_SortingCriteria = renderingData.cameraData.defaultOpaqueSortFlags;
            m_DrawingSettings = CreateDrawingSettings(shaderTagId, ref renderingData, m_SortingCriteria);
            context.DrawRenderers(renderingData.cullResults, ref m_DrawingSettings, ref m_FilteringSettings/*,ref m_RenderStateBlock*/);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            ConfigureTarget(currentTarget);
            cmd.ReleaseTemporaryRT(reflectionTexture_pid);
        }
    }

    ReflectionObjectsRenderPass m_ScriptablePass;
    public ReflectionObjectSettings settings = new ReflectionObjectSettings();

    public override void Create()
    {
        m_ScriptablePass = new ReflectionObjectsRenderPass(settings.LayerMask);
        m_ScriptablePass.resolutionRatio = settings.resolutionRatio;
        m_ScriptablePass.renderPassEvent = RenderPassEvent.BeforeRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_ScriptablePass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


