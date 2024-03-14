using System.Collections;
using UnityEngine;
public class LinearlyDependent : MonoBehaviour
{
    public float interval;
    public float speed;
    Matrix4x4 transformM = new Matrix4x4()
    {
        m00 = 1,
        m01 = 0,
        m02 = 0,
        m03 = 0,
        m10 = 0,
        m11 = 1,
        m12 = 0,
        m13 = 0,
        m20 = 0,
        m21 = 0,
        m22 = 1,
        m23 = 0,
        m30 = 0,
        m31 = 0,
        m32 = 0,
        m33 = 0,
    };
    Matrix4x4 transformM2 = new Matrix4x4()
    {
        m00 = -1,
        m01 = 0.2f,
        m02 = -0.1f,
        m03 = 0,
        m10 = 0.3f,
        m11 = 1,
        m12 = 0.4f,
        m13 = 0,
        m20 = 0.2f,
        m21 = -0.2f,
        m22 = -1,
        m23 = 0,
        m30 = 0,
        m31 = 0,
        m32 = 0,
        m33 = 0,
    };
    Mesh mesh;
    Vector3[] vertices;
    Coroutine coroutine;

    void Start()
    {
        mesh = GetComponent<MeshFilter>().mesh;
        vertices = new Vector3[mesh.vertices.Length];
        for (int i = 0; i < mesh.vertices.Length; i++)
        {
            vertices[i] = mesh.vertices[i];
        }
    }
    void OnGUI()
    {
        if (GUILayout.Button("Start"))
        {
            Vector3[] vertices = mesh.vertices;
            for (int i = 0; i < vertices.Length; i++)
            {
                vertices[i] = this.vertices[i];
            }
            mesh.vertices = vertices;
            if (coroutine != null)
                StopCoroutine(coroutine);
            transformM.m10 = 0;
            transformM.m11 = 1;
            transformM.m12 = 0;
            coroutine = StartCoroutine(Translate());
        }
        if (GUILayout.Button("Trans2"))
        {
            Vector3[] vertices = mesh.vertices;
            for (int i = 0; i < vertices.Length; i++)
            {
                vertices[i] = transformM2 * vertices[i];
            }
            mesh.vertices = vertices;
        }
    }
    IEnumerator Translate()
    {
        while (true)
        {
            Vector3[] vertices = mesh.vertices;

            for (int i = 0; i < mesh.vertices.Length; i++)
            {
                vertices[i] = transformM * vertices[i];
            }

            mesh.vertices = vertices;

            transformM.m00 = Mathf.Lerp(transformM.m00, -1, Time.deltaTime * speed);
            transformM.m01 = Mathf.Lerp(transformM.m01, 0.2f, Time.deltaTime * speed);
            transformM.m02 = Mathf.Lerp(transformM.m02, -0.1f, Time.deltaTime * speed);

            transformM.m10 = Mathf.Lerp(transformM.m10, 0.3f, Time.deltaTime * speed);
            transformM.m11 = Mathf.Lerp(transformM.m11, 1, Time.deltaTime * speed);
            transformM.m12 = Mathf.Lerp(transformM.m12, 0.4f, Time.deltaTime * speed);

            transformM.m20 = Mathf.Lerp(transformM.m20, 0.2f, Time.deltaTime * speed);
            transformM.m21 = Mathf.Lerp(transformM.m21, -0.2f, Time.deltaTime * speed);
            transformM.m22 = Mathf.Lerp(transformM.m22, -1, Time.deltaTime * speed);

            yield return new WaitForSeconds(interval);
        }
    }
}