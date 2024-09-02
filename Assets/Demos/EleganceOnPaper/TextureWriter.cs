using UnityEngine;

public class TextureWriter : MonoBehaviour
{
    public ComputeShader computeShader;
    public Texture2D texture;
    public Material material;
    public Vector3 currentPosition;

    RenderTexture m_OriginalRenderTexture;
    RenderTexture m_ResultRenderTexture;
    int kernelHandle;

    void Start()
    {
        InitTexture();
        InitComputeShader();
    }

    void InitTexture()
    {
        m_OriginalRenderTexture = new RenderTexture(texture.width, texture.height, 0);
        m_OriginalRenderTexture.enableRandomWrite = true;
        m_OriginalRenderTexture.Create();
        Graphics.Blit(texture, m_OriginalRenderTexture, new Material(Shader.Find("Universal Render Pipeline/Unlit")));

        m_ResultRenderTexture = new RenderTexture(texture.width, texture.height, 0);
        m_ResultRenderTexture.enableRandomWrite = true;
        m_ResultRenderTexture.Create();

        material.SetTexture("_BaseMap", m_ResultRenderTexture);
    }

    void InitComputeShader()
    {
        kernelHandle = computeShader.FindKernel("Writer");
        computeShader.SetTexture(kernelHandle, "tex", m_OriginalRenderTexture);
        computeShader.SetTexture(kernelHandle, "Result", m_ResultRenderTexture);
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