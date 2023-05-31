using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ReflectionObjects : ScriptableRendererFeature
{
    [Serializable]
    public class ReflectionObjectSettings
    {
        public LayerMask LayerMask;
        public Material overrideMaterial = null;
    }
    class ReflectionObjectsRenderPass : ScriptableRenderPass
    {
        FilteringSettings m_FilteringSettings;
        public Material overrideMaterial { get; set; }
        static ShaderTagId shaderTagId = new ShaderTagId("UniversalForward");
        public ReflectionObjectsRenderPass(LayerMask layerMask, Material overrideMaterial)
        {
            m_FilteringSettings = new FilteringSettings();
            m_FilteringSettings.layerMask = layerMask;
            this.overrideMaterial = overrideMaterial;
        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {

        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {

        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {

        }
    }

    ReflectionObjectsRenderPass m_ScriptablePass;
    public ReflectionObjectSettings settings = new ReflectionObjectSettings();

    public override void Create()
    {
        //m_ScriptablePass = new ReflectionObjectsRenderPass();

        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


