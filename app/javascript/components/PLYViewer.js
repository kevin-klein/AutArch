import { useRef, useState } from 'react'
import { Canvas, useLoader, useThree } from '@react-three/fiber'
import { OrbitControls, PLYLoader } from 'three-stdlib'
import { Mesh } from 'three'

function Model ({ url }) {
  const mesh = useLoader(PLYLoader, url)
  return <primitive object={mesh} />
}

function CameraControls () {
  const { camera, gl } = useThree()
  return <OrbitControls args={[camera, gl.domElement]} />
}

export default function PLYViewer ({ modelUrl }) {
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  return (
    <div style={{ width: '100%', height: '100vh' }}>
      <Canvas
        onCreated={({ gl }) => {
          gl.setClearColor('#f0f0f0')
        }}
      >
        <ambientLight intensity={0.5} />
        <pointLight position={[10, 10, 10]} />
        <Model url={modelUrl} />
        <CameraControls />
      </Canvas>
    </div>
  )
}
