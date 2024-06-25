using System.Collections;
using UnityEngine;

public class SingleStarSimulator : MonoBehaviour
{
    public Vector2 regenerateDirectionTime = new Vector2(2, 5);
    public float movementSpeed = 1;
    public float rotationSpeed = 3;
    public Vector3 boxSize = new Vector3(5, 1, 3);

    Vector3 m_TargetDirection;
    Coroutine m_Coroutine;
    void OnEnable()
    {
        m_Coroutine = StartCoroutine(RegenerateDirection());
    }
    void OnDisable()
    {
        if (m_Coroutine != null)
            StopCoroutine(m_Coroutine);
    }
    void FixedUpdate()
    {
        transform.position += transform.forward * movementSpeed * Time.deltaTime;
        var forward = Vector3.Lerp(transform.forward, m_TargetDirection, Time.deltaTime * rotationSpeed);
        transform.rotation = Quaternion.LookRotation(forward);

        var position = transform.localPosition;
        position.x %= boxSize.x;
        position.y %= boxSize.y;
        position.z %= boxSize.z;
        transform.localPosition = position;
    }
    IEnumerator RegenerateDirection()
    {
        while (true)
        {
            m_TargetDirection = new Vector3(Random.value * 2 - 1, 0, Random.value * 2 - 1);
            m_TargetDirection.Normalize();
            yield return new WaitForSeconds(Random.Range(regenerateDirectionTime.x, regenerateDirectionTime.y));
        }
    }
}