using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    PicoInputSimulator input;
    void Start()
    {
        input = new PicoInputSimulator();
        input.Control.LeftX.performed += p =>
        {
            transform.position += Vector3.up;
        };
        input.Control.LeftY.performed += p =>
        {
            transform.position += Vector3.down;
        };
        input.Control.LeftTrigger.performed += p =>
        {
            MobileSSPRRendererFeature.instance.Settings.ShouldRenderSSPR = !MobileSSPRRendererFeature.instance.Settings.ShouldRenderSSPR;
        };
        input.Enable();
    }

}