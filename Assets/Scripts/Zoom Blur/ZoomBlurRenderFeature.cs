using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ZoomBlurRenderFeature : ScriptableRendererFeature
{
    class CZoomBlurRenderPass : ScriptableRenderPass
    {
        static readonly string k_RenderTag = "Render ZoomBlur Effects";
        static readonly int MainTexId = Shader.PropertyToID("_MainTex");
        static readonly int TempTargetId = Shader.PropertyToID("_TempTarget");
        static readonly int FoucsPowerId = Shader.PropertyToID("_FoucsPower");
        static readonly int FocusDetailId = Shader.PropertyToID("_FocusDetail");
        static readonly int FocusScreenPositionId = Shader.PropertyToID("_FocusScreenPosition");
        static readonly int ReferenceResolutionXId = Shader.PropertyToID("_ReferenceResolutionX");

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
            Render(cmd, ref renderingData);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
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

            int shaderPass = 0;

            cmd.SetGlobalTexture(MainTexId, source);
            cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
            cmd.Blit(source, destination);
            cmd.Blit(destination, source, zoomBlurMaterial, shaderPass);

        }
    }

    CZoomBlurRenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new CZoomBlurRenderPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_ScriptablePass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


