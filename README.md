# unity-trae-skills

一组可复用的 Unity Trae Skills，面向 Unity 项目初始化与 UI 页面转场接入场景。

## 包含的 Skills

### `unity-project-assets-bootstrap`

用于初始化 Unity 项目的 `Assets` 标准目录结构。

默认会补齐以下目录：

- `Assets/Sprites`
- `Assets/Scripts`
- `Assets/StreamingAssets`
- `Assets/Fonts`
- `Assets/Materials`
- `Assets/Prefabs`
- `Assets/Scenes`
- `Assets/Shaders`
- `Assets/Editor`

适用场景：

- 新建 Unity 项目后快速补齐基础目录
- 为现有项目补齐常用资源目录

### `unity-ui-transition-system`

用于在 Unity 项目中接入可复用的 UI 页面过渡系统。

核心能力：

- 接入 `ScreenTransitionPlayer`
- 创建或复用转场 Shader 与材质
- 在 `Canvas` 上挂接全屏转场层
- 将页面切换改造成统一的转场入口
- 尽量保留用户手工微调过的 UI 布局

当前仓库已附带可直接复用的资源：

- `Runtime/Scripts/ScreenTransitionPlayer.cs`
- `Runtime/Shaders/UITransitionInkSpread.shader`
- `Runtime/Shaders/UITransitionPixelMosaic.shader`
- `Runtime/Shaders/UITransitionGlitchSlices.shader`
- `Runtime/Shaders/UITransitionRadial.shader`
- `Samples~/Materials/*.mat` 示例材质球
- `Editor/TransitionMaterialPresetCreator.cs` 一键生成示例材质脚本

适用场景：

- 展项项目
- 大屏项目
- 答题系统
- 多页面 UI 切换系统

## 使用方式

将对应 skill 目录放到 Trae 的全局 skills 目录下，或直接作为个人 skill 仓库维护。

常见调用示例：

```text
Use Skill: unity-project-assets-bootstrap
```

```text
Use Skill: unity-ui-transition-system
```

## 目录结构

```text
unity-trae-skills/
├─ README.md
├─ unity-project-assets-bootstrap/
│  └─ SKILL.md
└─ unity-ui-transition-system/
   ├─ SKILL.md
   ├─ Editor/
   ├─ Runtime/
   └─ Samples~/
```