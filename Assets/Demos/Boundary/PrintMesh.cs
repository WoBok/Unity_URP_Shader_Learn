using UnityEngine;

public class PrintMesh : MonoBehaviour
{
    void Start()
    {
        var mesh = GetComponent<MeshFilter>().mesh;

        var vertices = mesh.vertices;
        var verticesStr = "";
        for (int i = 0; i < vertices.Length; i++)
        {
            verticesStr += vertices[i] + " | ";
        }

        var uv = mesh.uv;
        var uvStr = "";
        for (int i = 0; i < uv.Length; i++)
        {
            uvStr += uv[i] + " | ";
        }

        var colors = mesh.colors;
        var colorStr = "";
        for (int i = 0; i < colors.Length; i++)
        {
            colorStr += colors[i] + " | ";
        }
        print(verticesStr);
        print(uvStr);
        print(colorStr);
    }
}
