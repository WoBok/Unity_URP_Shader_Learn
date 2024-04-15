using UnityEngine;

public class CubicCurve : MonoBehaviour
{
    public Transform a;
    public Transform b;
    public Transform c;
    public Transform d;
    public float delta = 0.05f;
    public float max = 1;


    void OnDrawGizmos()
    {
        if (a & b & c & d)
        {
            for (float f = 0; f < max; f += delta)
            {
                if (f + delta <= max)
                {
                    var a = GetCubicCurvePoint(f);
                    var b = GetCubicCurvePoint(f + delta);
                    Gizmos.DrawLine(a, b);
                }
            }
        }
    }
    Vector3 GetCubicCurvePoint(float t)
    {
        var C = new Matrix4x4(a.position, b.position, c.position, d.position);
        var T = new Vector4(1, t, t * t, t * t * t);

        Vector3 point = C * T;

        return point;
    }
}
