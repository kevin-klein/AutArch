import React, { useRef, useState, useMemo, useEffect } from 'react'
import { Canvas, useLoader, useThree, useFrame } from '@react-three/fiber'
import { PLYLoader } from 'three/addons/loaders/PLYLoader.js'
import { STLLoader } from 'three/addons/loaders/STLLoader.js'
import { OrbitControls, Bounds, Html } from '@react-three/drei'
import * as THREE from 'three'
import { t } from '../utils/i18n'

function Model ({ url }) {
  const geometry = useLoader(
    url.endsWith('.stl') ? STLLoader : PLYLoader,
    url
  )

  useMemo(() => {
    if (geometry) {
      geometry.center()
      geometry.computeVertexNormals()

      const size = new THREE.Vector3()
      geometry.computeBoundingBox()
      geometry.boundingBox.getSize(size)
      const maxDim = Math.max(size.x, size.y, size.z)
      const scale = 200 / maxDim
      geometry.scale(scale, scale, scale)
    }
  }, [geometry])

  return (
    <mesh geometry={geometry} castShadow receiveShadow>
      <meshStandardMaterial
        color='#a5845b'
        metalness={0.3}
        roughness={0.7}
        flatShading={false}
      />
    </mesh>
  )
}

function AutoRotateControl ({ autoRotate }) {
  const ref = useRef()
  useFrame(() => {
    if (autoRotate && ref.current) {
      ref.current.rotation.y += 0.005
    }
  })
  return <primitive ref={ref} object={new THREE.Object3D()} />
}

export default function PLYViewer ({ modelUrl, width = 400, height = 400, label }) {
  const [autoRotate, setAutoRotate] = useState(false)
  const cameraRef = useRef()

  const extensions = useMemo(() => ['.ply', '.stl'], [])
  const isSupportedFormat = useMemo(() => {
    if (!modelUrl) return false
    return extensions.some(ext => modelUrl.toLowerCase().endsWith(ext))
  }, [modelUrl, extensions])

  const handleReset = () => {
    console.log('Reset')
    if (cameraRef.current) {
      cameraRef.current.reset()
    }
    setAutoRotate(false)
  }

  if (!modelUrl) {
    return (
      <div
        style={{
          width: `${width}px`,
          height: `${height}px`,
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          borderRadius: '12px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: 'white',
          textAlign: 'center',
          padding: '20px'
        }}
      >
        <div>
          <div style={{ fontSize: '48px', marginBottom: '10px' }}>🏺</div>
          <div>No 3D Model Available</div>
          <div style={{ fontSize: '14px', opacity: 0.8, marginTop: '10px' }}>
            Upload a PLY or STL model to view
          </div>
        </div>
      </div>
    )
  }

  if (!isSupportedFormat) {
    return (
      <div
        style={{
          width: `${width}px`,
          height: `${height}px`,
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          borderRadius: '12px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: 'white',
          textAlign: 'center',
          padding: '20px'
        }}
      >
        <div>
          <div style={{ fontSize: '48px', marginBottom: '10px' }}>⚠️</div>
          <div>Unsupported Format</div>
          <div style={{ fontSize: '14px', opacity: 0.8, marginTop: '10px' }}>
            Please upload a PLY or STL file
          </div>
        </div>
      </div>
    )
  }

  return (
    <div style={{ width: `${width}px`, height: `${height}px` }}>
      {/* 3D Canvas */}
      <Canvas
        style={{
          width: `${width}px`,
          height: `${height}px`,
          borderRadius: '12px',
          overflow: 'hidden'
        }}
        onCreated={({ gl }) => {
          gl.setClearColor('#f5f5f5')
          gl.shadowMap.enabled = true
          gl.shadowMap.type = 'PCSoftShadowMap'
          gl.shadowMap.autoUpdate = true
        }}
        camera={{ position: [0, 0, 500], fov: 50, near: 1, far: 10000 }}
      >
        <ambientLight intensity={0.5} />
        <directionalLight
          position={[100, 100, 100]}
          intensity={1.5}
          castShadow
          shadow-mapSize={[1024, 1024]}
        />
        <directionalLight
          position={[-100, -50, 50]}
          intensity={0.8}
          color='#ffffff'
        />
        <directionalLight
          position={[0, -100, -50]}
          intensity={0.4}
          color='#ffeedd'
        />

        <Bounds fit clip observe margin={1.2}>
          <Model url={modelUrl} />
        </Bounds>

        <AutoRotateControl autoRotate={autoRotate} />

        <OrbitControls
          enablePan
          enableZoom
          enableRotate
          rotateSpeed={0.5}
          zoomSpeed={0.8}
          panSpeed={0.7}
          autoRotate={autoRotate}
          autoRotateSpeed={2.0}
          minDistance={50}
          maxDistance={800}
          enableDamping
          dampingFactor={0.05}
          ref={cameraRef}
        />
      </Canvas>
    </div>
  )
}
