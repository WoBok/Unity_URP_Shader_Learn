using System.Collections.Generic;
using UnityEngine;

public class CGCollectTest : MonoBehaviour
{
    public int times;
    void Update()
    {
        List<List<GameObject>> objects = new List<List<GameObject>>();
        for (int i = 0; i < times; i++)
        {
            List<GameObject> gameObjects = new List<GameObject>();
            objects.Add(new List<GameObject>());
            for (int j = 0; j < times; j++)
            {
                gameObjects.Add(new GameObject());
            }
        }
        foreach (var objs in objects)
        {
            foreach (var obj in objs)
            {
                Destroy(obj);
            }
        }
    }
}
