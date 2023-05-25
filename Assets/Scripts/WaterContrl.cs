using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterContrl : MonoBehaviour
{
    public GameObject water;
    public GameObject water1;
    PicoInputSimulator inputSimulator;
    void Start()
    {
        inputSimulator = new PicoInputSimulator();
        inputSimulator.Control.RightA.performed += p =>
        {
            water.SetActive(true);
            water1.SetActive(false);
        };
        inputSimulator.Control.RightB.performed += p =>
        {
            water.SetActive(false);
            water1.SetActive(true);
        };
        inputSimulator.Enable();
    }

}
