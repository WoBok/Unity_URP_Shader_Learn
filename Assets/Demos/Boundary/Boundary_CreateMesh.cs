using UnityEngine;

public class Boundary_CreateMesh : MonoBehaviour
{
    public GameObject pointObjs;
    void Start()
    {
        var pointObjsTrans = pointObjs.transform;
        var pointCount = pointObjsTrans.childCount;

        //Vertices
        var vertices = new Vector3[pointCount * 2];
        for (int i = 0; i < pointCount; i++)
        {
            vertices[i] = pointObjsTrans.GetChild(i).position;
            vertices[i + pointCount] = vertices[i] + new Vector3(0, 2, 0);
        }

        //Triangles
        var triangles = new int[pointCount * 6];
        for (int i = 0; i < pointCount; i++)
        {
            var index = i * 6;
            triangles[index] = i;
            triangles[index + 1] = i + pointCount;
            triangles[index + 2] = (i + 1) % pointCount + pointCount;
            triangles[index + 3] = (i + 1) % pointCount;
            triangles[index + 4] = i;
            triangles[index + 5] = (i + 1) % pointCount + pointCount;
        }

        var gameObject = new GameObject("Boundary");

        var mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = triangles;

        MeshFilter meshFilter = gameObject.AddComponent<MeshFilter>();
        meshFilter.mesh = mesh;

        MeshRenderer meshRenderer = gameObject.AddComponent<MeshRenderer>();

        meshRenderer.material = new Material(Shader.Find("Shader Graphs/Boundary"));
    }

}
