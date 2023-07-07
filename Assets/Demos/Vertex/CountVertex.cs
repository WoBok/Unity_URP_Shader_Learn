using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CountVertex : MonoBehaviour
{
    void Start()
    {
        string info = "<color=lime>";
        info += $"-------------------------{transform.name}-------------------------";
        info += "</color>\n";
        info += $"vertex count:{GetComponent<MeshFilter>().mesh.vertexCount}\n";
        info += $"vertex count:{GetComponent<MeshFilter>().mesh.triangles.Length}\n";
        var vertices = GetComponent<MeshFilter>().mesh.vertices;
        foreach (var v in vertices)
            info += v + " | ";
        print(info);
    }

}
