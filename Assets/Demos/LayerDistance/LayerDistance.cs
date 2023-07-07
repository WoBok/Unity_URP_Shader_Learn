using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LayerDistance : MonoBehaviour
{
   public float[] distance;  
    void Start()
    {
        Camera.main.layerCullDistances = distance;
    }

}
