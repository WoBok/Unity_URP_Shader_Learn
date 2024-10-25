using UnityEngine;

public class DotAngle : MonoBehaviour
{
    public Transform vec1Trans;
    public Transform vec2Trans;
    float Magnitude(Vector2 vec)
    {
        return Mathf.Sqrt(vec.x * vec.x + vec.y * vec.y);
    }
    float Dot(Vector2 v1, Vector2 v2)
    {
        return v1.x * v2.x + v1.y * v2.y;
    }
    float Cross(Vector2 v1, Vector2 v2)
    {
        return v1.x * v2.y + v1.y * v2.x;
    }
    void OnGUI()
    {
        if (GUILayout.Button("Print"))
        {
            print(Vector2.Angle(Vector2.zero, Vector2.zero));
            var vec1 = new Vector2(vec1Trans.position.x, vec1Trans.position.z);
            var vec2 = new Vector2(vec2Trans.position.x, vec2Trans.position.z);
            var v1Dotv2 = Dot(vec1, vec2);
            var v = vec1 / 0;
            print(v);
            print(3f / 0f);
            print(v1Dotv2);
            var v1Magnitude = Magnitude(vec1);
            var v2Magnitude = Magnitude(vec2);
            print(v1Magnitude);
            print(v2Magnitude);
            print(v1Magnitude * v2Magnitude);
            print(v1Dotv2 / (v1Magnitude * v2Magnitude));
            print(Mathf.Acos(v1Dotv2 / (v1Magnitude * v2Magnitude)));
        }
        if (GUILayout.Button("Roate90"))
        {
            vec2Trans.transform.position = new Vector3(vec1Trans.position.z, 0, -vec1Trans.position.x);
        }
        if (GUILayout.Button("Cross"))
        {
            var vec1 = new Vector2(vec1Trans.position.x, vec1Trans.position.z);
            var vec2 = new Vector2(vec2Trans.position.x, vec2Trans.position.z);
            print(Cross(vec1, vec2));
        }
    }
    void OnDrawGizmos()
    {
        if (vec1Trans)
            Gizmos.DrawLine(Vector3.zero, vec1Trans.position);
        if (vec2Trans)
            Gizmos.DrawLine(Vector3.zero, vec2Trans.position);
    }
}