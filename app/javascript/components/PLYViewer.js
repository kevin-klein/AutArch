import React, { useRef, useState, useMemo } from 'react'
import { Canvas, useLoader, useThree } from '@react-three/fiber'
import { PLYLoader } from 'three/addons/loaders/PLYLoader.js'
import { STLLoader } from 'three/addons/loaders/STLLoader.js'
import { OrbitControls, Bounds } from '@react-three/drei'
import * as THREE from 'three'

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

export default function PLYViewer ({ modelUrl, width = 400, height = 400, label }) {
  const extensions = useMemo(() => ['.ply', '.stl'], [])
  const isSupportedFormat = useMemo(() => {
    if (!modelUrl) return false
    return extensions.some(ext => modelUrl.toLowerCase().endsWith(ext))
  }, [modelUrl, extensions])

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
    <div
      style={{
        width: `${width}px`,
        height: `${height}px`,
        borderRadius: '12px',
        overflow: 'hidden',
        position: 'relative'
      }}
    >
      {/* Label */}
      {label && (
        <div
          style={{
            position: 'absolute',
            top: '10px',
            left: '10px',
            backgroundColor: 'rgba(0, 0, 0, 0.6)',
            color: 'white',
            padding: '8px 12px',
            borderRadius: '6px',
            fontSize: '14px',
            fontWeight: 'bold',
            zIndex: 10
          }}
        >
          {label}
        </div>
      )}

      {/* 3D Canvas */}
      <Canvas
        onCreated={({ gl }) => {
          gl.setClearColor('#f5f5f5')
          gl.shadowMap.enabled = true
          gl.shadowMap.type = 'PCSoftShadowMap'
          gl.shadowMap.autoUpdate = true
        }}
        camera={{ position: [0, 0, 300], fov: 50 }}
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

        <OrbitControls />
      </Canvas>

      <style>{`
        @keyframes spin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
      `}
      </style>
    </div>
  )
}
