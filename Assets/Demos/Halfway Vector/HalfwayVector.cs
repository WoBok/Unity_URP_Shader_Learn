using UnityEngine;

public class HalfwayVector : MonoBehaviour
{
    public Vector2 v1;
    public Vector2 v2;
    Vector2 v3;
    void Start()
    {
        v3 = v1.normalized + v2.normalized;
        print("v1v3£º" + Vector2.Angle(v1, v3));
        print("v2v3£º" + Vector2.Angle(v2, v3));
    }
    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawLine(Vector3.zero, new Vector3(v1.x, v1.y, 0).normalized);
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(Vector3.zero, new Vector3(v2.x, v2.y, 0).normalized);
        Gizmos.color = Color.green;
        Gizmos.DrawLine(Vector3.zero, new Vector3(v3.x, v3.y, 0));
    }
}