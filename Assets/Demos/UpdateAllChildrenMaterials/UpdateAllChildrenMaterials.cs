using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;

public class UpdateAllChildrenMaterials : MonoBehaviour
{
    public string scalarName = "";
    public float scalarValue = 1;
    public string colorName = "";
    public Color colorValue = Color.white;

    string m_CachedScalarName;
    float m_CachedScalarValue;
    string m_CachedColorName;
    Color m_CachedColorValue;

    void Start()
    {
        UpdateCache();
    }

    void Update()
    {
        UpdateMaterialProperties();
    }
    void OnValidate()
    {
        UpdateMaterialProperties();
    }
    void UpdateMaterialProperties()
    {
        var needToUpdate = m_CachedScalarName != scalarName ||
                                 m_CachedScalarValue != scalarValue ||
                                 m_CachedColorName != colorName ||
                                 m_CachedColorValue != colorValue;
        if (needToUpdate)
        {
            var allMaterials = GetComponentsInChildren<Renderer>().Select(r => r.sharedMaterial);
            if (scalarName != null && scalarName != "")
            {
                foreach (var material in allMaterials)
                {
                    if (IsShaderProperty(material, scalarName, ShaderPropertyType.Float))
                        material.SetFloat(scalarName, scalarValue);
                }
            }
            if (colorName != null && colorName != "")
            {
                foreach (var material in allMaterials)
                {
                    if (IsShaderProperty(material, colorName, ShaderPropertyType.Color))
                        material.SetColor(colorName, colorValue);
                }
            }
            UpdateCache();
        }
    }
    void UpdateCache()
    {
        m_CachedScalarName = scalarName;
        m_CachedColorName = colorName;
        m_CachedScalarValue = scalarValue;
        m_CachedColorValue = colorValue;
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