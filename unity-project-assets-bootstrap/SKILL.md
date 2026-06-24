---
name: "unity-project-assets-bootstrap"
description: "初始化 Unity 项目的 Assets 标准目录结构，自动创建常用资源文件夹。用户提到初始化 Unity 项目文件夹结构或补齐基础目录时调用。"
---

# Unity 项目 Assets 初始化

这个 skill 用于初始化 Unity 项目的标准 `Assets` 目录结构。

当用户希望快速准备 Unity 项目常用资源目录时，使用这个 skill 在目标项目的 `Assets` 目录下创建以下标准空文件夹：

- `Sprites`
- `Scripts`
- `StreamingAssets`
- `Fonts`
- `Materials`
- `Prefabs`
- `Scenes`
- `Shaders`
- `Editor`

## 何时使用

在以下场景中调用这个 skill：

- 用户要求“初始化 Unity 项目文件夹结构”
- 用户要求“创建 Unity 项目的基础目录”
- 用户要求“在 Assets 下创建 Sprites、Scripts、StreamingAssets”
- 用户希望为新 Unity 项目补齐标准资源目录
- 用户希望直接生成 Unity 常用目录模板

## 工作规则

1. 先确认目标 Unity 项目的根目录
2. 检查该目录下是否存在 `Assets`
3. 仅在 `Assets` 目录下创建缺失的标准文件夹：
   - `Assets/Sprites`
   - `Assets/Scripts`
   - `Assets/StreamingAssets`
   - `Assets/Fonts`
   - `Assets/Materials`
   - `Assets/Prefabs`
   - `Assets/Scenes`
   - `Assets/Shaders`
   - `Assets/Editor`
4. 如果某个文件夹已经存在，不要删除、覆盖或重建
5. 不要创建额外目录，除非用户明确提出
6. 完成后验证目录确实存在

## 默认目录说明

- `Sprites`: 图片、图集、UI 切图
- `Scripts`: 运行时代码脚本
- `StreamingAssets`: 运行时原样读取的数据文件
- `Fonts`: 字体资源
- `Materials`: 材质球
- `Prefabs`: 预制体
- `Scenes`: 场景文件
- `Shaders`: Shader 文件
- `Editor`: 编辑器工具脚本

## 执行要求

- 优先使用安全的文件系统或命令工具创建目录
- 使用绝对路径
- 不要改动用户已有文件
- 不要删除任何目录

## 如果信息不完整

如果用户没有明确给出 Unity 项目路径，先根据当前工作区判断是否已经在 Unity 项目根目录。

若仍无法确定目标项目位置，则向用户确认项目根目录后再执行。

## 输出要求

完成后需要明确说明：

- 使用的项目根目录
- 已创建了哪些目录
- 哪些目录原本已存在

## 调用提示

当用户后续说出类似下面的话时，应调用这个 skill：

- “初始化这个 Unity 项目的目录结构”
- “给这个 Unity 工程补齐 Assets 基础目录”
- “创建 Unity 常用文件夹”
- “帮我初始化 Unity 项目目录”
- “在 Assets 下创建标准资源目录”

## 建议执行方式

如果当前工作区已经是 Unity 项目根目录，则直接在当前项目执行。

如果用户给了明确路径，例如：

```text
H:\MyUnityProject
```

则在该项目下执行，确保存在以下目录：

```text
H:\MyUnityProject\Assets\Sprites
H:\MyUnityProject\Assets\Scripts
H:\MyUnityProject\Assets\StreamingAssets
H:\MyUnityProject\Assets\Fonts
H:\MyUnityProject\Assets\Materials
H:\MyUnityProject\Assets\Prefabs
H:\MyUnityProject\Assets\Scenes
H:\MyUnityProject\Assets\Shaders
H:\MyUnityProject\Assets\Editor
```

## 示例

如果项目根目录是：

```text
H:\MyUnityProject
```

则应确保存在：

```text
H:\MyUnityProject\Assets\Sprites
H:\MyUnityProject\Assets\Scripts
H:\MyUnityProject\Assets\StreamingAssets
H:\MyUnityProject\Assets\Fonts
H:\MyUnityProject\Assets\Materials
H:\MyUnityProject\Assets\Prefabs
H:\MyUnityProject\Assets\Scenes
H:\MyUnityProject\Assets\Shaders
H:\MyUnityProject\Assets\Editor
```