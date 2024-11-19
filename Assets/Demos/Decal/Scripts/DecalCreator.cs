using UnityEngine;

public class DecalCreator : MonoBehaviour
{
    public GameData gameData;
    public void Create(Vector3 position, Vector3 direction)
    {
        var decalObj = Instantiate(gameData.decalPrefab, position, Quaternion.LookRotation(direction));
        decalObj.transform.rotation = Quaternion.AngleAxis(Random.Range(0, 360), direction);
        var decal = decalObj.AddComponent<Decal>();
        decal.gameData = gameData;
    }
}