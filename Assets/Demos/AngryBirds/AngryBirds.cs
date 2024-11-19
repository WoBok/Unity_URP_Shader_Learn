using UnityEngine;

public class AngryBirds : MonoBehaviour
{
    public GameObject catapult;
    public GameObject pill;
    public GameObject pos1;
    public GameObject pos2;

    void Update()
    {
        var direction = catapult.transform.position - pill.transform.position;
        var axis = pos1.transform.position - pos2.transform.position;
        catapult.transform.rotation = Quaternion.LookRotation(direction.normalized, axis.normalized);
    }
}
