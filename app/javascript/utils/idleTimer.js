/**
 * Idle Timer Utility
 * Auto-resets wizard to beginning after specified idle time
 */

export function createIdleTimer(onIdle, timeout = 60000) {
  let timeoutId = null
  let idleTimer = null

  const resetTimer = () => {
    clearTimeout(timeoutId)
    if (idleTimer) {
      clearTimeout(idleTimer)
    }
    timeoutId = setTimeout(onIdle, timeout)
  }

  const resetTimers = () => {
    resetTimer()
    // Reset timer on any user activity
    document.addEventListener('mousemove', resetTimer, { passive: true })
    document.addEventListener('keydown', resetTimer, { passive: true })
    document.addEventListener('scroll', resetTimer, { passive: true })
    document.addEventListener('click', resetTimer, { passive: true })
  }

  const stopTimers = () => {
    clearTimeout(timeoutId)
    if (idleTimer) {
      clearTimeout(idleTimer)
    }
    document.removeEventListener('mousemove', resetTimer)
    document.removeEventListener('keydown', resetTimer)
    document.removeEventListener('scroll', resetTimer)
    document.removeEventListener('click', resetTimer)
  }

  // Start timers
  resetTimers()

  return {
    resetTimers,
    stop
  }
}
