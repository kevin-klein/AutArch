import * as React from 'react';
import {Link} from 'wouter';
import {Pagination, usePagination} from './Pagination';
import TextInput from './inputs/TextInput';
import SelectInput, {TitleSelectConverter} from './inputs/SelectInput';
import { useFieldArray, useForm, Controller } from 'react-hook-form';

const SKELETONS_QUERY = `
  query($offset: Int!, $limit: Int!) {
    count: skeletonsCount
    skeletons(offset: $offset, limit: $limit) {
      id
      skeletonId
    }

    publications {
      id
      title
      author
    }
  }
`;

export default function SkeletonList() {
  const [searchPublicationId, setSearchPublicationId] = React.useState(null);
  const paginationData = usePagination(SKELETONS_QUERY, {
    variables: {
      publicationId: searchPublicationId
    }
  });
  const {data, loading, error} = paginationData;

  const {formState: { errors }, register, handleSubmit} = useForm({
  });

  const onSubmit = data => setSearchPublicationId(data.publicationId);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Oh no... {error.message}</p>;

  return (
    <React.Fragment>
      <h4>Skeletons</h4>
      <form onSubmit={handleSubmit(onSubmit)} className="row gy-2 gx-3 align-items-center">
        <div className='col-auto'>
          <SelectInput
            register={register('publicationId')}
            text='Publication'
            wrap={false}
            includeBlank={true}
            options={data.publications}
            converter={TitleSelectConverter} />
        </div>

        <div className='col-auto'>
          <button type="submit" className="btn btn-primary">Search</button>
        </div>
      </form>

      <table className='table'>
        <thead>
          <tr>
            <td>ID</td>
            <td>Skeleton ID</td>
            <td align="right"></td>
          </tr>
        </thead>
        <tbody>
          {data.skeletons.map((skeleton) => (
            <tr key={skeleton.id}>
              <td>{skeleton.id}</td>
              <td>{skeleton.skeletonId}</td>
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
