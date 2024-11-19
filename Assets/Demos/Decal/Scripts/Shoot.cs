using System;
using UnityEngine;

public class Shoot : MonoBehaviour
{
    public GameData gameData;

    public Action<GameObject> onShoot;

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            ShootBall();
        }
    }
    void ShootBall()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit))
        {
            Vector3 direction = (hit.point - Camera.main.transform.position).normalized;
            CreateBall(direction);
        }
    }
    void CreateBall(Vector3 direction)
    {
        GameObject ball = Instantiate(gameData.ballPrefab, Camera.main.transform.position, Quaternion.identity);
        Rigidbody rb = ball.GetComponent<Rigidbody>();
        rb.AddForce(direction * gameData.shootForce);
        onShoot?.Invoke(ball);
    }
}