using UnityEngine;

public class Boundary_CreateMesh : MonoBehaviour
{
    public GameObject pointObjs;
    void Start()
    {
        var pointObjsTrans = pointObjs.transform;
        var pointCount = pointObjsTrans.childCount;

        //Vertices
        var vertices = new Vector3[(pointCount + 1) * 2];
        for (int i = 0; i < pointCount; i++)
        {
            vertices[i] = pointObjsTrans.GetChild(i).position;
            vertices[i + pointCount + 1] = vertices[i] + new Vector3(0, 2, 0);
        }
        vertices[pointCount] = vertices[0];
        vertices[pointCount * 2 + 1] = vertices[pointCount + 1];

        //Triangles
        var triangles = new int[(pointCount + 1) * 6];
        for (int i = 0; i < pointCount; i++)
        {
            var index = i * 6;
            triangles[index] = i;
            triangles[index + 1] = i + pointCount + 1;
            triangles[index + 2] = i + pointCount + 2;
            triangles[index + 3] = i + 1;
            triangles[index + 4] = i;
            triangles[index + 5] = i + pointCount + 2;
        }

        //UVs
        var uv = new Vector2[(pointCount + 1) * 2];
        var length = 0.0f;
        for (int i = 0; i < pointCount; i++)
        {
            var posA = pointObjsTrans.GetChild(i).position;
            var posB = pointObjsTrans.GetChild((i + 1) % pointCount).position;
            var distance = Vector3.Distance(posA, posB);
            length += distance;
        }
        var uvLength = 0.0f;
        for (int i = 1; i <= pointCount - 1; i++)
        {
            var posA = pointObjsTrans.GetChild(i).position;
            var posB = pointObjsTrans.GetChild(i - 1).position;
            var distance = Vector3.Distance(posA, posB);
            uvLength += distance;
            var u = uvLength / length;
            uv[i] = new Vector2(u, 0);
            uv[i + pointCount + 1] = new Vector2(u, 1);
        }
        uv[0] = new Vector2(0, 0);
        uv[pointCount + 1] = new Vector2(0, 1);
        uv[pointCount] = new Vector2(1, 0);
        uv[pointCount * 2 + 1] = new Vector2(1, 1);

        var gameObject = new GameObject("Boundary");

        var mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uv;

        MeshFilter meshFilter = gameObject.AddComponent<MeshFilter>();
        meshFilter.mesh = mesh;

        MeshRenderer meshRenderer = gameObject.AddComponent<MeshRenderer>();

        var material = new Material(Shader.Find("Shader Graphs/Boundary"));
        meshRenderer.material = material;

        material.SetFloat("_LineCount", length / 0.2f);
        material.SetVector("_StartPosition", pointObjsTrans.GetChild(0).position);
    }
}