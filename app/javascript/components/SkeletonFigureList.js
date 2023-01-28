import * as React from 'react';
import {SKELETONS_FIGURES_LIST_QUERY} from './queries';
import {Pagination, usePagination} from './Pagination';
import {Link} from 'wouter';

export default function SkeletonFigureList() {
  const paginationData = usePagination(SKELETONS_FIGURES_LIST_QUERY);
  const {data, loading, error} = paginationData;

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Oh no... {error.message}</p>;

  console.log(data);

  return (
    <div>
      <table className='table'>
        <thead>
          <tr>
            <td>ID</td>
            <td align="right"></td>
          </tr>
        </thead>
        <tbody>
          {data.skeletonFigures.map((skeleton) => (
            <tr key={skeleton.id}>
              <td>{skeleton.id}</td>
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
    </div>
  );
}
