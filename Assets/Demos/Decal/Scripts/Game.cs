using UnityEngine;

public class Game : MonoBehaviour
{
    public GameObject ballPrefab;
    public GameObject decalPrefab;

    public float shootForce = 1000;
    public float decalLifeTime = 5;
    public float fadeSpeed = 1;

    GameData m_GameData;

    Shoot m_Shoot;
    DecalCreator m_DecalCreator;
    void Start()
    {
        InitGameData();

        InitShoot();
        InitDecalCreator();
    }
    void InitGameData()
    {
        m_GameData = new GameData();

        m_GameData.ballPrefab = ballPrefab;
        m_GameData.decalPrefab = decalPrefab;

        m_GameData.shootForce = shootForce;
        m_GameData.decalLifeTime = decalLifeTime;
        m_GameData.fadeSpeed = fadeSpeed;
    }
    void InitShoot()
    {
        m_Shoot = gameObject.AddComponent<Shoot>();
        m_Shoot.gameData = m_GameData;
        m_Shoot.onShoot += BindBall;
    }

    void InitDecalCreator()
    {
        m_DecalCreator = gameObject.AddComponent<DecalCreator>();
        m_DecalCreator.gameData = m_GameData;
    }

    void BindBall(GameObject ballObj)
    {
        var ball = ballObj.AddComponent<Ball>();
        ball.onBallCollisionEntered += m_DecalCreator.Create;
    }
}