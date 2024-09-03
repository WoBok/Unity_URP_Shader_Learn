using UnityEditor;
using UnityEngine;

public class ReflectionVector : MonoBehaviour
{
    public Vector2 L;
    public Vector2 N;
    Vector2 R;
    void Start()
    {
        R = 2 * N.normalized * Vector2.Dot(N.normalized, L) - L;
        print("L, N: "+Vector2.Angle(L,N));
        print("N, R: "+Vector2.Angle(N,R));
    }
    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawLine(Vector3.zero, new Vector3(L.x, L.y, 0).normalized);
        Handles.Label(L,"L");
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(Vector3.zero, new Vector3(N.x, N.y, 0).normalized);
        Handles.Label(N, "N");
        Gizmos.color = Color.green;
        Gizmos.DrawLine(Vector3.zero, new Vector3(R.x, R.y, 0));
        Handles.Label(R, "R");
    }
}