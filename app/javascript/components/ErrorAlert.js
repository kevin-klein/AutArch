export default function ErrorAlert(error) {
  if(error.fetchError) {
    alert(error.fetchError.message);
  }
  else if(error.graphQLErrors) {
    alert(error.graphQLErrors.map(err => `${err.path}: ${err.message}`).join('\n'));
  }
  else if(error.httpError) {
    alert(`HTTP Error: ${error.httpError.status} ${error.httpError.statusText}`);
  }
  else {
    alert('unkown error');
  }
}
