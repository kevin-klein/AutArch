import React from 'react';
import SiteSearchField from './SiteSearchField';
import Collapse from './Collapse';
import {useQuery} from 'graphql-hooks';

const SITE_QUERY = `
  query($search: String) {
    sites(search: $search) {
      id
      lat
      lon
      name
      locality
      siteCode
      countryCode
    }
  }
`;


function Row({site, setGeography}) {
  const [open, setOpen] = React.useState(false);

  return (
    <React.Fragment>
      <tr>
        <td>
          <button onClick={() => setOpen(!open)}>
            {open}
          </button>
        </td>
        <td>{site.name}</td>
        <td>{site.locality}</td>
        <td>{site.countryCode}</td>
        <td>{site.siteCode}</td>
        <td>
          <button
            onClick={(evt) => {
              evt.preventDefault();
              setGeography(site);
            }}
            className='btn btn-default'>
              select
          </button>
        </td>
      </tr>
      <tr>
        <Collapse open={open}>
          <td colSpan='5'>
            <h4>Details</h4>
          </td>
        </Collapse>
      </tr>
    </React.Fragment>
  );
}

export default function GeographyDialog({open, setGeography, selectedValue, onClose}) {
  const [page, setPage] = React.useState(0);
  const [searchValue, setSearchValue] = React.useState('');
  const rowsPerPage = 8;

  const { loading, error, data } = useQuery(SITE_QUERY, {
    variables: {
      search: searchValue
    }
  });

  return (
    <div className={`modal modal-xl ${open ? 'd-block' : ''}`}>
      <div className='modal-dialog'>
        <div className='modal-content'>
          <div className='modal-header'>
            <h4 className='modal-title'>Select Site</h4>
            <button className='btn-close' onClick={(evt) => { evt.preventDefault(); onClose(); }} />
          </div>

          <div className="modal-body">
            <SiteSearchField onSearchChange={setSearchValue} searchValue={searchValue} />
            {loading && <p>Loading...</p>}
            {error && <p>Oh no... {error.message}</p>}
            <table className='table'>
              <thead>
                <tr>
                  <td />
                  <td>Name</td>
                  <td>Locality</td>
                  <td>Country Code</td>
                  <td>Site Code</td>
                  <td></td>
                </tr>
              </thead>
              <tbody>
                {data && data.sites.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(site => (
                  <Row setGeography={(value) => { setGeography(value); onClose(); }} key={site.id} site={site} />
                ))}
              </tbody>

              <tfoot>
                <tr>

                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
