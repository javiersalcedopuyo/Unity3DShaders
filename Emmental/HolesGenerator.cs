using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HolesGenerator : MonoBehaviour
{
  [SerializeField] GameObject m_target;
  [SerializeField] int m_minHolesCount = 0;
  [SerializeField] int m_maxHolesCount = 5;
  [SerializeField] float m_minHolesRadius = 0.01f;
  [SerializeField] float m_maxHolesRadius = 0.5f;

  Material m_targetMat;
  float[] m_centersArrayX, m_centersArrayY, m_radiusArray;

  // Start is called before the first frame update
  void Start()
  {
        m_targetMat = m_target.GetComponent<Renderer>().material;

        m_centersArrayX = new float[10];
        m_centersArrayY = new float[10];
        m_radiusArray = new float[10];

        Refresh();
  }

  // Update is called once per frame
  void Update() {
    if (Input.GetKeyUp(KeyCode.Space)) Refresh();
  }

  void Refresh()
  {
    // Clear the arrays
    for (int i=0; i<10; i++)
    {
      m_centersArrayX[i] = 0f;
      m_centersArrayY[i] = 0f;
      m_radiusArray[i]   = 0f;
    }

    // Assign random centers and radius
    int maxCount = Random.Range(m_minHolesCount, m_maxHolesCount);
    for (int i=0; i<maxCount; i++)
    {
      m_centersArrayX[i] = Random.Range(0f, 1f);
      m_centersArrayY[i] = Random.Range(0f, 1f);
      m_radiusArray[i]   = Random.Range(m_minHolesRadius, m_maxHolesRadius);
    }

    // Pass the uniforms to the shader
    m_targetMat.SetFloatArray("_CentersX", m_centersArrayX);
    m_targetMat.SetFloatArray("_CentersY", m_centersArrayX);
    m_targetMat.SetFloatArray("_RadiusArray", m_radiusArray);
  }
}
