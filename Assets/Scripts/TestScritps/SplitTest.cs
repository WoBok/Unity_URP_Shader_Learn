using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;

public class SplitTest : MonoBehaviour
{
    void Start()
    {
        Regex regex = new Regex(@"(?=[A-Z])");
        string str = "HelloWorldWAWaaaHaha...";
        str = regex.Replace(str, " ");
        print(str);
    }
}
