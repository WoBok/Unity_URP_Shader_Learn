using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AndTest : MonoBehaviour
{
    void Start()
    {
        int a = (3 & 1);
        print(a);
        int b = (100 & 1);
        print(b);
    }
}
