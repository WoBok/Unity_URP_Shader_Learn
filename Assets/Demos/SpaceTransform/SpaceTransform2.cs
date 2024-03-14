using System;
using UnityEngine;
public class SpaceTransform2 : MonoBehaviour
{
    Mesh m_Mesh;
    public Matrix3x2 matrix;
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
public struct Matrix3x2
{
    public float m00;
    public float m01;
    public float m10;
    public float m11;
    public float m20;
    public float m21;
    public static Vector3 operator *(Matrix3x2 m, Vector2 v)
    {
        Vector3 result = Vector3.zero;
        result.x = m.m00 * v.x + m.m01 * v.y;
        result.y = m.m10 * v.x + m.m11 * v.y;
        result.z = m.m20 * v.x + m.m21 * v.y;
        return result;
    }
}