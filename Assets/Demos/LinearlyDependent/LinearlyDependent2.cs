using UnityEngine;


public class LinearlyDependent2 : MonoBehaviour
{
    Matrix4x4 m_Matrix = new Matrix4x4()
    {
        m00 = 2,
        m01 = -2,
        m10 = 1,
        m11 = -1,
    };
    void OnGUI()
    {
        if (GUILayout.Button("Trans"))
        {
            Vector3[] points = new Vector3[2];
            GetComponent<LineRenderer>().GetPositions(points);
            for (int i = 0; i < points.Length; i++)
            {
                points[i] = m_Matrix * points[i];
            }
            GetComponent<LineRenderer>().SetPositions(points);
        }
    }
}