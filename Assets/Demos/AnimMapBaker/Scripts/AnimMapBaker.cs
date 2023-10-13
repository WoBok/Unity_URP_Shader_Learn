/*
 * Created by jiadong chen
 * https://jiadong-chen.medium.com/
 * 用来烘焙动作贴图。烘焙对象使用Animation组件，并且在导入时设置Rig为Legacy
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
using System.IO;

/// <summary>
/// 保存需要烘焙的动画的相关数据
/// </summary>
public struct AnimData
{
    #region FIELDS

    private int _vertexCount;
    private int _mapWidth;
    private readonly List<AnimationState> _animClips;
    private string _name;

    private Animation _animation;
    private SkinnedMeshRenderer _skin;

    public List<AnimationState> AnimationClips => _animClips;
    public int MapWidth => _mapWidth;
    public string Name => _name;

    #endregion

    public AnimData(Animation anim, SkinnedMeshRenderer smr, string goName)
    {
        _vertexCount = smr.sharedMesh.vertexCount;
        _mapWidth = Mathf.NextPowerOfTwo(_vertexCount);
        _animClips = new List<AnimationState>(anim.Cast<AnimationState>());
        _animation = anim;
        _skin = smr;
        _name = goName;
    }

    #region METHODS

    public void AnimationPlay(string animName)
    {
        _animation.Play(animName);
    }

    public void SampleAnimAndBakeMesh(ref Mesh m)
    {
        SampleAnim();
        BakeMesh(ref m);
    }

    private void SampleAnim()
    {
        if (_animation == null)
        {
            Debug.LogError("animation is null!!");
            return;
        }

        _animation.Sample();
    }

    private void BakeMesh(ref Mesh m)
    {
        if (_skin == null)
        {
            Debug.LogError("skin is null!!");
            return;
        }

        _skin.BakeMesh(m);
    }


    #endregion

}

/// <summary>
/// 烘焙后的数据
/// </summary>
public struct BakedData
{
    #region FIELDS

    private readonly string _name;
    private readonly string _normalName;
    private readonly float _animLen;
    private readonly byte[] _rawAnimMap;
    private readonly byte[] _rawNormalMap;
    private readonly int _animMapWidth;
    private readonly int _animMapHeight;

    #endregion

    public BakedData(string name, string normalName, float animLen, Texture2D animMap, Texture2D normalMap)
    {
        _name = name;
        _normalName = normalName;
        _animLen = animLen;
        _animMapHeight = animMap.height;
        _animMapWidth = animMap.width;
        _rawAnimMap = animMap.GetRawTextureData();
        _rawNormalMap = normalMap.GetRawTextureData();
    }

    public int AnimMapWidth => _animMapWidth;

    public string Name => _name;
    public string NormalName => _normalName;

    public float AnimLen => _animLen;

    public byte[] RawAnimMap => _rawAnimMap;
    public byte[] RawNormalMap => _rawNormalMap;

    public int AnimMapHeight => _animMapHeight;
}

/// <summary>
/// 烘焙器
/// </summary>
public class AnimMapBaker
{

    #region FIELDS

    private AnimData? _animData = null;
    private Mesh _bakedMesh;
    private readonly List<Vector3> _vertices = new List<Vector3>();
    private readonly List<BakedData> _bakedDataList = new List<BakedData>();

    #endregion

    #region METHODS

    public void SetAnimData(GameObject go)
    {
        if (go == null)
        {
            Debug.LogError("go is null!!");
            return;
        }

        var anim = go.GetComponent<Animation>();
        var smr = go.GetComponentInChildren<SkinnedMeshRenderer>();

        if (anim == null || smr == null)
        {
            Debug.LogError("anim or smr is null!!");
            return;
        }
        _bakedMesh = new Mesh();
        _animData = new AnimData(anim, smr, go.name);
    }

    public List<BakedData> Bake()
    {
        if (_animData == null)
        {
            Debug.LogError("bake data is null!!");
            return _bakedDataList;
        }

        //每一个动作都生成一个动作图
        foreach (var t in _animData.Value.AnimationClips)
        {
            if (!t.clip.legacy)
            {
                Debug.LogError(string.Format($"{t.clip.name} is not legacy!!"));
                continue;
            }
            BakePerAnimClip(t);
        }

        return _bakedDataList;
    }

    private void BakePerAnimClip(AnimationState curAnim)
    {
        var curClipFrame = 0;
        float sampleTime = 0;
        float perFrameTime = 0;

        curClipFrame = Mathf.ClosestPowerOfTwo((int)(curAnim.clip.frameRate * curAnim.length));
        perFrameTime = curAnim.length / curClipFrame; ;

        var animMap = new Texture2D(_animData.Value.MapWidth, curClipFrame, TextureFormat.RGBAHalf, true);
        animMap.name = string.Format($"{_animData.Value.Name}_{curAnim.name}.animMap");
        var normalMap = new Texture2D(_animData.Value.MapWidth, curClipFrame, TextureFormat.RGBAHalf, true);
        normalMap.name = string.Format($"{_animData.Value.Name}_{curAnim.name}.normalMap");
        _animData.Value.AnimationPlay(curAnim.name);

        for (var i = 0; i < curClipFrame; i++)
        {
            curAnim.time = sampleTime;

            _animData.Value.SampleAnimAndBakeMesh(ref _bakedMesh);

            for (var j = 0; j < _bakedMesh.vertexCount; j++)
            {
                var vertex = _bakedMesh.vertices[j];
                var normal = _bakedMesh.normals[j];
                animMap.SetPixel(j, i, new Color(vertex.x, vertex.y, vertex.z));
                normalMap.SetPixel(j, i, new Color(normal.x, normal.y, normal.z));
            }

            sampleTime += perFrameTime;
        }
        animMap.Apply();
        normalMap.Apply();
        _bakedDataList.Add(new BakedData(animMap.name, normalMap.name, curAnim.clip.length, animMap, normalMap));
    }

    #endregion

}
