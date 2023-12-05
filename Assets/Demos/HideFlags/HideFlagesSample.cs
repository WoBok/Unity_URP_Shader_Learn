using UnityEngine;

public class HideFlagesSample : MonoBehaviour
{
    public GameObject gObj;
    void Start()
    {
        var material = new Material(Shader.Find("URP Shader/Lit"));
        material.hideFlags = HideFlags.HideAndDontSave;
        gObj.GetComponent<Renderer>().material = material;

        var g = GameObject.CreatePrimitive(PrimitiveType.Cube);
        g.name = "A cube";
        g.hideFlags = HideFlags.HideInHierarchy;
    }
}