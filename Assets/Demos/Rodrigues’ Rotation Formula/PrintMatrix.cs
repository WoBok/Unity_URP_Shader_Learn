using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrintMatrix : MonoBehaviour
{
    void Start()
    {
        Matrix4x4 matrix = new Matrix4x4();
        for (int i = 0; i < 16; i++)
        {
            matrix[i] = i;
        }
        var v4 = matrix.GetColumn(0);
        print(v4);
    }

}
