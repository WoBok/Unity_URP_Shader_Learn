using UnityEngine;

public class AngryBirds : MonoBehaviour
{
    public GameObject catapult;
    public GameObject pill;

    void Update()
    {
        var direction = catapult.transform.position - pill.transform.position;
        catapult.transform.rotation = Quaternion.LookRotation(direction);
    }
}
