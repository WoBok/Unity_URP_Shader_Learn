using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateObjectByRotationMatrix : MonoBehaviour
{
    Vector4 originalPosition;
    public float speed = 100;
    void Start()
    {
        originalPosition = transform.position;
    }

    void Update()
    {
        transform.position = RotationMatrix.GetYAxisRotationMatrix(Time.time * speed) * originalPosition;
    }
}
