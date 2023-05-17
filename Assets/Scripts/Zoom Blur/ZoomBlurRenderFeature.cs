using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ZoomBlurRenderFeature : ScriptableRendererFeature
{
    class CZoomBlurRenderPass : ScriptableRenderPass
    {
        static readonly string k_RenderTag = "Render ZoomBlur Effects";
        static readonly int MainTexId = Shader.PropertyToID("_MainTex");
        static readonly int TempTargetId = Shader.PropertyToID("_TempTargetId");
        static readonly int FoucsPowerId = Shader.PropertyToID("_FoucsPowerId");
        static readonly int FocusDetailId = Shader.PropertyToID("_FocusDetailId");
        static readonly int FocusScreenPositionId = Shader.PropertyToID("_FocusScreenPositionId");
        static readonly int ReferenceResolutionXId = Shader.PropertyToID("_ReferenceResolutionXId");

        ZoomBlur zoomBlur;
        Material zoomBlurMaterial;
        RenderTargetIdentifier currentTarget;
        public CZoomBlurRenderPass(RenderPassEvent renderPassEvent)
        {
            this.renderPassEvent = renderPassEvent;
            var shader = Shader.Find("PostEffect/ZoomBlur");
            if (shader == null)
            {
                Debug.LogError("Shader not found.");
                return;
            }
            zoomBlurMaterial = CoreUtils.CreateEngineMaterial(shader);

        }
        public void Setup(in RenderTargetIdentifier currentTarget)
        {
            this.currentTarget = currentTarget;
        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {

        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (zoomBlurMaterial == null)
            {
                Debug.LogError("Material not found.");
                return;
            }
            if (!renderingData.cameraData.postProcessEnabled) return;

            var stack = VolumeManager.instance.stack;
            zoomBlur = stack.GetComponent<ZoomBlur>();
            if (zoomBlur == null) return;
            if (!zoomBlur.IsActive()) return;

            var cmd = CommandBufferPool.Get(k_RenderTag);
        }
        void Render(CommandBuffer cmd, ref RenderingData renderingData)
        {
            ref var cameraData = ref renderingData.cameraData;
            var source = currentTarget;
            var destination = TempTargetId;

            var w = cameraData.camera.scaledPixelWidth;
            var h = cameraData.camera.scaledPixelHeight;

            zoomBlurMaterial.SetFloat(FoucsPowerId, zoomBlur.focusPower.value);
            zoomBlurMaterial.SetInt(FocusDetailId, zoomBlur.focusDetail.value);
            zoomBlurMaterial.SetVector(FocusScreenPositionId, zoomBlur.focusScreenPostion.value);
            zoomBlurMaterial.SetInt(ReferenceResolutionXId, zoomBlur.referenceResolutionX.value);

        }
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }

    CZoomBlurRenderPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CZoomBlurRenderPass(RenderPassEvent.BeforeRenderingPostProcessing);

    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


