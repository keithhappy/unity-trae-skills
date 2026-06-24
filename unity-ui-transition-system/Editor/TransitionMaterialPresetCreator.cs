using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 为仓库中附带的转场 Shader 快速生成一组可直接试用的材质球。
/// </summary>
public static class TransitionMaterialPresetCreator
{
    private const string OutputFolder = "Assets/Materials/TraeTransitions";

    [MenuItem("Tools/Trae/Transitions/Generate Sample Materials")]
    public static void GenerateSampleMaterials()
    {
        EnsureFolder("Assets/Materials");
        EnsureFolder(OutputFolder);

        CreateMaterial(
            "Custom/UI/Transition/InkSpread",
            "TraeTransitionInkSpread",
            new Dictionary<string, float>
            {
                { "_Progress", 0f },
                { "_NoiseScale", 10f },
                { "_SpreadPower", 1.4f },
                { "_EdgeSoftness", 0.05f }
            });

        CreateMaterial(
            "Custom/UI/Transition/PixelMosaic",
            "TraeTransitionPixelMosaic",
            new Dictionary<string, float>
            {
                { "_Progress", 0f },
                { "_PixelSizeMin", 1f },
                { "_PixelSizeMax", 28f },
                { "_FadeSoftness", 0.06f }
            });

        CreateMaterial(
            "Custom/UI/Transition/GlitchSlices",
            "TraeTransitionGlitchSlices",
            new Dictionary<string, float>
            {
                { "_Progress", 0f },
                { "_SliceCount", 42f },
                { "_OffsetStrength", 0.05f },
                { "_Softness", 0.05f }
            });

        CreateMaterial(
            "Custom/UI/Transition/Radial",
            "TraeTransitionRadial",
            new Dictionary<string, float>
            {
                { "_Progress", 0f },
                { "_Softness", 0.05f }
            });

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("已生成 TraeTransitions 示例材质球。");
    }

    /// <summary>
    /// 创建单个转场材质，并根据传入参数写入默认数值。
    /// </summary>
    private static void CreateMaterial(string shaderName, string materialName, IReadOnlyDictionary<string, float> floatProperties)
    {
        var shader = Shader.Find(shaderName);
        if (shader == null)
        {
            Debug.LogWarning($"未找到 Shader: {shaderName}");
            return;
        }

        var path = $"{OutputFolder}/{materialName}.mat";
        var material = AssetDatabase.LoadAssetAtPath<Material>(path);
        if (material == null)
        {
            material = new Material(shader);
            AssetDatabase.CreateAsset(material, path);
        }
        else
        {
            material.shader = shader;
        }

        foreach (var pair in floatProperties)
        {
            if (material.HasProperty(pair.Key))
            {
                material.SetFloat(pair.Key, pair.Value);
            }
        }

        EditorUtility.SetDirty(material);
    }

    /// <summary>
    /// 逐级确保 Unity 工程中的资源目录存在。
    /// </summary>
    private static void EnsureFolder(string assetPath)
    {
        if (AssetDatabase.IsValidFolder(assetPath))
        {
            return;
        }

        var segments = assetPath.Split('/');
        var current = segments[0];
        for (var index = 1; index < segments.Length; index++)
        {
            var next = $"{current}/{segments[index]}";
            if (!AssetDatabase.IsValidFolder(next))
            {
                AssetDatabase.CreateFolder(current, segments[index]);
            }

            current = next;
        }
    }
}