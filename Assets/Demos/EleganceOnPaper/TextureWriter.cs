using UnityEngine;

public class TextureWriter : MonoBehaviour
{
    public ComputeShader computeShader;
    public Texture2D texture;
    public Material material;
    public Vector3 currentPosition;

    RenderTexture m_RenderTexture;
    int kernelHandle;

    void Start()
    {
        InitTexture();
        InitComputeShader();
    }

    void InitTexture()
    {
        m_RenderTexture = new RenderTexture(texture.width, texture.height, 0)
        {
            //enableRandomWrite = true
        };
        //m_RenderTexture.Create();
        Graphics.Blit(texture, m_RenderTexture);
        material.SetTexture("_BaseMap", m_RenderTexture);
    }

    void InitComputeShader()
    {
        kernelHandle = computeShader.FindKernel("Writer");
        computeShader.SetTexture(kernelHandle, "Result", m_RenderTexture);
    }

    void Update()
    {
        SetPosition();
        computeShader.Dispatch(kernelHandle, texture.width / 8, texture.height / 8, 1);
    }
    void SetPosition()
    {

        var texPos = Vector2.zero;

        texPos.x = (currentPosition.x / transform.localScale.x) * texture.width;
        texPos.y = (currentPosition.y / transform.localScale.y) * texture.height;

        computeShader.SetVector("currentPosition", texPos);
    }
}