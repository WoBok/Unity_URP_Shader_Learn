using System.Collections;
using UnityEngine;

public class Toucher : MonoBehaviour
{
    Coroutine m_Coroutine;
    void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Paper")
        {
            m_Coroutine = StartCoroutine(Trigger(other.transform.parent));
        }
    }
    void OnTriggerExit(Collider other)
    {
        StopCoroutine(m_Coroutine);
    }

    IEnumerator Trigger(Transform referenceFrame)
    {
        while (true)
        {
            Debug.Log(referenceFrame.InverseTransformPoint(transform.position));
            yield return new WaitForSeconds(0.5f);
        }
    }
}