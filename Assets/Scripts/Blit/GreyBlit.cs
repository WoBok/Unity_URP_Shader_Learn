using Pico.Platform.Models;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GreyBlit : MonoBehaviour
{
    public float c_r = 1;
    public float c_g = 1;
    public float c_b = 1;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Shader sd = Shader.Find("Light/Color");
        Material mt = new Material(sd);
        mt.SetFloat("c_r",c_r);
        mt.SetFloat("c_g", c_g);
        mt.SetFloat("c_b", c_b);
        Graphics.Blit(source, destination, mt);
    }
}