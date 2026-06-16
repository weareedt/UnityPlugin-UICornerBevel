using UnityEngine;
using UnityEngine.UI;

namespace EDT.UI
{
    /// <summary>
    /// Rounds the corners of a UI <see cref="Graphic"/> (Image / RawImage) with an
    /// SDF shader — no extra GameObjects or RenderTextures. Add via
    /// <b>Add Component → UI/Effects/UI Corner Bevel</b>.
    /// </summary>
    [ExecuteAlways]
    [AddComponentMenu("UI/Effects/UI Corner Bevel")]
    [RequireComponent(typeof(Graphic))]
    public class UICornerBevel : MonoBehaviour
    {
        [SerializeField, Min(0f)] private float _cornerRadius = 20f;
        [SerializeField, Min(0.1f)] private float _edgeSoftness = 1.5f;

        public float CornerRadius => _cornerRadius;
        public float EdgeSoftness => _edgeSoftness;

        [System.NonSerialized] private Graphic  _graphic;
        [System.NonSerialized] private Material _mat;

        static readonly int ID_CornerRadius = Shader.PropertyToID("_CornerRadius");
        static readonly int ID_Size         = Shader.PropertyToID("_Size");
        static readonly int ID_CropRect     = Shader.PropertyToID("_CropRect");
        static readonly int ID_EdgeSoftness = Shader.PropertyToID("_EdgeSoftness");

        // Optional integration: if a companion shadow/glow component (e.g. UISoftShadowRT)
        // is present on this GameObject, ask it to rebuild. SendMessage keeps this package
        // free of any hard compile dependency on that component — it harmlessly no-ops when
        // no receiver exists.
        void NotifySoftShadow()
        {
            SendMessage("RequestRebuild", SendMessageOptions.DontRequireReceiver);
        }

        void OnEnable()
        {
            _graphic = GetComponent<Graphic>();
            var shader = Shader.Find("UI/CornerBevel");
            if (shader == null)
            {
                Debug.LogError("[UICornerBevel] UI/CornerBevel shader not found. " +
                               "Add it to Project Settings → Graphics → Always Included Shaders for WebGL builds.");
                enabled = false;
                return;
            }
            _mat = new Material(shader) { hideFlags = HideFlags.HideAndDontSave };
            _graphic.material = _mat;
            ApplyProperties();
            NotifySoftShadow();
        }

        void OnDisable()
        {
            if (_graphic) _graphic.material = null;
            if (_mat) DestroyImmediate(_mat);
            _mat = null;
        }

        void OnDestroy() => OnDisable();

#if UNITY_EDITOR
        void OnValidate()
        {
            if (!isActiveAndEnabled || _mat == null) return;
            UnityEditor.EditorApplication.delayCall += () =>
            {
                if (this && isActiveAndEnabled && _mat != null)
                {
                    ApplyProperties();
                    NotifySoftShadow();
                }
            };
        }
#endif

        void OnRectTransformDimensionsChange()
        {
            if (isActiveAndEnabled && _mat != null)
                ApplyProperties();
        }

        void ApplyProperties()
        {
            var rt = (RectTransform)transform;
            float w = Mathf.Abs(rt.rect.width);
            float h = Mathf.Abs(rt.rect.height);

            // Compute the crop rect — normalised atlas slice for Image, full (0,0,1,1) for RawImage.
            var cropRect = new Vector4(0f, 0f, 1f, 1f);
            if (_graphic is Image img && img.sprite != null)
            {
                var tex  = img.sprite.texture;
                var rect = img.sprite.textureRect;
                cropRect = new Vector4(
                    rect.x      / tex.width,
                    rect.y      / tex.height,
                    rect.width  / tex.width,
                    rect.height / tex.height);
            }

            _mat.SetFloat(ID_CornerRadius, _cornerRadius);
            _mat.SetFloat(ID_EdgeSoftness, _edgeSoftness);
            _mat.SetVector(ID_Size,        new Vector4(w, h, 0f, 0f));
            _mat.SetVector(ID_CropRect,    cropRect);
        }
    }
}
