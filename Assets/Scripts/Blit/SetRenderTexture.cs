using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SetRenderTexture : MonoBehaviour
{
    public RawImage rawImage;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        rawImage.texture = source;
        Graphics.Blit(source, destination);
    }
}
