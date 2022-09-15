import logo from './logo.svg';
import './App.css';
import React from 'react';

function Publication({publication}) {
  return (
    <div>
      {publication.title}
    </div>
  )
}

function App() {
  const [publications, setPublications] = React.useState([]);

  React.useEffect(() => {
    fetch('/publications').then(res => res.json()).then(data => {
      setPublications(data.publications);
    });
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        {publications.map((p) => <Publication publication={p} key={p.id} />)}
      </header>
    </div>
  );
}

export default App;
