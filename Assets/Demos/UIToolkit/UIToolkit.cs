using UnityEngine;
using UnityEngine.UIElements;

public class UIToolkit : MonoBehaviour
{
    AudioSource m_AudioSource;
    UIDocument m_UIDocument;
    void Start()
    {
        m_AudioSource = GetComponent<AudioSource>();
        m_UIDocument = GetComponent<UIDocument>();

        var root = m_UIDocument.rootVisualElement;

        var startBtn = root.Q<Button>("StartGame");
        startBtn.RegisterCallback<ClickEvent>(OnStartBtnClicked);

        var allBtns = root.Query<Button>().ToList();
        foreach (var btn in allBtns)
        {
            btn.RegisterCallback<ClickEvent>(PlayAudio);
        }
    }

    void PlayAudio(ClickEvent evt)
    {
        m_AudioSource.Play();
    }

    void OnStartBtnClicked(ClickEvent evt)
    {
        Debug.Log("<color=green>Game Start!</color>");
    }
}
