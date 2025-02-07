using UnityEngine;

public class PrintMesh : MonoBehaviour
{
    void Start()
    {
        var mesh = GetComponent<MeshFilter>().mesh;

        var vertices = mesh.vertices;
        var verticesStr = "Vertices: ";
        for (int i = 0; i < vertices.Length; i++)
        {
            verticesStr += vertices[i] + " | ";
        }

        var uv = mesh.uv;
        var uvStr = "UV: ";
        for (int i = 0; i < uv.Length; i++)
        {
            uvStr += uv[i] + " | ";
        }

        var colors = mesh.colors;
        var colorStr = "Color: ";
        for (int i = 0; i < colors.Length; i++)
        {
            colorStr += colors[i] + " | ";
        }

        var verticesAndColorStr = "";
        for (int i = 0; i < vertices.Length; i++)
        {
            verticesAndColorStr += $"Index: {i}, Vertex: {vertices[i] * 1000}, UV: {uv[i]} | ";
        }
        print(verticesStr);
        print(uvStr);
        print(verticesAndColorStr);
        print(colorStr);
    }
}
