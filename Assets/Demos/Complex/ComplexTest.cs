using System.Collections.Generic;
using UnityEngine;
using Complex = System.Numerics.Complex;

public class ComplexTest : MonoBehaviour
{
    void Start()
    {
        var lineRender = GetComponent<LineRenderer>();
        var positions = new List<Vector3>();
        var i = Complex.ImaginaryOne;
        var pi = Mathf.PI;
        for (double j = 0; j <= 2 * pi; j += 2 * pi * 0.01f)
        {
            var p = Complex.Exp(j * i);
            positions.Add(new Vector3((float)p.Real, (float)p.Imaginary, 0));
        }
        lineRender.positionCount = positions.Count;
        lineRender.SetPositions(positions.ToArray());
    }
}