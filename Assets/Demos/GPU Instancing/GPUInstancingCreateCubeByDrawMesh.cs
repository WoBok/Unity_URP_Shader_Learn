using UnityEngine;

public class GPUInstancingCreateCubeByDrawMesh : MonoBehaviour
{
    static int baseColorID = Shader.PropertyToID("_BaseColor");
    static int positionDeltaID = Shader.PropertyToID("_PositionDelta");
    static int speedID = Shader.PropertyToID("_Speed");
    [SerializeField]
    Mesh mesh = default;
    [SerializeField]
    Material material = default;
    [SerializeField]
    int positionRange = 20;

    Matrix4x4[] matrixs = new Matrix4x4[1022];
    Vector4[] baseColors = new Vector4[1022];
    float[] positionDelta = new float[1022];
    float[] speeds= new float[1022];

    [SerializeField]
    float positionDeltaRange = 10; 
    [SerializeField]
    float speedRange = 10;

    MaterialPropertyBlock block;
    void Start()
    {
        for (int i = 0; i < matrixs.Length; i++)
        {
            matrixs[i] = Matrix4x4.TRS(Random.insideUnitSphere * positionRange, Quaternion.identity, Vector3.one);
            baseColors[i] = new Vector4(Random.value, Random.value, Random.value, 1);
            positionDelta[i] = Random.Range(-positionDeltaRange, positionDeltaRange);
            speeds[i] = Random.Range(-speedRange, speedRange);
        }
        block = new MaterialPropertyBlock();
        block.SetVectorArray(baseColorID, baseColors);
        block.SetFloatArray(positionDeltaID, positionDelta);
        block.SetFloatArray(speedID, speeds);
    }
    void Update()
    {
        Graphics.DrawMeshInstanced(mesh, 0, material, matrixs, 1022, block);
    }
}
