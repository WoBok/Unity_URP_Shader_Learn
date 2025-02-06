using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class CreateCubeMesh : MonoBehaviour
{
    public float width = 1f;
    public float height = 1f;
    public float depth = 1f;

    void Start()
    {
        Vector3[] vertices = new Vector3[8]
        {
            new Vector3(-width / 2, -height / 2, -depth / 2), // 0
            new Vector3(width / 2, -height / 2, -depth / 2),  // 1
            new Vector3(width / 2, height / 2, -depth / 2),   // 2
            new Vector3(-width / 2, height / 2, -depth / 2),  // 3
            new Vector3(-width / 2, -height / 2, depth / 2),  // 4
            new Vector3(width / 2, -height / 2, depth / 2),   // 5
            new Vector3(width / 2, height / 2, depth / 2),    // 6
            new Vector3(-width / 2, height / 2, depth / 2)    // 7
        };

        int[] triangles = new int[36]
        {
            // 前面
            0, 2, 1,
            0, 3, 2,
            // 右面
            1, 2, 6,
            1, 6, 5,
            // 后面
            5, 6, 7,
            5, 7, 4,
            // 左面
            4, 7, 3,
            4, 3, 0,
            // 上面
            3, 7, 6,
            3, 6, 2,
            // 下面
            4, 0, 1,
            4, 1, 5
        };

        Vector2[] uv = new Vector2[8]
        {
            new Vector2(0, 0), // 0
            new Vector2(1, 0), // 1
            new Vector2(1, 1), // 2
            new Vector2(0, 1), // 3
            new Vector2(0, 0), // 4
            new Vector2(1, 0), // 5
            new Vector2(1, 1), // 6
            new Vector2(0, 1)  // 7
        };

        Mesh mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uv;
        mesh.RecalculateNormals();

        MeshFilter meshFilter = GetComponent<MeshFilter>();
        meshFilter.mesh = mesh;
    }
}