import React from 'react'
import { setLanguage, getLanguage, getLanguages, t } from '../utils/i18n'

export default function LanguageSelection ({ onLanguageSelect }) {
  const languages = getLanguages()

  const handleLanguageSelect = (langCode) => {
    setLanguage(langCode)
    onLanguageSelect(langCode)
  }

  return (
    <div className='language-selection-screen' style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      padding: '20px',
      color: 'white'
    }}>
      <style>{`
        .language-selection-screen {
          animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }

        .language-title {
          font-size: 48px;
          font-weight: 800;
          margin-bottom: 20px;
          text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
          text-align: center;
        }

        .language-subtitle {
          font-size: 20px;
          margin-bottom: 60px;
          opacity: 0.95;
          text-align: center;
        }

        .language-buttons {
          display: flex;
          gap: 40px;
          flex-wrap: wrap;
          justify-content: center;
        }

        .language-button {
          background: white;
          border: none;
          border-radius: 20px;
          padding: 40px 60px;
          min-width: 280px;
          cursor: pointer;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 15px;
        }

        .language-button:hover {
          transform: translateY(-10px) scale(1.05);
          box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }

        .language-button:active {
          transform: translateY(-5px) scale(1.02);
        }

        .language-flag {
          font-size: 80px;
        }

        .language-name {
          font-size: 28px;
          font-weight: 700;
          color: #1f2937;
        }
      `}</style>

      <div className='language-title'>{t('selectLanguage')}</div>
      <div className='language-subtitle'>{t('languageInstructions')}</div>

      <div className='language-buttons'>
        {languages.map((lang) => (
          <button
            key={lang.code}
            className='language-button'
            onClick={() => handleLanguageSelect(lang.code)}
          >
            <div className='language-flag'>{lang.flag}</div>
            <div className='language-name'>{lang.name}</div>
          </button>
        ))}
      </div>
    </div>
  )
}
