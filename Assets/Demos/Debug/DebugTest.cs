using UnityEngine;

public class DebugTest : MonoBehaviour
{
    void Start()
    {
        Func1();
        Func2();
        Func3();
    }
    void Func1()
    {
        print("func1");
        Func2();
    }
    void Func2()
    {
        print("func2");
        Func3();
    }
    void Func3()
    {
        print("func3");
    }
}