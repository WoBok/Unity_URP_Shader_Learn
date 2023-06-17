using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUInstancingRotateGameObject : MonoBehaviour
{
    public float speed=5;

    void Update()
    {
        transform.Rotate(Vector3.up, speed);
    }
}
