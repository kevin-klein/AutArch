// https://gist.github.com/fletcher91/c62b865c6aa9f710531e
/**
 *
 * A regular non-safe get request:
 * fetch('/profiles/foobar.json', jsonHeader());
 *
 * How this would look in a safe fetch request:
 * fetch('/profiles.json', safeCredentials({
 *              method: 'POST',
 *              body: JSON.stringify({
 *                  q: input,
 *                  thing: this.props.thing
 *              })
 *          }));
 *
 *
 */

/**
 * For use with window.fetch
 * @param {Object} options Object to be merged with jsonHeader options.
 * @returns {Object} The merged object.
 */
function jsonHeader (options) {
  options = options || {};
  return Object.assign(options, {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  });
}

/**
 * Lets fetch include credentials in the request. This includes cookies and other possibly sensitive data.
 * Note: Never use for requests across (untrusted) domains.
 * @param {Object} options Object to be merged with safeCredentials options.
 * @returns {Object} The merged object.
 */
export default function safeCredentials (options) {
  options = options || {};
  return Object.assign(options, {
    credentials: 'include',
    mode: 'same-origin',
    headers: Object.assign((options['headers'] || {}), authenticityHeader(), jsonHeader())
  });
}

// Additional helper methods

function authenticityHeader (options) {
  options = options || {};
  return Object.assign(options, {
    'X-CSRF-Token': getAuthenticityToken(),
    'X-Requested-With': 'XMLHttpRequest'
  });
}

function getAuthenticityToken () {
  return getMetaContent('csrf-token');
}

function getMetaContent (name) {
  const header = document.querySelector(`meta[name="${name}"]`);
  return header && header.content;
}
