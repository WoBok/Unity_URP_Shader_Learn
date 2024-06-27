using Unity.Mathematics;
using UnityEngine;

public class CommonFunction : MonoBehaviour
{
    void Start()
    {
        double x = math.modf(-12.0156743d, out double i);
        print($"{i},{x}");
        print("--------------------------------------------------");
        float s1 = math.step(1f, 0f);
        float s2 = math.step(1f, 1f);
        float s3 = math.step(1f, 2f);
        print($"{s1}, {s2}, {s3}");
    }
}