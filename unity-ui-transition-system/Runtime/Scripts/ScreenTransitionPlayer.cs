using System.Collections;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class ScreenTransitionPlayer : MonoBehaviour
{
    [SerializeField] private Image transitionImage;
    [SerializeField] private Material defaultTransitionMaterial;
    [SerializeField] private float duration = 0.6f;
    [SerializeField] private string progressProperty = "_Progress";
    [SerializeField] private bool useUnscaledTime = true;
    [SerializeField] private bool hideImageOnComplete = true;
    [SerializeField] private UnityEvent onScreenshotCaptured;
    [SerializeField] private UnityEvent onTransitionComplete;

    private Coroutine playRoutine;
    private Texture2D capturedTexture;
    private Sprite capturedSprite;
    private Material runtimeMaterial;
    private System.Action screenshotCapturedCallback;
    private System.Action transitionCompleteCallback;

    public void PlayDefaultTransition()
    {
        PlayTransition(defaultTransitionMaterial);
    }

    public void PlayDefaultTransition(System.Action onScreenshotCapturedCallback, System.Action onTransitionCompleteCallback = null)
    {
        PlayTransition(defaultTransitionMaterial, onScreenshotCapturedCallback, onTransitionCompleteCallback);
    }

    public void PlayTransition(Material transitionMaterialOverride)
    {
        PlayTransition(transitionMaterialOverride, null, null);
    }

    public void PlayTransition(Material transitionMaterialOverride, System.Action onScreenshotCapturedCallback, System.Action onTransitionCompleteCallback = null)
    {
        if (playRoutine != null)
        {
            StopCoroutine(playRoutine);
        }

        screenshotCapturedCallback = onScreenshotCapturedCallback;
        transitionCompleteCallback = onTransitionCompleteCallback;
        playRoutine = StartCoroutine(PlayTransitionRoutine(transitionMaterialOverride));
    }

    public void StopTransition()
    {
        if (playRoutine != null)
        {
            StopCoroutine(playRoutine);
            playRoutine = null;
        }

        HideTransitionImage();
    }

    private IEnumerator PlayTransitionRoutine(Material transitionMaterialOverride)
    {
        if (transitionImage == null)
        {
            yield break;
        }

        yield return new WaitForEndOfFrame();

        CaptureScreenToImage();
        PrepareTransitionImage(transitionMaterialOverride);
        onScreenshotCaptured?.Invoke();
        screenshotCapturedCallback?.Invoke();

        float transitionDuration = Mathf.Max(0.01f, duration);
        float elapsed = 0f;
        SetMaterialProgress(0f);
        while (elapsed < transitionDuration)
        {
            elapsed += GetDeltaTime();
            SetMaterialProgress(Mathf.Clamp01(elapsed / transitionDuration));
            yield return null;
        }

        SetMaterialProgress(1f);
        onTransitionComplete?.Invoke();
        transitionCompleteCallback?.Invoke();

        if (hideImageOnComplete)
        {
            HideTransitionImage();
        }

        playRoutine = null;
        screenshotCapturedCallback = null;
        transitionCompleteCallback = null;
    }

    private void CaptureScreenToImage()
    {
        CleanupCapturedResources();

        int width = Mathf.Max(1, Screen.width);
        int height = Mathf.Max(1, Screen.height);
        capturedTexture = new Texture2D(width, height, TextureFormat.RGBA32, false);
        capturedTexture.ReadPixels(new Rect(0f, 0f, width, height), 0, 0, false);
        capturedTexture.Apply(false, false);

        capturedSprite = Sprite.Create(capturedTexture, new Rect(0f, 0f, width, height), new Vector2(0.5f, 0.5f));
        transitionImage.sprite = capturedSprite;
        transitionImage.preserveAspect = true;
    }

    private void PrepareTransitionImage(Material transitionMaterialOverride)
    {
        if (transitionImage == null)
        {
            return;
        }

        CleanupRuntimeMaterial();

        Material sourceMaterial = transitionMaterialOverride != null ? transitionMaterialOverride : defaultTransitionMaterial;
        if (sourceMaterial != null)
        {
            runtimeMaterial = new Material(sourceMaterial);
            transitionImage.material = runtimeMaterial;
        }
        else
        {
            transitionImage.material = null;
        }

        transitionImage.color = Color.white;
        transitionImage.gameObject.SetActive(true);
        transitionImage.enabled = true;
    }

    private void SetMaterialProgress(float progress)
    {
        if (runtimeMaterial == null || string.IsNullOrEmpty(progressProperty))
        {
            return;
        }

        if (!runtimeMaterial.HasProperty(progressProperty))
        {
            return;
        }

        runtimeMaterial.SetFloat(progressProperty, Mathf.Clamp01(progress));
    }

    private void HideTransitionImage()
    {
        if (transitionImage != null)
        {
            transitionImage.enabled = false;
            transitionImage.gameObject.SetActive(false);
        }
    }

    private float GetDeltaTime()
    {
        return useUnscaledTime ? Time.unscaledDeltaTime : Time.deltaTime;
    }

    private void CleanupRuntimeMaterial()
    {
        if (runtimeMaterial != null)
        {
            Destroy(runtimeMaterial);
            runtimeMaterial = null;
        }
    }

    private void CleanupCapturedResources()
    {
        if (capturedSprite != null)
        {
            Destroy(capturedSprite);
            capturedSprite = null;
        }

        if (capturedTexture != null)
        {
            Destroy(capturedTexture);
            capturedTexture = null;
        }
    }

    private void OnDestroy()
    {
        CleanupRuntimeMaterial();
        CleanupCapturedResources();
    }
}