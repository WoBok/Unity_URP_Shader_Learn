using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class Planar_Reflection_camera_Script1 : MonoBehaviour
{
    [ExecuteAlways]
    public Camera Main_camera;
    public Camera Reflection_camera;
    public Camera Scene_Reflection_camera;
    public GameObject Plane;

    private readonly RenderTexture _Reflection_camera_RT;//定义反射RT
    private int _Reflection_camera_RT_ID;//定义主纹理_MainTex属性名称的ID
    public Material Reflection_material;//传入材质

    private readonly RenderTexture _Scene_Reflection_camera_RT;
    private int _Scene_Reflection_camera_RT_ID;

    public Shader shader;

    void Start()//Start函数在脚本运行开始的时候执行
    {
        Debug.Log("Planar Reflection succes!");
        if (this.Reflection_camera == null)
        {
            var R_gameobject = new GameObject("Reflection camera");//申请新组件
            this.Reflection_camera = R_gameobject.AddComponent<Camera>();//获取Camera类型的组件
        }

        RenderPipelineManager.beginCameraRendering += OnBeginCameraRendering;//订阅事件

    }

    void OnBeginCameraRendering(ScriptableRenderContext context, Camera camera)
    {
        if (camera == this.Reflection_camera)
        {
            Update_camera(this.Reflection_camera);
            camera.clearFlags = CameraClearFlags.SolidColor;//清除刚初始化信息的Reflection_camera中的DepthBuffer和ColorBuffer,用Background属性颜色替代
            camera.backgroundColor = Color.clear;//清除掉背景颜色
            camera.cullingMask = LayerMask.GetMask("Reflection");//确定摄像机的渲染层

            var Reflection_camera_M = CalculateReflectionCameraMatrix(this.Plane.transform.up, this.Plane.transform.position);//构建反射矩阵
            Reflection_camera.worldToCameraMatrix = Reflection_camera.worldToCameraMatrix * Reflection_camera_M;//在进VP变换之前
            GL.invertCulling = true;//将裁剪顺序翻转回去，因为反射矩阵的变化会引起裁剪顺序的变化

            //下面进行视锥体裁剪
            Vector4 viewPlane = new Vector4(this.Plane.transform.up.x,
                this.Plane.transform.up.y,
                this.Plane.transform.up.z,
                -Vector3.Dot(this.Plane.transform.position, this.Plane.transform.up));//用四维向量表示平面
            viewPlane = Reflection_camera.worldToCameraMatrix.inverse.transpose * viewPlane;//将世界空间中的平面表示转换成相机空间中的平面表示

            var ClipMatrix = Reflection_camera.CalculateObliqueMatrix(viewPlane);//获取以反射平面为近平面的投影矩阵
            Reflection_camera.projectionMatrix = ClipMatrix;//获取新的投影矩阵

            UniversalRenderPipeline.RenderSingleCamera(context, camera);//摄像机开始渲染

            RenderTexture Reflection_camera_temporary_RT = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);//创建临时的RT（截图保存）

            _Reflection_camera_RT_ID = Shader.PropertyToID("_Reflection_camera_RT");//先获取着色器属性名称_Reflection_camera_RT的唯一标识符_Reflection_camera_RT_ID 
            Shader.SetGlobalTexture(_Reflection_camera_RT_ID, Reflection_camera_temporary_RT);//再利用_Reflection_camera_RT_ID和Reflection_camera_temporary_RT为所有着色器设置一个全局纹理

            camera.targetTexture = Reflection_camera_temporary_RT;//设置自定义的渲染纹理为摄像机的目标纹理，定义完成后，反射相机的输出就会输出到纹理上

            Reflection_material.SetTexture(_Reflection_camera_RT_ID, Reflection_camera_temporary_RT);//将贴图传进材质

            RenderTexture.ReleaseTemporary(Reflection_camera_temporary_RT);//释放掉临时纹理

        }

        else
        {
            GL.invertCulling = false;
        }
    }

    private void OnDisable()
    {
        RenderPipelineManager.beginCameraRendering -= OnBeginCameraRendering;//取消事件订阅
    }

    private void Update_camera(Camera Reflection_camera)//同步两个摄像机的数据，相当于反射相机初始化
    {
        if (Reflection_camera == null || this.Main_camera == null)
            return;
        //先同步两个摄像机的数据，初始化完Reflection_camera后立刻背景颜色和深度的清除，然后设置在相机开始渲染前的各种设置
        int target_display = Reflection_camera.targetDisplay;
        Reflection_camera.CopyFrom(this.Main_camera);
        Reflection_camera.targetDisplay = target_display;

    }


    private Matrix4x4 CalculateReflectionCameraMatrix(Vector3 N, Vector3 plane_position)//计算返回反射矩阵
    {
        //下面计算反射矩阵是在世界空间计算的
        Matrix4x4 Reflection_camera_M = Matrix4x4.identity;//初始化反射矩阵
        float d = -Vector3.Dot(plane_position, N);//d = -dot(P, N),P是平面上的任意一点，N是平面的法向量

        Reflection_camera_M.m00 = 1 - 2 * N.x * N.x;
        Reflection_camera_M.m01 = -2 * N.x * N.y;
        Reflection_camera_M.m02 = -2 * N.x * N.z;
        Reflection_camera_M.m03 = -2 * N.x * d;

        Reflection_camera_M.m10 = -2 * N.x * N.y;
        Reflection_camera_M.m11 = 1 - 2 * N.y * N.y;
        Reflection_camera_M.m12 = -2 * N.y * N.z;
        Reflection_camera_M.m13 = -2 * N.y * d;

        Reflection_camera_M.m20 = -2 * N.x * N.z;
        Reflection_camera_M.m21 = -2 * N.y * N.z;
        Reflection_camera_M.m22 = 1 - 2 * N.z * N.z;
        Reflection_camera_M.m23 = -2 * N.z * d;

        Reflection_camera_M.m30 = 0;
        Reflection_camera_M.m31 = 0;
        Reflection_camera_M.m32 = 0;
        Reflection_camera_M.m33 = 1;

        return Reflection_camera_M;
    }
}

