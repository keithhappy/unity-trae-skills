---
name: "unity-ui-transition-system"
description: "封装 Unity UI 页面截图转场系统，自动接入 ScreenTransitionPlayer、转场 Shader/材质与页面切换逻辑。用户提到 Unity 界面切换、转场特效、页面过渡时调用。"
---

# Unity UI 转场系统

这个 skill 用于在 Unity 项目中快速接入一套可复用的 UI 页面过渡系统，适用于展项、大屏、答题系统、图文查询系统等多页面切换场景。

它的目标不是简单解释做法，而是直接帮助完成以下工作：

- 创建或复用 `ScreenTransitionPlayer`
- 创建或复用 UI 转场 Shader 与材质
- 将转场系统挂到 `Canvas` 上
- 在现有页面切换逻辑中接入统一的过渡播放入口
- 尽量不破坏用户已经手工微调过的 UI 布局

## 何时使用

当用户出现以下意图时，应主动使用这个 skill：

- 提到 Unity 项目中的“界面切换过渡”“转场动画”“页面切换特效”
- 希望在多个界面之间加入截图转场、Shader 转场、溶解切换、墨迹扩散、马赛克切换等效果
- 已经有多个页面根节点，需要统一封装切页逻辑
- 希望把某个项目里的 UI 转场方案迁移到另一个 Unity 项目里复用

不适用场景：

- 只做单页内的按钮动画、缩放动画、DOTween 小动效
- 只做 Timeline、Animator 驱动的镜头转场，而不是 UI 页面切换

## 默认实现目标

默认采用以下结构：

1. 一个 `ScreenTransitionPlayer` 组件负责：
   - 截图当前屏幕
   - 把截图塞到全屏 `Image`
   - 给 `Image` 赋转场材质
   - 驱动材质 `_Progress` 从 `0` 到 `1`
   - 在转场中途切换真实页面内容

2. 一个全屏 `Image` 作为转场层：
   - 放在主 `Canvas` 最上层
   - 拉伸铺满整个画布
   - 平时隐藏，仅转场时显示

3. 一个默认材质：
   - 优先使用项目内已有的 UI 转场 Shader
   - 若项目中没有材质但有 Shader，则自动创建默认材质
   - 默认优先选择类似 `InkSpread` 这类观感稳定的效果

4. 一个统一页面切换封装：
   - 不在每个按钮里直接 `SetActive`
   - 统一改为 `SwitchPage(targetPage, setupAction)`
   - 在 `setupAction` 中刷新目标页面的数据
   - 再切换真实页面根节点显隐

## 工作原则

在接入时遵循以下优先级：

1. 优先保留用户现有界面和手工微调结果
2. 优先最小改动，不重建整套场景，除非用户明确要求
3. 优先接入现有控制器，而不是额外复制一份页面控制逻辑
4. 若用户已经有转场脚本、材质、Shader，优先复用而不是重写

## 推荐接入流程

### 1. 先检查现有项目资源

优先检查：

- 是否已有 `ScreenTransitionPlayer.cs`
- 是否已有可用的 UI 转场 Shader
- 是否已有 `Canvas`、`CanvasScaler`、页面根节点
- 是否已有统一页面控制器
- 是否已有手工微调过的场景

如果用户已经手工改过 UI，必须把这些改动视为新的基线，避免无故覆盖。

### 2. 创建或复用转场核心脚本

如果项目没有 `ScreenTransitionPlayer`，创建一个带以下能力的组件：

- `Image transitionImage`
- `Material defaultTransitionMaterial`
- `float duration`
- `string progressProperty = "_Progress"`
- 支持 `onScreenshotCaptured` 和 `onTransitionComplete`
- 支持：
  - `PlayDefaultTransition()`
  - `PlayDefaultTransition(Action onScreenshotCaptured, Action onTransitionComplete = null)`
  - `PlayTransition(Material overrideMat, Action onScreenshotCaptured, Action onTransitionComplete = null)`

组件核心行为：

- `WaitForEndOfFrame()`
- `ReadPixels` 截图
- 创建 `Sprite`
- 赋给转场 `Image`
- 实例化运行时材质
- 按时长推进 `_Progress`
- 完成后隐藏转场图层

