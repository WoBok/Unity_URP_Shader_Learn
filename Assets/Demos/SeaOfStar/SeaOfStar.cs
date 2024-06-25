using UnityEngine;

public class SeaOfStar : MonoBehaviour
{
    [Header("Resources")]
    public Mesh mesh;
    public Material material;
    public ComputeShader computeShader;

    ComputeBuffer m_argsBuffer;

    void Start()
    {

    }

    void Update()
    {

        Graphics.DrawMeshInstancedIndirect(mesh, 0, material, new Bounds(Vector3.zero, 10000 * Vector3.one), m_argsBuffer, 0);
    }
}