import React, { useRef, useState, useMemo } from 'react'
import { Canvas, useLoader, useThree } from '@react-three/fiber'
import { PLYLoader } from 'three/addons/loaders/PLYLoader.js'
import { STLLoader } from 'three/addons/loaders/STLLoader.js'
import { OrbitControls, Bounds } from '@react-three/drei'
import { Mesh, Color } from 'three'
import * as THREE from 'three'

function Model ({ url }) {
  // 1. The loader returns GEOMETRY, not a Mesh
  const geometry = useLoader(
    url.endsWith('.stl') ? STLLoader : PLYLoader,
    url
  )

  useMemo(() => {
    if (geometry) {
      geometry.center()
      const size = new THREE.Vector3()
      geometry.computeBoundingBox()
      geometry.boundingBox.getSize(size)
      const maxDim = Math.max(size.x, size.y, size.z)
      const scale = 200 / maxDim
      geometry.scale(scale, scale, scale)
    }
  }, [geometry])

  return (
    <mesh geometry={geometry}>
      <meshStandardMaterial color="orange" />
    </mesh>
  )
}

function CameraControls () {
  const { camera, gl } = useThree()
  return (
    <OrbitControls
      // args={[camera, gl.domElement]}
      // enablePan
      // enableZoom
      // enableRotate
      // minPolarAngle={Math.PI / 4}
      // maxPolarAngle={Math.PI / 1.5}
    />
  )
}

function LoadingIndicator () {
  return (
    <mesh>
      <sphereGeometry args={[1, 32, 32]} />
      <meshStandardMaterial color='#4a90d9' />
    </mesh>
  )
}

function ErrorIndicator ({ message }) {
  return (
    <text
      x={0}
      y={0}
      fontSize={2}
      fill='#dc3545'
      textAlign='center'
      anchorX='middle'
      anchorY='middle'
    >
      {message}
    </text>
  )
}

function CameraHelper() {
  const { camera } = useThree()

  React.useEffect(() => {
    const logCamera = () => {
      const { x, y, z } = camera.position
      const { x: rx, y: ry, z: rz } = camera.rotation

      console.log('--- Camera Settings ---')
      console.log(`Position: [${x.toFixed(2)}, ${y.toFixed(2)}, ${z.toFixed(2)}]`)
      console.log(`Rotation: [${rx.toFixed(2)}, ${ry.toFixed(2)}, ${rz.toFixed(2)}]`)
      // If you are using OrbitControls, you also need the "target"
    }

    window.addEventListener('mousedown', logCamera)
    return () => window.removeEventListener('mousedown', logCamera)
  }, [camera])

  return null
}

export default function PLYViewer ({ modelUrl, width = 400, height = 400, label }) {
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

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
        }}
        camera={{ position: [6.06, -231.01, 177.95], rotation: [0.91, 0.02, -0.03], fov: 50 }}
      >
        <ambientLight intensity={0.6} />
        <pointLight position={[10, 10, 10]} intensity={1} castShadow />
        <directionalLight position={[-5, 10, 5]} intensity={0.8} castShadow />

        <Bounds fit clip observe margin={1.2}>
          <Model url={modelUrl} />
        </Bounds>

        {/* <CameraControls /> */}
        <OrbitControls />
        {/* <CameraHelper /> */}
      </Canvas>

      {/* Loading Overlay */}
      {/* {loading && (
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(255, 255, 255, 0.8)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 5
          }}
        >
          <div
            style={{
              width: '40px',
              height: '40px',
              border: '4px solid #4a90d9',
              borderTopColor: 'transparent',
              borderRadius: '50%',
              animation: 'spin 1s linear infinite'
            }}
          />
        </div>
      )} */}

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
