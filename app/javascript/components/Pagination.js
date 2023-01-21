import React from 'react';
import BootstrapPagination from 'react-bootstrap/Pagination';
import PageItem from 'react-bootstrap/PageItem';
import { useQuery } from 'graphql-hooks';

export function usePagination(query, { pageSize=25 } = {}) {
  const [limit, setLimit] = React.useState(25);
  const [offset, setOffset] = React.useState(0);

  const {data, loading, error} = useQuery(query, {
    variables: { limit, offset }
  });

  return {
    pageSize,
    limit,
    setLimit,
    offset,
    setOffset,
    data,
    loading,
    error
  };
}

export function Pagination({paginationData: {offset, setOffset, setLimit, pageSize, data}}) {
  const count = data.count;

  const pages = Math.ceil(count / pageSize);
  let items = [];
  for(let number = 0; number < pages; number++) {
    items.push(
      <PageItem onClick={() => { setOffset(number * 25); setLimit((number + 1) * pageSize); }} key={number} active={number === offset / 25}>
        {number+1}
      </PageItem>
    );
  }

  return (
    <BootstrapPagination>{items}</BootstrapPagination>
  );
}
