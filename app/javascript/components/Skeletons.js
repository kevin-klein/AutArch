import * as React from 'react';
import {Link} from 'wouter';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Title from './Title';
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
      <Title>Skeletons</Title>
      <Table size="small">
        <TableHead>
          <TableRow>
            <TableCell>ID</TableCell>
            <TableCell>Skeleton ID</TableCell>
            <TableCell>Ship To</TableCell>
            <TableCell>Payment Method</TableCell>
            <TableCell align="right"></TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {data.skeletons.map((skeleton) => (
            <TableRow key={skeleton.id}>
              <TableCell>{skeleton.id}</TableCell>
              <TableCell></TableCell>
              <TableCell></TableCell>
              <TableCell></TableCell>
              <TableCell align="right">
                <Link href={`/skeletons/${skeleton.id}`}>
                  Edit
                </Link>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      <Link color="primary" href="#" onClick={preventDefault} sx={{ mt: 3 }}>
        See more orders
      </Link>
    </React.Fragment>
  );
}
