using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using static Unity.XR.PXR.PXR_Plugin;

public class LearnPipeline : RenderPipeline
{
    CameraRenderer renderer=new CameraRenderer();
    //RenderPipeline.Render doesn't draw anything, but checks whether the pipeline object is valid to use for rendering. If not, it will raise an exception.
    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        ////Debug.Log("Renderer is working...");
        //foreach (var camera in cameras)
        //{
        //    renderer. Render(context, camera);
        //}
        context.SetupCameraProperties(cameras[0]);
        context.DrawSkybox(cameras[0]);
        context.Submit();
    }
}
