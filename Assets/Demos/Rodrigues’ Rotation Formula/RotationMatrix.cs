using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotationMatrix
{
   public static Matrix4x4 GetXAxisRotationMatrix(float angle)
    {
        angle *= Mathf.Deg2Rad;
        var cosValue = Mathf.Cos(angle);
        var sinValue = Mathf.Sin(angle);
        var m0 = new Vector4(1, 0, 0, 0);
        var m1 = new Vector4(0, cosValue, -sinValue, 0);
        var m2 = new Vector4(0, sinValue, cosValue, 0);
        var m3 = new Vector4(0, 0, 0, 1);
        return new Matrix4x4(m0, m1, m2, m3);
    }
    public static Matrix4x4 GetYAxisRotationMatrix(float angle)
    {
        angle *= Mathf.Deg2Rad;
        var cosValue = Mathf.Cos(angle);
        var sinValue = Mathf.Sin(angle);
        var m0 = new Vector4(cosValue, 0, sinValue, 0);
        var m1 = new Vector4(0, 1, 0, 0);
        var m2 = new Vector4(-sinValue, 0, cosValue, 0);
        var m3 = new Vector4(0, 0, 0, 1);
        return new Matrix4x4(m0, m1, m2, m3);
    }
    public static Matrix4x4 GetZAxisRotationMatrix(float angle)
    {
        angle *= Mathf.Deg2Rad;
        var cosValue = Mathf.Cos(angle);
        var sinValue = Mathf.Sin(angle);
        var m0 = new Vector4(cosValue, -sinValue, 0, 0);
        var m1 = new Vector4(sinValue, cosValue, 0, 0);
        var m2 = new Vector4(0, 0, 1, 0);
        var m3 = new Vector4(0, 0, 0, 1);
        return new Matrix4x4(m0, m1, m2, m3);
    }
}
