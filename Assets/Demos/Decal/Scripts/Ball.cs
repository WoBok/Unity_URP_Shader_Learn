using System;
using System.Collections;
using UnityEngine;

public class Ball : MonoBehaviour
{
    public Action<Vector3, Vector3> onBallCollisionEntered;

    Rigidbody rigibody;

    Vector3[] velocities = new Vector3[5];
    int frameCount = 0;

    Material material;
    void Start()
    {
        material = GetComponent<Renderer>().material;
        rigibody = GetComponent<Rigidbody>();
        StartCoroutine(DestroySelf());
    }
    void Update()
    {
        var velocity = rigibody.velocity;
        velocities[frameCount] = velocity.normalized;
        frameCount++;
        frameCount %= velocities.Length;

        material.SetFloat("_Speed", velocities.Length);
    }
    //The physics cycle may happen more than once per frame if the fixed time step is less than the actual frame update time
    //我需要在球碰撞到物体之后获得此时球的运动方向，但OnCollisionEnter捕获的velocity应该是碰撞后得到的
    void OnCollisionEnter(Collision collision)
    {
        var velocitiesSum = Vector3.zero;
        for (int i = 0; i < velocities.Length; i++)
        {
            velocitiesSum += velocities[i];
        }
        var velocityDirection = (velocitiesSum / velocities.Length).normalized;//将多帧的运动方向平均

        onBallCollisionEntered?.Invoke(transform.position, velocityDirection);

        Destroy(gameObject);
    }

    IEnumerator DestroySelf()
    {
        yield return new WaitForSeconds(5);
        Destroy(gameObject);
    }
}