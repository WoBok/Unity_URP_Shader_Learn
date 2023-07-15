using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RodriguesRotation : MonoBehaviour
{
    Vector4 originalPosition;
    public float speed;
    public Vector3 axis = Vector3.one;
    void Start()
    {
        originalPosition = transform.position;
    }

    void Update()
    {
        transform.position = RodriguesRotationFormula.GetRotationMatrix(Time.time * speed, axis) * originalPosition;
        print(Vector3.Distance(Vector3.zero, transform.position));
    }
    void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawLine(Vector3.zero, axis * 100);
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(Vector3.zero, transform.position);
    }
}