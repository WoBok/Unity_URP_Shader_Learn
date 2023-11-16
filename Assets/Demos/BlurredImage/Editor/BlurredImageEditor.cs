using UnityEditor;
using UnityEditor.UI;
using UnityEngine.UI;

[CustomEditor(typeof(BlurredImage))]
[CanEditMultipleObjects]
public class BlurredImageEditor : ImageEditor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        var image = target as BlurredImage;
        if (image != null)
            image.blurSize = EditorGUILayout.IntSlider("Blur Size", image.blurSize, 1, 20);
    }
}
