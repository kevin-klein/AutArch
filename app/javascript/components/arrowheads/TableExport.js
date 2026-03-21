// app/javascript/components/arrowheads/TableExport.js

import React, { useState } from 'react'

export default function TableExport ({ boxes, onDownload, onBack }) {
  const [targetPoints, setTargetPoints] = useState(200)

  if (!boxes || !Array.isArray(boxes)) {
    return null
  }

  const TARGET_WIDTH = 200
  const TARGET_HEIGHT = 200

  // Function to calculate the total length of the contour
  const calculateContourLength = (contour) => {
    let length = 0
    for (let i = 0; i < contour.length - 1; i++) {
      const [x1, y1] = contour[i]
      const [x2, y2] = contour[i + 1]
      length += Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
    }
    return length
  }

  // Function to resample the contour to exactly targetPoints
  const resampleContour = (contour) => {
    const totalLength = calculateContourLength(contour)
    const segmentLength = totalLength / (targetPoints - 1)
    const resampled = []
    let accumulatedLength = 0
    let currentIndex = 0

    resampled.push(contour[0])

    for (let i = 1; i < targetPoints - 1; i++) {
      const targetLength = i * segmentLength
      while (accumulatedLength < targetLength && currentIndex < contour.length - 1) {
        const [x1, y1] = contour[currentIndex]
        const [x2, y2] = contour[currentIndex + 1]
        const segmentDist = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
        if (accumulatedLength + segmentDist >= targetLength) {
          const ratio = (targetLength - accumulatedLength) / segmentDist
          const x = x1 + (x2 - x1) * ratio
          const y = y1 + (y2 - y1) * ratio
          resampled.push([x, y])
          accumulatedLength = targetLength
          break
        } else {
          accumulatedLength += segmentDist
          currentIndex++
        }
      }
    }

    resampled.push(contour[contour.length - 1])

    return resampled
  }

  const generateCSV = () => {
    const headerColumns = ['type']
    for (let i = 1; i <= targetPoints; i++) {
      headerColumns.push(`X${i}`, `Y${i}`)
    }
    const header = headerColumns.join(',')

    const rows = boxes.map((box) => {
      const { type, contour } = box

      if (!contour || contour.length === 0) {
        return `${type},,`
      }

      // 1. Resample contour to exactly targetPoints
      const resampledContour = resampleContour(contour)

      // 2. Calculate Bounding Box of the resampled contour
      let minX = Infinity
      let minY = Infinity
      let maxX = -Infinity
      let maxY = -Infinity
      resampledContour.forEach(([x, y]) => {
        if (x < minX) minX = x
        if (y < minY) minY = y
        if (x > maxX) maxX = x
        if (y > maxY) maxY = y
      })

      const width = maxX - minX
      const height = maxY - minY

      // 3. Transform resampled points to 200x200 grid (Scale)
      const scaled = resampledContour.map(([x, y]) => ({
        x: ((x - minX) * (TARGET_WIDTH / width)).toFixed(2),
        y: ((y - minY) * (TARGET_HEIGHT / height)).toFixed(2)
      }))

      // 4. Flatten X,Y coordinates into a single string
      const coordinates = scaled.map(({ x, y }) => `${x},${y}`).join(',')

      return `${type},${coordinates}`
    })

    return [header, ...rows].filter(row => row !== `${boxes[0]?.type},,`).join('\n')
  }

  const handleDownload = () => {
    const csvContent = generateCSV()
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.setAttribute('href', url)
    link.setAttribute('download', 'arrowheads_export.csv')
    link.style.visibility = 'hidden'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    URL.revokeObjectURL(url)
  }

  return (
    <div className='d-flex flex-column align-items-center gap-3 p-3 rounded shadow-sm'>
      {/* Header Section */}
      <div className='w-100 d-flex justify-content-between align-items-center mb-2'>
        <h3 className='m-0'>Export to CSV</h3>
        <button className='btn btn-info' onClick={onBack}>
          Back
        </button>
      </div>

      {/* Instructions Section */}
      <div className='alert alert-info mb-2' role="alert">
        <h5 className="alert-heading">How this section works:</h5>
        <ul className="mb-0">
          <li><strong>1. Export Format:</strong> Your shape data will be exported in CSV format with columns for class type, X and Y coordinates.</li>
          <li><strong>2. Resampling:</strong> Each contour will be resampled to exactly <strong>{targetPoints} points</strong> to ensure consistent data. Use a higher number for more detail, or a lower number for more generalized shapes.</li>
          <li><strong>3. Grid Normalization:</strong> The coordinates are normalized to a 200x200 grid for consistent input size.</li>
          <li><strong>4. Download:</strong> Review your export settings and click "Download CSV" to save the file to your computer.</li>
        </ul>
      </div>

      {/* Controls Section */}
      <div className='w-100 d-flex flex-wrap align-items-center gap-3'>
        {/* Input Group */}
        <div className='input-group' style={{ width: 'auto' }}>
          <span className='input-group-text' style={{ color: 'white' }}>Points:</span>
          <input
            type='number'
            className='form-control'
            value={targetPoints}
            onChange={(e) => setTargetPoints(Number(e.target.value))}
            min='2'
            style={{ width: '80px' }}
          />
        </div>

        {/* Download Button */}
        <button className='btn btn-primary' onClick={handleDownload}>
          Download CSV
        </button>

        {/* Info Text */}
        <span className='text-muted' style={{ fontSize: '12px', whiteSpace: 'nowrap' }}>
          Exports {boxes.length} shapes to {targetPoints} points
        </span>
      </div>
    </div>
  )
}
