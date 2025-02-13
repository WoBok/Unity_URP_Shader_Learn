using UnityEngine;
using UnityEditor;
using System.Linq;

public class BatchRenameGameObjects : EditorWindow
{
    string prefix = "NewName_";
    string suffixFormat = "#1#1";
    int startIndex = 1;
    int minLength = 3;

    [MenuItem("Tools/Batch Rename GameObjects")]
    public static void ShowWindow()
    {
        GetWindow<BatchRenameGameObjects>("Batch Rename GameObjects");
    }

    void OnGUI()
    {
        GUILayout.Label("Batch Rename GameObjects", EditorStyles.boldLabel);

        prefix = EditorGUILayout.TextField("Prefix", prefix);
        suffixFormat = EditorGUILayout.TextField("Suffix Format", suffixFormat);

        if (GUILayout.Button("Preview & Apply"))
        {
            ParseSuffixFormat();
            ApplyBatchRename();
        }
    }

    void ParseSuffixFormat()
    {
        string[] parts = suffixFormat.Split('#');
        if (parts.Length >= 3 && int.TryParse(parts[1], out int start) && int.TryParse(parts[2], out int length))
        {
            startIndex = start;
            minLength = length;
        }
        else
        {
            Debug.LogError("Invalid suffix format. Use: #startIndex#minLength");
        }
    }

    void ApplyBatchRename()
    {
        GameObject[] selectedObjects = Selection.gameObjects;
        if (selectedObjects.Length == 0)
        {
            Debug.LogWarning("No GameObjects selected.");
            return;
        }

        int index = startIndex;
        foreach (var obj in selectedObjects.OrderBy(o => o.name))
        {
            string newName = prefix + index.ToString().PadLeft(minLength, '0');
            obj.name = newName;
            index++;
        }
    }
}