using System.Collections;
using UnityEngine;

public class CreateFlowersWithinTheRange : MonoBehaviour
{
    [SerializeField]
    [Tooltip("预制体")]
    GameObject flowerPrefab;
    [SerializeField]
    [Tooltip("生成范围：x：左，y：右，z：前")]
    Vector3 m_GenerationRange = new Vector3(-10, 10, 100);
    [SerializeField]
    [Tooltip("旋转范围")]
    Vector2 m_RotationRange = new Vector2(20f, 50f);
    [SerializeField]
    [Tooltip("缩放范围：0-180")]
    Vector2 m_ScaleRange = new Vector2(1, 2);
    [SerializeField]
    [Tooltip("数量")]
    int count = 100;
    [SerializeField]
    [Tooltip("持续时长")]
    float duration = 10;

    GameObject[] m_Objs;
    Coroutine m_Coroutine;
    void OnEnable()
    {
        m_Objs = new GameObject[count];
        StopCoroutine();
        m_Coroutine = StartCoroutine(Generate());
    }
    void OnDisable()
    {
        StopCoroutine();
        Destroy();
    }
    IEnumerator Generate()
    {
        var generationCount = 0;
        var countPerFrame = count / duration * Time.fixedDeltaTime;
        var currentGenCount = 0f;

        var forwardDistance = 0f;
        var forwardStepPerFrame = m_GenerationRange.z / duration * Time.fixedDeltaTime;

        while (generationCount < count)
        {
            currentGenCount += countPerFrame;
            while (currentGenCount >= 1)
            {
                currentGenCount--;
                var obj = Instantiate(flowerPrefab);
                obj.transform.SetParent(transform, false);

                var pX = Random.Range(m_GenerationRange.x, m_GenerationRange.y) * transform.right;
                var pZ = forwardDistance * transform.forward;
                obj.transform.position = transform.position + pX + pZ;

                var dX = Random.Range(m_RotationRange.x / 180, m_RotationRange.y / 180);
                var dXDirection = Random.Range(0, 100f) > 50 ? 1 : -1;
                var dZ = Random.Range(m_RotationRange.x / 180, m_RotationRange.y / 180);
                var dZDirection = Random.Range(0, 100f) > 50 ? 1 : -1;
                obj.transform.rotation = Quaternion.LookRotation(Vector3.up + new Vector3(dX * dXDirection, 0, dZ * dZDirection));

                var scale = Random.Range(m_ScaleRange.x, m_ScaleRange.y);
                obj.transform.localScale = Vector3.one * scale;

                m_Objs[generationCount++] = obj;

                if (generationCount >= count - 1) break;
            }
            forwardDistance += forwardStepPerFrame;
            yield return new WaitForFixedUpdate();
        }
    }
    void StopCoroutine()
    {
        if (m_Coroutine != null)
            StopCoroutine(m_Coroutine);
    }
    void Destroy()
    {
        if (m_Objs != null)
        {
            foreach (var obj in m_Objs)
                Destroy(obj);
            m_Objs = null;
        }
    }
}