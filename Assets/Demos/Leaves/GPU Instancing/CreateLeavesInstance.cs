using UnityEngine;

public class CreateLeavesInstance : MonoBehaviour
{
    public int instanceCount = 10;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    ComputeBuffer trsBuffer;
    int m_CachedInstanceCount;
    void Start()
    {
        UpdateBuffer();
    }

    void Update()
    {
        if (m_CachedInstanceCount != instanceCount)
            UpdateBuffer();

        Graphics.DrawMeshInstancedProcedural(instanceMesh, 0, instanceMaterial, new Bounds(Vector3.zero, 10000 * Vector3.one), instanceCount);
    }

    void UpdateBuffer()
    {
        Matrix4x4[] matrix4X4s = new Matrix4x4[instanceCount];

        if (trsBuffer != null)
            trsBuffer.Release();
        trsBuffer = new ComputeBuffer(instanceCount, 64);

        var rotation = Quaternion.identity;
        var scale = Vector3.one;
        for (int i = 0; i < instanceCount; i++)
        {
            var position = new Vector3(i % 10 * 3, (i / 10) % 10 * 3, (i / 100) % 100 * 3) + new Vector3(-12.5f, 0, 50);

            matrix4X4s[i] = Matrix4x4.TRS(position, rotation, scale);
        }

        trsBuffer.SetData(matrix4X4s);

        instanceMaterial.SetBuffer("trsBuffer", trsBuffer);

        m_CachedInstanceCount = instanceCount;
    }
}