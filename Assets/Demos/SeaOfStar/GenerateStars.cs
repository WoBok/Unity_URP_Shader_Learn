using UnityEngine;

public class GenerateStars : MonoBehaviour
{
    public Vector3 boxSize = new Vector3(5, 0.3f, 3);
    public GameObject start;
    public int sum;
    void Start()
    {
        Generate();
    }
    void Generate()
    {
        for (int i = 0; i < sum; i++)
        {
            var start = Instantiate(this.start);
            start.transform.SetParent(this.transform);
            var position = new Vector3(Random.Range(0, boxSize.x), Random.Range(0, boxSize.y), Random.Range(0, boxSize.z));
            start.transform.localPosition = position;
            start.transform.localScale = Vector3.one * Random.Range(0.03f, 0.04f);
            start.GetComponent<SingleStarSimulator>().movementSpeed = Random.Range(0.05f,0.2f);
        }
    }
}