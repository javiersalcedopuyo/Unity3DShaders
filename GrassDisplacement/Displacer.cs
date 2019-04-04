using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Displacer : MonoBehaviour
{
    [SerializeField] Material m_mat;
    [SerializeField] float m_radius = 0.5f;

    void Start() {}

    void Update()
    {
      m_mat.SetVector("_ObjPos", transform.position);
      m_mat.SetFloat ("_ObjRad", m_radius);
    }
}
