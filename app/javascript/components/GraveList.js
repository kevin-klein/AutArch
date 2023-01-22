import React from 'react';
import { useQuery } from 'graphql-hooks';
import {Pagination, usePagination} from './Pagination';
import {Link} from 'wouter';

const GRAVES_QUERY = `query($limit: Int!, $offset: Int!) {
  graves(offset: $offset, limit: $limit) {
    id
    areaWithUnit {
      unit
      value
    }
    arcLengthWithUnit {
      unit
      value
    }
  }
  count: gravesCount
}
`;



export default function GraveList() {
  const paginationData = usePagination(GRAVES_QUERY);
  const {data, loading, error} = paginationData;

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Oh no... {error.message}</p>;

  return (
    <div>
      <h3>Grave List</h3>

      <table className='table'>
        <thead>
          <tr>
            <td>ID</td>
            <td>Area</td>
            <td>Arc</td>
            <td align="right"></td>
          </tr>
        </thead>
        <tbody>
          {data.graves.map((grave) => (
            <tr key={grave.id}>
              <td>{grave.id}</td>
              <td>{grave.areaWithUnit.value.toFixed(2)}{grave.areaWithUnit.unit} </td>
              <td>{grave.arcLengthWithUnit.value.toFixed(2)}{grave.arcLengthWithUnit.unit} </td>
              <td align="right">
                <Link href={`/graves/${grave.id}`}>
                  Edit
                </Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <Pagination paginationData={paginationData} />
    </div>
  );
}
