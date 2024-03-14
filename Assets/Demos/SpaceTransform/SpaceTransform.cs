using System;
using UnityEngine;

public class SpaceTransform : MonoBehaviour
{
    Mesh m_Mesh;
    public Matrix2x3 matrix;
    Vector3[] m_OriginVertices;
    Vector3[] m_CurrentVertices;
    Vector3[] m_OriginNormal;
    Vector3[] m_CurrentNormal;
    void Start()
    {
        m_Mesh = GetComponent<MeshFilter>().mesh;
        m_OriginVertices = new Vector3[m_Mesh.vertices.Length];
        m_CurrentVertices = new Vector3[m_Mesh.vertices.Length];
        for (int i = 0; i < m_Mesh.vertices.Length; i++)
        {
            m_OriginVertices[i] = m_Mesh.vertices[i];
            m_CurrentVertices[i] = m_Mesh.vertices[i];
        }
        m_OriginNormal = new Vector3[m_Mesh.normals.Length];
        m_CurrentNormal = new Vector3[m_Mesh.normals.Length];
        for (int i = 0; i < m_Mesh.normals.Length; i++)
        {
            m_OriginNormal[i] = m_Mesh.normals[i];
            m_CurrentNormal[i] = m_Mesh.normals[i];
        }
    }
    void Update()
    {
        for (int i = 0; i < m_Mesh.vertices.Length; i++)
        {
            m_CurrentVertices[i] = matrix * m_OriginVertices[i];
        }
        m_Mesh.vertices = m_CurrentVertices;
        for (int i = 0; i < m_Mesh.normals.Length; i++)
        {
            m_CurrentNormal[i] = matrix * m_OriginNormal[i];
        }
        m_Mesh.normals = m_CurrentNormal;
    }
}
[Serializable]
public struct Matrix2x3
{
    public float m00;
    public float m01;
    public float m02;
    public float m10;
    public float m11;
    public float m12;

    public static Vector2 operator *(Matrix2x3 m, Vector3 v)
    {
        Vector2 result = Vector2.zero;
        result.x = m.m00 * v.x + m.m01 * v.y + m.m02 * v.z;
        result.y = m.m10 * v.x + m.m11 * v.y + m.m12 * v.z;
        return result;
    }
}