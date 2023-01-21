import React from 'react';

export default function SiteSearchField({onSearchChange, searchValue}) {

  return (
    <input className='form-control' type='text' onChange={evt => onSearchChange(evt.target.value)} />
  );
}
