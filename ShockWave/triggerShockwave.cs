using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class triggerShockwave : MonoBehaviour {

	public Vector3 center;
	public float waveSpeed, waveWidth, waveHeight, startTime;

	private Shader stillShader;
	private Shader shockwaveShader;
	private Renderer terrainRenderer;
	private SphereCollider fakeWave;
	private bool shock = false;

	// Use this for initialization
	void Start () {
		
		terrainRenderer = GetComponent<Renderer>();
		stillShader = Shader.Find("Standard");
		//shockwaveShader = Shader.Find("Custom/shockWaveShader");
		shockwaveShader = Shader.Find("Custom/shockwave");

		terrainRenderer.material.shader = stillShader;

		// Since the shader doesn't change the geometry of the mesh, to make the objects react to the change, a growing sphere trigger collider is used
		fakeWave = GetComponent<SphereCollider>();
		fakeWave.isTrigger = true;
	}
	
	private void setShockwave(float h, float s, float w, Vector3 c) {

		terrainRenderer.material.shader = shockwaveShader;

		terrainRenderer.material.SetFloat("_WaveSize", h);
		terrainRenderer.material.SetFloat("_WaveSpeed", s);
		terrainRenderer.material.SetFloat("_WaveWidth", 1/w);
		terrainRenderer.material.SetVector("_StartPoint", c);
		fakeWave.center = c;

		terrainRenderer.material.SetVector("_StartTime", new Vector4(Time.time/20, Time.time, Time.time*2, Time.time*3));
	}

	public void startShockwave() {

		// Sphere collider shockwave
		startTime = Time.time;
		fakeWave.radius = 0.001f;
		fakeWave.center = center;
		shock = true;

		setShockwave(waveHeight, waveSpeed, waveWidth, center);
		StartCoroutine("waitForNow");
	}

	// Update is called once per frame
	void Update () {
		
		// Sphere collider shockwave
		if (shock) {
			fakeWave.radius += (Time.time - startTime) * 3 * waveSpeed;
		} else {
			fakeWave.radius = 0.0001f;
		}
	}

	IEnumerator waitForNow(){

		yield return new WaitForSeconds(3.0f);
		shock = false;
		terrainRenderer.material.shader = stillShader;
	}
}