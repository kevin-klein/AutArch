import * as React from 'react';
import {Link} from 'wouter';
import {Pagination, usePagination} from './Pagination';

const SKELETONS_QUERY = `
  query($offset: Int!, $limit: Int!) {
    count: skeletonsCount
    skeletons(offset: $offset, limit: $limit) {
      id
    }
  }
`;


function preventDefault(event) {
  event.preventDefault();
}

export default function Orders() {
  const paginationData = usePagination(SKELETONS_QUERY);
  const {data, loading, error} = paginationData;

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Oh no... {error.message}</p>;

  return (
    <React.Fragment>
      <h4>Skeletons</h4>
      <table className='table'>
        <thead>
          <tr>
            <td>ID</td>
            <td>Skeleton ID</td>
            <td>Ship To</td>
            <td>Payment Method</td>
            <td align="right"></td>
          </tr>
        </thead>
        <tbody>
          {data.skeletons.map((skeleton) => (
            <tr key={skeleton.id}>
              <td>{skeleton.id}</td>
              <td></td>
              <td></td>
              <td></td>
              <td align="right">
                <Link href={`/skeletons/${skeleton.id}`}>
                  Edit
                </Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <Pagination paginationData={paginationData} />
    </React.Fragment>
  );
}
