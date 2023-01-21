import React from 'react';
import { useQuery, useMutation, useQueryClient } from 'graphql-hooks';

const GRAVES_QUERY = `query GravesQuery {
  graves {
    id
  }
}
`;
export default function GraveList() {
  const {data, loading, error} = useQuery(GRAVES_QUERY);

  return (
    <div>
      <h3>Grave List</h3>
    </div>
  );
}
