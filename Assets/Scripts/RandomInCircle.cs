using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomInCircle : MonoBehaviour
{
    [Tooltip("预制体")]
    public GameObject prefab;
    [Tooltip("总量")]
    public int sum;
    [Tooltip("持续时长")]
    public float duration;
    [Tooltip("半径")]
    public float radius;
    [Tooltip("最小缩放")]
    public float minSize;
    [Tooltip("最大缩放")]
    public float maxSize;
    [Tooltip("间隔时间")]
    public float interval;

    List<GameObject> objs = new List<GameObject>();
    void OnEnable()
    {
        StartCoroutine(Create());
    }
    void OnDisable()
    {
        StopAllCoroutines();
        Clear();
    }
    IEnumerator Create()
    {
        int count = 0;
        int onceCount = (int)(sum / duration * interval);
        while (count <= sum)
        {
            for (int i = 0; i < onceCount; i++)
            {
                var randomPosition = Random.insideUnitCircle * radius;
                var position = new Vector3(randomPosition.x, 0, randomPosition.y) + transform.position;

                var size = Random.Range(minSize, maxSize);

                var obj = Instantiate(prefab, position, Quaternion.identity);
                obj.transform.localScale = Vector3.one * size;
                objs.Add(obj);
                yield return new WaitForSeconds(Random.Range(0, interval / onceCount));
            }
            count += onceCount;
            yield return new WaitForSeconds(interval);
        }

        yield return new WaitForSeconds(5);
        Clear();
    }
    void Clear()
    {
        foreach (GameObject obj in objs)
        {
            Destroy(obj);
        }
        objs.Clear();
    }
    void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        for (int i = 0; i <= 100; i++)
        {
            var angle1 = i * 2 * Mathf.PI / 100;
            var x1 = Mathf.Cos(angle1) * radius;
            var z1 = Mathf.Sin(angle1) * radius;
            var angle2 = (i + 1) % 100 * 2 * Mathf.PI / 100;
            var x2 = Mathf.Cos(angle2) * radius;
            var z2 = Mathf.Sin(angle2) * radius;
            var y = transform.position.y;
            Gizmos.DrawLine(new Vector3(x1, y, z1), new Vector3(x2, y, z2));
        }
    }
}