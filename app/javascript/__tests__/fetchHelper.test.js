/**
 * Tests for fetchHelper.js
 */

import safeCredentials, { getAuthenticityToken, authenticityHeader, getMetaContent } from '../fetchHelper'

describe('getMetaContent', () => {
  beforeEach(() => {
    document.head.innerHTML = ''
  })

  it('returns meta content when exists', () => {
    const meta = document.createElement('meta')
    meta.name = 'csrf-token'
    meta.content = 'test-token-123'
    document.head.appendChild(meta)

    expect(getMetaContent('csrf-token')).toBe('test-token-123')
  })

  it('returns null when meta tag does not exist', () => {
    expect(getMetaContent('nonexistent')).toBeNull()
  })
})

describe('getAuthenticityToken', () => {
  beforeEach(() => {
    document.head.innerHTML = ''
  })

  it('returns auth token from meta tag', () => {
    const meta = document.createElement('meta')
    meta.name = 'csrf-token'
    meta.content = 'secret-token'
    document.head.appendChild(meta)

    expect(getAuthenticityToken()).toBe('secret-token')
  })
})

describe('authenticityHeader', () => {
  it('returns default headers with auth token', () => {
    const result = authenticityHeader()
    expect(result).toMatchObject({
      'X-CSRF-Token': 'test-token',
      'X-Requested-With': 'XMLHttpRequest'
    })
  })

  it('merges with existing options', () => {
    const result = authenticityHeader({ 'Custom-Header': 'value' })
    expect(result).toMatchObject({
      'Custom-Header': 'value',
      'X-CSRF-Token': 'test-token',
      'X-Requested-With': 'XMLHttpRequest'
    })
  })
})

describe('jsonHeader', () => {
  it('adds JSON headers to options', () => {
    const result = safeCredentials({ method: 'POST' })
    expect(result.headers).toMatchObject({
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    })
  })

  it('merges existing headers with JSON headers', () => {
    const result = safeCredentials({
      headers: { 'Custom-Header': 'value' }
    })
    expect(result.headers).toMatchObject({
      'Custom-Header': 'value',
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    })
  })
})

describe('safeCredentials', () => {
  it('adds credentials and mode to options', () => {
    const result = safeCredentials({ method: 'POST' })
    expect(result).toMatchObject({
      credentials: 'include',
      mode: 'same-origin'
    })
  })

  it('combines all headers', () => {
    const result = safeCredentials({
      headers: { 'Custom': 'value' }
    })
    expect(result.headers).toMatchObject({
      'Custom': 'value',
      'X-CSRF-Token': 'test-token',
      'X-Requested-With': 'XMLHttpRequest',
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    })
  })
})
