using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomCreateGameObject : MonoBehaviour
{
    [Tooltip("预制体")]
    public GameObject prefab;
    [Tooltip("最小数量")]
    public int minSum;
    [Tooltip("最大数量")]
    public int maxSum;
    [Tooltip("一次产生的最小数量")]
    public int minSumAtATime;
    [Tooltip("一次产生的最大数量")]
    public int maxSumAtATime;
    [Tooltip("最小间隔时间")]
    public float minIntervalTime;
    [Tooltip("最大间隔时间")]
    public float maxIntervalTime;
    [Tooltip("最小缩放")]
    public float minScale;
    [Tooltip("最大缩放")]
    public float maxScale;
    [Tooltip("销毁时间")]
    public float destructionTime;
    List<GameObject> objects = new List<GameObject>();
    List<Vector3> generationPositionWS = new List<Vector3>();
    [Tooltip("被附着的所有物体")]
    public List<GameObject> attachedGameObjects;
    void OnEnable()
    {
        GetAllGenerationPositionWS();

        CreateGameObject();
    }
    void OnDisable()
    {
        StopCoroutine("DestroyObject");
        foreach (GameObject obj in objects)
        {
            Destroy(obj);
        }
        objects.Clear();
    }
    void GetAllGenerationPositionWS()
    {
        generationPositionWS.Clear();
        for (int i = 0; i < attachedGameObjects.Count; i++)
        {
            generationPositionWS.AddRange(GetGenerationPositionWS(attachedGameObjects[i]));
        }
    }
    Vector3[] GetGenerationPositionWS(GameObject attachedGameObject)
    {

        var vertex = attachedGameObject.GetComponent<MeshFilter>().mesh.vertices;
        var generationPositionWS = new Vector3[vertex.Length];
        for (int i = 0; i < generationPositionWS.Length; i++)
        {
            generationPositionWS[i] = attachedGameObject.transform.TransformPoint(vertex[i]);
        }
        return generationPositionWS;
    }
    public void CreateGameObject()
    {
        StartCoroutine("Create");
    }

    IEnumerator Create()
    {
        int sum = Random.Range(minSum, maxSum + 1);
        int currentSum = 0;
        while (currentSum < sum)
        {
            var sumAtATime = Random.Range(minSumAtATime, minSumAtATime + 1);
            for (int i = 0; i < sumAtATime; i++)
            {
                currentSum++;
                var pos = generationPositionWS[Random.Range(0, generationPositionWS.Count + 1)];
                var obj = Instantiate(prefab, pos, Quaternion.Euler(new Vector3(Random.Range(-30, 30.0f), Random.Range(0, 360.0f), Random.Range(-30, 30.0f))));
                obj.transform.localScale = Vector3.one * Random.Range(minScale, maxScale);
                objects.Add(obj);
                StartCoroutine(DestroyObject(obj));
            }
            yield return new WaitForSeconds(Random.Range(minIntervalTime, maxIntervalTime));
        }
    }
    IEnumerator DestroyObject(GameObject obj)
    {
        yield return new WaitForSeconds(destructionTime);
        Destroy(obj);
    }
}
