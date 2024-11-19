using System.Collections;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class Decal : MonoBehaviour
{
    public GameData gameData;
    void Start()
    {
        StartCoroutine(FadeAndDestroy());
    }

    IEnumerator FadeAndDestroy()
    {
        yield return new WaitForSeconds(gameData.decalLifeTime);

        var projector = GetComponent<DecalProjector>();
        projector.size = new Vector3(Random.Range(1.75f, 3.25f), Random.Range(2.25f, 3.25f), 5);

        var material = projector.material;
        var newMaterial = new Material(material);
        GetComponent<DecalProjector>().material = newMaterial;

        var fadeValue = material.GetFloat("_Fade");

        while (fadeValue > -1)
        {
            fadeValue -= Time.deltaTime * gameData.fadeSpeed;
            newMaterial.SetFloat("_Fade", fadeValue);
            yield return null;
        }
        Destroy(gameObject);
    }
}