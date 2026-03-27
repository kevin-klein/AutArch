import React from 'react'

export default function SharedButton ({ children, onClick, disabled, variant = 'primary', className = '', style = {} }) {
  const baseStyles = {
    width: '100%',
    margin: '15px 0 0 0',
    padding: '12px 24px',
    fontSize: '1rem',
    fontWeight: '500',
    background: disabled
      ? 'linear-gradient(135deg, #6b7280 0%, #4b5563 100%)'
      : variant === 'primary'
        ? 'linear-gradient(135deg, #4caf50 0%, #45a049 100%)'
        : 'linear-gradient(135deg, #6b7280 0%, #4b5563 100%)',
    color: 'white',
    border: 'none',
    borderRadius: '8px',
    cursor: disabled ? 'not-allowed' : 'pointer',
    boxShadow: disabled ? 'none' : '0 2px 6px rgba(0, 0, 0, 0.2)',
    transition: 'all 0.3s ease',
    opacity: disabled ? 0.6 : 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    ...style
  }

  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={className}
      style={baseStyles}
      onMouseEnter={(e) => {
        if (!disabled) {
          e.target.style.background = variant === 'primary'
            ? 'linear-gradient(135deg, #45a049 0%, #3d8b40 100%)'
            : 'linear-gradient(135deg, #4b5563 0%, #374151 100%)'
          e.target.style.transform = 'translateY(-2px)'
          e.target.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.3)'
        }
      }}
      onMouseLeave={(e) => {
        if (!disabled) {
          e.target.style.background = variant === 'primary'
            ? 'linear-gradient(135deg, #4caf50 0%, #45a049 100%)'
            : 'linear-gradient(135deg, #6b7280 0%, #4b5563 100%)'
          e.target.style.transform = 'translateY(0)'
          e.target.style.boxShadow = '0 2px 6px rgba(0, 0, 0, 0.2)'
        }
      }}
      onMouseDown={(e) => {
        if (!disabled) {
          e.target.style.transform = 'translateY(0)'
        }
      }}
      onMouseUp={(e) => {
        if (!disabled) {
          e.target.style.background = variant === 'primary'
            ? 'linear-gradient(135deg, #45a049 0%, #3d8b40 100%)'
            : 'linear-gradient(135deg, #4b5563 0%, #374151 100%)'
          e.target.style.transform = 'translateY(-2px)'
          e.target.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.3)'
        }
      }}
    >
      {children}
    </button>
  )
}
