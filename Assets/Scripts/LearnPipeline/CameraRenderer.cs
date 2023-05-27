using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CameraRenderer
{
    ScriptableRenderContext context;
    Camera camera;
    const string bufferName = "Render Buffer";
    CommandBuffer cb = new CommandBuffer() { name = bufferName };
    CullingResults cullingResults;
    static ShaderTagId shaderTagId = new ShaderTagId("SRPDefaultUnlit");
    static ShaderTagId[] legacyShaderTagIds = {
        new ShaderTagId("Always"),
        new ShaderTagId("ForwardBase"),
        new ShaderTagId("PrepassBase"),
        new ShaderTagId("Vertex"),
        new ShaderTagId("VertexLMRGBM"),
        new ShaderTagId("VertexLM")
    };
    public void Render(ScriptableRenderContext context, Camera camera)
    {
        this.context = context;
        this.camera = camera;

        if (!Cull()) return;

        SetUp();
        DrawVisibleGeometry();
        DrawUnsupportedShaders();
        Submit();
    }
    void SetUp()
    {
        //The Draw GL entry represent drawing a full-screen quad with the Hidden/InternalClear shader that writes to the render target, which isn't the most efficient way to clear it.
        //This approach is used because we're clearing before setting up the camera properties. If we swap the order of those two steps we get the quick way to clear.
        context.SetupCameraProperties(camera);
        CameraClearFlags flags = camera.clearFlags;
        cb.ClearRenderTarget((flags & CameraClearFlags.Depth) != 0, (flags & CameraClearFlags.Color) != 0, Color.clear);//ClearRenderTarget自身会将Draw GL包裹进以CommandBuffer为名字的Sample中
        cb.BeginSample(bufferName);
        ExcuteBuffer();
    }
    void DrawVisibleGeometry()
    {
        var sortingSettings = new SortingSettings(camera) { criteria = SortingCriteria.CommonOpaque };
        var drawingSettings = new DrawingSettings(shaderTagId, sortingSettings);
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

        context.DrawSkybox(camera);

        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    }
    void DrawUnsupportedShaders()
    {
        var drawingSettings = new DrawingSettings(legacyShaderTagIds[0], new SortingSettings(camera));
        for (int i = 1; i < legacyShaderTagIds.Length; i++)
        {
            drawingSettings.SetShaderPassName(i, legacyShaderTagIds[i]);
        }
        var filteringSettings = FilteringSettings.defaultValue;
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    }
    void Submit()
    {
        cb.EndSample(bufferName);
        ExcuteBuffer();
        context.Submit();
    }
    void ExcuteBuffer()
    {
        //We can instruct the context to execute the buffer via its ExecuteCommandBuffer method.
        //Once again, this doesn't immediately execute the commands, but copies them to the internal buffer of the context.
        context.ExecuteCommandBuffer(cb);
        cb.Clear();
    }
    //Command buffers claim resources to store their commands at the native level of the Unity engine.
    //If we no longer need these resources, it is best to release them immediately.
    //This can be done by invoking the buffer's Release method, directly after invoking ExecuteCommandBuffer.
    //cb.Release();
    bool Cull()
    {
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters cullingParameters))
        {
            cullingResults = context.Cull(ref cullingParameters);
            return true;
        }
        return false;
    }
}
