using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class UpdateAllChildrenMaterials : MonoBehaviour
{
    [Serializable]
    public struct ScalarValue
    {
        public string name;
        public float value;
    }
    [Serializable]
    public struct ColorValue
    {
        public string name;
        public Color value;
    }

    public bool needToUpdate;

    public ScalarValue scalarValue1;
    public ScalarValue scalarValue2;
    public ScalarValue scalarValue3;
    public ScalarValue scalarValue4;
    public ScalarValue scalarValue5;

    public ColorValue colorValue1;
    public ColorValue colorValue2;
    public ColorValue colorValue3;
    public ColorValue colorValue4;
    public ColorValue colorValue5;

    public static List<Material> materials = new List<Material>();

    public static void DestroyAllMaterials()
    {
        foreach (Material mat in materials)
        {
            Destroy(mat);
        }
        materials.Clear();
    }
    void Update()
    {
        if (needToUpdate)
            UpdateMaterialProperties();
    }
    void OnValidate()
    {
        if (needToUpdate)
            UpdateMaterialProperties();
    }
    void UpdateMaterialProperties()
    {
#if UNITY_EDITOR
        Material[] allMaterials;
        if (EditorApplication.isPlaying)
        {
            allMaterials = GetComponentsInChildren<Renderer>().Select(r => r.material).ToArray();
            materials.AddRange(allMaterials);
        }
        else
        {
            allMaterials = GetComponentsInChildren<Renderer>().Select(r => r.sharedMaterial).ToArray();
        }
#else
        var allMaterials = GetComponentsInChildren<Renderer>().Select(r => r.material);
         materials.AddRange(allMaterials);
#endif

        foreach (var material in allMaterials)
        {
            UpdateScalarValue(material, scalarValue1.name, scalarValue1.value);
            UpdateScalarValue(material, scalarValue2.name, scalarValue2.value);
            UpdateScalarValue(material, scalarValue3.name, scalarValue3.value);
            UpdateScalarValue(material, scalarValue4.name, scalarValue4.value);
            UpdateScalarValue(material, scalarValue5.name, scalarValue5.value);

            UpdateColorValue(material, colorValue1.name, colorValue1.value);
            UpdateColorValue(material, colorValue2.name, colorValue2.value);
            UpdateColorValue(material, colorValue3.name, colorValue3.value);
            UpdateColorValue(material, colorValue4.name, colorValue4.value);
            UpdateColorValue(material, colorValue5.name, colorValue5.value);
        }
    }
    void UpdateScalarValue(Material material, string name, float value)
    {
        if (string.IsNullOrEmpty(name)) return;
        if (IsShaderProperty(material, name, ShaderPropertyType.Float))
            material.SetFloat(name, value);
    }
    void UpdateColorValue(Material material, string name, Color value)
    {
        if (string.IsNullOrEmpty(name)) return;
        if (IsShaderProperty(material, name, ShaderPropertyType.Color))
            material.SetColor(name, value);
    }
    bool IsShaderProperty(Material material, string name, ShaderPropertyType propertyType)
    {
        if (!material.HasProperty(name)) return false;

        var shader = material.shader;
        var propertyIndex = shader.FindPropertyIndex(name);
        var type = shader.GetPropertyType(propertyIndex);
        return type == propertyType;
    }
}