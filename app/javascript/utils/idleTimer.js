import { useEffect, useRef } from 'react'

const useIdle = (callback, timeout = 3000) => {
  const timeoutRef = useRef(null)

  useEffect(() => {
    const handleEvent = () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current)
      }

      timeoutRef.current = setTimeout(() => {
        callback()
      }, timeout)
    }

    handleEvent()

    window.addEventListener('mousemove', handleEvent)

    return () => {
      window.removeEventListener('mousemove', handleEvent)
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current)
      }
    }
  }, [callback, timeout])
}

export default useIdle

/**
 * Reload page utility
 */
export function reloadPage () {
  window.location.reload()
}
