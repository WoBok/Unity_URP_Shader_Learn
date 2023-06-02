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
        public Material overrideMaterial = null;
    }
    class ReflectionObjectsRenderPass : ScriptableRenderPass
    {
        FilteringSettings m_FilteringSettings;
        public Material overrideMaterial { get; set; }
        static ShaderTagId shaderTagId = new ShaderTagId("UniversalForward");
        static readonly int reflectionTexture_pid = Shader.PropertyToID("_ReflectionRT");
        static readonly int originalTexture_pid = Shader.PropertyToID("originalTexture");
        RenderTargetIdentifier reflectionTexture_identifier = new RenderTargetIdentifier(reflectionTexture_pid);
        RenderTargetIdentifier currentTarget;
        public ReflectionObjectsRenderPass(LayerMask layerMask)
        {
            m_FilteringSettings = new FilteringSettings(RenderQueueRange.all, layerMask);
        }
        public void Setup(in RenderTargetIdentifier currentTarget)
        {
            this.currentTarget = currentTarget;
        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            cmd.GetTemporaryRT(reflectionTexture_pid, Screen.width, Screen.height);
            ConfigureTarget(reflectionTexture_pid);
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("Render Reflection Object");

            ConfigureTarget(reflectionTexture_pid);

            SortingCriteria sortingCriteria = renderingData.cameraData.defaultOpaqueSortFlags;
            DrawingSettings drawingSettings = CreateDrawingSettings(shaderTagId, ref renderingData, sortingCriteria);
            drawingSettings.overrideMaterial = overrideMaterial;
            drawingSettings.overrideMaterialPassIndex = 0;
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);

            cmd.SetGlobalTexture(reflectionTexture_pid, reflectionTexture_identifier);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            ConfigureTarget(currentTarget);
            cmd.ReleaseTemporaryRT(reflectionTexture_pid);
            // cmd.ReleaseTemporaryRT(originalTexture_pid);
        }
    }

    ReflectionObjectsRenderPass m_ScriptablePass;
    public ReflectionObjectSettings settings = new ReflectionObjectSettings();

    public override void Create()
    {
        m_ScriptablePass = new ReflectionObjectsRenderPass(settings.LayerMask);
        m_ScriptablePass.overrideMaterial = settings.overrideMaterial;
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_ScriptablePass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


