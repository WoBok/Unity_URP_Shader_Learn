using UnityEngine;

public class PrintMesh : MonoBehaviour
{
    void Start()
    {
        var mesh = GetComponent<MeshFilter>().mesh;
        var vertices = mesh.vertices;
        var uv = mesh.uv;
        var verticesStr = "";
        for (int i = 0; i < vertices.Length; i++)
        {
            verticesStr += vertices[i] + " | ";
        }
        var uvStr = "";
        for (int i = 0; i < uv.Length; i++)
        {
            uvStr += uv[i] + " | ";
        }
        print(verticesStr);
        print(uvStr);
    }
}
