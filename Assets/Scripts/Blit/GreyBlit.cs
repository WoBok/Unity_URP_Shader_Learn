using Pico.Platform.Models;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GreyBlit : MonoBehaviour
{
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Shader sd = Shader.Find("Light/Color");
        Material mt = new Material(sd);
        Graphics.Blit(source, destination, mt);
    }
}