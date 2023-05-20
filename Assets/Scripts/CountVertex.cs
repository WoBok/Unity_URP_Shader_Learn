using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CountVertex : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        print($"vertex count:{GetComponent<MeshFilter>().mesh.vertexCount}");
        print($"vertex count:{GetComponent<MeshFilter>().mesh.triangles.Length}");
    }

    // Update is called once per frame
    void Update()
    {

    }
}
