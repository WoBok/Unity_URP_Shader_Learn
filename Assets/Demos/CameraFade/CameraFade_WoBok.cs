using System.Collections;
using UnityEngine;

public class CameraFade_WoBok : MonoBehaviour
{
    string shaderPath = "WoBok/CameraFade";

    GameObject sphere;
    GameObject Sphere
    {
        get
        {
            if (sphere == null)
            {
                sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                sphere.GetComponent<Renderer>().material = new Material(Shader.Find(shaderPath));
                sphere.transform.parent = Camera.main.transform;
                sphere.transform.localPosition = Vector3.zero;
                sphere.transform.localScale = Vector3.one * 0.1f;
            }
            return sphere;
        }
    }

    Material Sphere_Material => Sphere.GetComponent<Renderer>().material;

    float Sphere_Alpha
    {
        get => Sphere_Material.GetFloat("_Alpha");
        set => Sphere_Material.SetFloat("_Alpha", value);
    }

    Coroutine coroutine;
    public void FadeIn(float duration)
    {
        FadeIn(duration, false);
    }
    public void FadeOut(float duration)
    {
        FadeOut(duration, false);
    }
    public void FadeInUseCurrentAlpha(float duration)
    {
        FadeIn(duration, true);
    }
    public void FadeOutUseCurrentAlpha(float duration)
    {
        FadeOut(duration, true);
    }
    void FadeIn(float duration, bool useCurrentAlpha)
    {
        if (coroutine != null)
            StopCoroutine(coroutine);
        coroutine = StartCoroutine(DoFade(duration, 1, useCurrentAlpha));
    }

    void FadeOut(float duration, bool useCurrentAlpha)
    {
        if (coroutine != null)
            StopCoroutine(coroutine);
        coroutine = StartCoroutine(DoFade(duration, -1, useCurrentAlpha));
    }

    IEnumerator DoFade(float duration, float direction, bool useCurrentAlpha)
    {
        float endValue = direction == 1 ? 1 : 0;
        float timer = 0;
        float currentValue = useCurrentAlpha ? Sphere_Alpha : direction == 1 ? 0 : 1;
        while ((direction == -1 && Sphere_Alpha != 0) || (direction == 1 && Sphere_Alpha != 1))
        {
            timer += Time.deltaTime;
            Sphere_Alpha = Mathf.Lerp(currentValue, endValue, timer / duration);
            yield return 0;
        }
    }
}