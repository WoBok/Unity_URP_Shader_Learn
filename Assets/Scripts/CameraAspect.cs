using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraAspect : MonoBehaviour
{
    public float aspect = 1;
     void Start()
    {
        print($"<color=blue>aspect: {Camera.main.aspect}</color>");
    }
    void Update()
    {
        print($"<color=blue>aspect: {Camera.main.aspect}</color>");
        //Camera.main.aspect = aspect;
    }
}
