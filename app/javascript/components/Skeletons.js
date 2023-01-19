import * as React from 'react';
import {Link} from 'wouter';
import { useQuery } from 'graphql-hooks';

const GRAVES_QUERY = `
  query($offset: Int!, $limit: Int!) {
    skeletons(offset: $offset, limit: $limit) {
      id
      grave {
        id

        page {
          image {
            data
          }
        }
      }
    }
  }
`;


function preventDefault(event) {
  event.preventDefault();
}

export default function Orders() {
  const { loading, error, data } = useQuery(GRAVES_QUERY, {
    variables: {
      limit: 10,
      offset: 0
    }
  });

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
      <Link color="primary" href="#" onClick={preventDefault} sx={{ mt: 3 }}>
        See more orders
      </Link>
    </React.Fragment>
  );
}
