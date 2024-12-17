using UnityEditor;
using UnityEngine;

public class BatchRenameTool : EditorWindow
{

    public string prefix = "Prefix";

    [MenuItem("Tools/Batch Rename Tool")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow(typeof(BatchRenameTool), false, "Batch Rename Tool");
    }

    void OnGUI()
    {
        GUILayout.Space(20);

        prefix = EditorGUILayout.TextField("File Name Prefix:", prefix);

        GUILayout.Space(20);

        if (GUILayout.Button("Rename", GUILayout.Height(50)))
        {
            Rename();
        }
    }

    public void Rename()
    {
        Object[] objects = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
        int index = 1;
        for (int i = 0; i < objects.Length; i++)
        {
            //{
            //    var material = objects[i] as Material;
            //    if (material != null)
            //        material.color = Color.red;
            //}
            string path = AssetDatabase.GetAssetPath(objects[i]);
            string newFileName = $"{prefix}_{index:00}";
            AssetDatabase.RenameAsset(path, newFileName);
            index++;
        }
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}