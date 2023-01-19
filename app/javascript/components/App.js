import '../css/application.scss';

import * as React from 'react';
import Skeletons from './Skeletons';
import SkeletonEditor from './SkeletonEditor';
import { Route, Router } from 'wouter';
import { useLocationProperty, navigate } from 'wouter/use-location';

import { GraphQLClient, ClientContext } from 'graphql-hooks';

const client = new GraphQLClient({
  url: '/graphql'
});


const hashLocation = () => window.location.hash.replace(/^#/, '') || '/';

const hashNavigate = (to) => navigate('#' + to);

const useHashLocation = () => {
  const location = useLocationProperty(hashLocation);
  return [location, hashNavigate];
};

function DashboardContent() {
  const [open, setOpen] = React.useState(true);
  const toggleDrawer = () => {
    setOpen(!open);
  };

  return (
    <div className='container'>
      <div className='row'>
        {/* Recent Orders */}
        <div className='col-md-12' >
          <Router hook={useHashLocation}>
            <Route path='/'>
              <Skeletons />
            </Route>
            <Route path='/skeletons/:id'>
              {(params) => <SkeletonEditor id={params.id} />}
            </Route>
          </Router>
        </div>
      </div>
    </div>
  );
}

export default function App () {
  return (
    <React.StrictMode>
      <ClientContext.Provider value={client}>
        <DashboardContent />
      </ClientContext.Provider>
    </React.StrictMode>
  );
}
