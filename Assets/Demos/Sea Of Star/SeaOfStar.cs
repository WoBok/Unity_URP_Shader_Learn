using UnityEngine;

public class SeaOfStar : MonoBehaviour
{
    public Material material;
    public int count;
    void OnRenderObject()
    {
        material.SetPass(0);
        Graphics.DrawProceduralNow(MeshTopology.Quads, 9, count);
    }
}