### 3. 创建转场材质

优先顺序：

1. 复用已有 `.mat`
2. 若没有 `.mat` 但有合适的 Shader，则创建默认材质
3. 若连 Shader 都没有，再补 Shader

默认材质建议放在：

```text
Assets/Materials/
```

推荐命名：

```text
Assets/Materials/<ProjectName>DefaultTransition.mat
```

### 4. 接入 Canvas

在主 `Canvas` 或 UI 根节点上：

- 添加 `ScreenTransitionPlayer`
- 创建全屏 `Image` 作为 `transitionImage`
- 把默认材质拖给 `defaultTransitionMaterial`

转场层要求：

- 全屏拉伸
- 在层级上位于最顶层
- 默认 `SetActive(false)`
- `raycastTarget = false`

### 5. 接入页面切换逻辑

不要继续在多个地方散落写：

```csharp
pageA.SetActive(false);
pageB.SetActive(true);
```

改为统一封装：

```csharp
private void SwitchPage(PageState targetPage, Action setupAction)
{
    if (!CanPlayScreenTransition())
    {
        setupAction?.Invoke();
        SetPageState(targetPage);
        return;
    }

    screenTransitionPlayer.PlayDefaultTransition(
        () =>
        {
            setupAction?.Invoke();
            SetPageState(targetPage);
        },
        () =>
        {
            // 需要的话恢复交互状态
        });
}
```

适合接入的切换点：

- 待机页 -> 分类页
- 分类页 -> 内容页 / 答题页
- 答题页 -> 判定页
- 判定页 -> 下一题
- 判定页 -> 结算页
- 结算页 -> 分类页 / 首页

### 6. 保证已有 UI 不被破坏

如果用户已经微调过界面：

- 不要轻易重建场景
- 不要默认把所有坐标重新计算一遍
- 不要把手工改过的按钮或文本区域改回“程序默认值”

推荐做法：

- 优先修改脚本逻辑
- 只对必要组件补引用和补节点
- 如果确实要改场景，先说明原因，且只做局部更新

## 分辨率与布局适配建议

如果项目明确要求固定设计分辨率，例如 `1920x1080`：

- 统一使用 `CanvasScaler.ScaleWithScreenSize`
- `referenceResolution` 与设计稿保持一致
- 让场景生成脚本和 UI 位置参数都基于这个分辨率
- 不要混用多个设计基准

如果需要把旧工程从 `1024x576` 升级到 `1920x1080`：

- 先确认当前所有布局参数是否基于旧分辨率
- 再统一缩放尺寸、坐标和字号
- 升级后优先做运行态截图核对

## 推荐验证清单

接入后至少验证：

- 转场开始时能正常截图，不是黑屏
- 材质 `_Progress` 能正常变化
- 页面在转场中途切换，而不是提前切换
- 切换完成后转场层隐藏
- 连续快速点击不会把转场状态打乱
- 无操作返回待机、结算返回分类等边界流程仍然正确
- 不会覆盖用户已经手调过的 UI

## 处理策略

当用户要求“在另一个项目里复用这套转场系统”时，按这个顺序处理：

1. 查现有转场脚本、Shader、材质、控制器
2. 决定是“复用现有资源”还是“补齐缺失资源”
3. 创建或挂接 `ScreenTransitionPlayer`
4. 创建转场层 `Image`
5. 将页面切换逻辑统一封装到 `SwitchPage`
6. 验证页面切换与交互逻辑
7. 尽量不碰用户已微调布局

## 输出要求

完成接入后，说明结果时应明确写出：

- 用了哪个脚本或新建了哪些脚本
- 默认材质或 Shader 放在哪里
- 哪些页面切换已接入转场
- 是否保留了用户现有 UI 微调
- 是否验证过编译和运行逻辑

## 关键词

Unity 转场, UI 页面切换, ScreenTransitionPlayer, Shader 转场, 截图过渡, 界面过渡效果, 页面切换动画, 展项转场, 结算页切换, 答题页切换