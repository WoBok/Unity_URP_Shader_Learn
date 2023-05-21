using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using static UnityEngine.GraphicsBuffer;
[Serializable]
public class ZoomBlurClip : PlayableAsset, ITimelineClipAsset
{
    public ZoomBlurBehaviour template = new ZoomBlurBehaviour();
    public ClipCaps clipCaps => ClipCaps.Extrapolation | ClipCaps.Blending;

    public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<ZoomBlurBehaviour>.Create(graph, template);
        ZoomBlurBehaviour clone = playable.GetBehaviour();
        return playable;
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(ZoomBlurClip))]
public class ZoomBlurClipEditor : Editor
{
    ZoomBlurClip zoomBlurClip;
    Editor profileEditor;
    SerializedProperty profileProperty;
    SerializedProperty curveProperty;

    void OnEnable()
    {
        zoomBlurClip = target as ZoomBlurClip;
        profileEditor = CreateEditor(zoomBlurClip.template.profile);
        profileProperty = serializedObject.FindProperty("template.profile");
        curveProperty = serializedObject.FindProperty("template.weightCurve");
    }
    void OnDisable()
    {
        DestroyImmediate(profileEditor);
    }
    public override void OnInspectorGUI()
    {
        zoomBlurClip.template.layer = EditorGUILayout.LayerField("Layer", zoomBlurClip.template.layer);
        serializedObject.Update();
        EditorGUILayout.PropertyField(profileProperty);
        EditorGUILayout.PropertyField(curveProperty);
        serializedObject.ApplyModifiedProperties();

        profileEditor?.OnInspectorGUI();
    }
}

#endif