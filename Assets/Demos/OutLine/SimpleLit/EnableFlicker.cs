using UnityEngine;

public class EnableFlicker : MonoBehaviour
{
    Material material;//shaderÎªLiQingZhao/Outline SimpleµÄ²ÄÖÊ
    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
    }

    void Update()
    {
        //if (Input.GetKeyDown(KeyCode.A))
        //{
        //    if (material != null)
        //    {
        //        material.EnableKeyword("_FLICKERSWITCH_ON");
        //    }
        //}
        //if (Input.GetKeyDown(KeyCode.S))
        //{
        //    if (material != null)
        //    {
        //        material.DisableKeyword("_FLICKERSWITCH_ON");
        //    }
        //}

        if (Input.GetKeyDown(KeyCode.D))
        {
            if (material != null)
            {
                material.SetFloat("_FlickerFrequency", 3);
            }
        }
        if (Input.GetKeyDown(KeyCode.F))
        {
            if (material != null)
            {
                material.SetFloat("_FlickerFrequency", 0);
            }
        }
    }
}