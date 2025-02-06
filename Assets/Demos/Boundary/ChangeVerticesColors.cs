using UnityEngine;

public class ChangeVerticesColors : MonoBehaviour
{
    void Start()
    {
        var meshFilter = GetComponent<MeshFilter>();
        var verticesCount = meshFilter.sharedMesh.vertices.Length;
        var colors = new Color[verticesCount];
        for (int i = 0; i < verticesCount; i++)
        {
            colors[i] = new Color(Random.Range(0, 1f), Random.Range(0, 1f), Random.Range(0, 1f));
        }
        meshFilter.mesh.colors = colors;
    }

}
