/* eslint-disable react/prop-types */
import * as React from 'react';
import { useQuery } from 'graphql-hooks';
import { useFieldArray, useForm } from 'react-hook-form';
import Collapse from './Collapse';

const GRAVES_QUERY = `
  query($id: Int!) {
    bones {
      id
      name
    }
    periods {
      id
      name
    }
    skeleton(id: $id) {
      id
      skeletonId
      figure {
        id
        x1
        y1
        x2
        y2
        label
      }
      location {
        id
        lat
        lon
        name
      }
      chronology {
        id
        contextFrom
        contextTo
        period {
          id
          name
        }
        c14dates {
          id
          c14Type
          labId
          ageBp
          interval
          material
          calbc1SigmaMax
          calbc1SigmaMin
          calbc2SigmaMax
          calbc2SigmaMin
          dateNote
          calMethod
          ref14c
          bone {
            id
            name
          }
        }
      }
      anthropology {
        id
        sexMorph
        sexGen
        sexConsensus
        ageAsReported
        ageClass
        height
        pathologies
        pathologiesType
      }
      taxonomy {
        id
        cultureReference
        cultureNote
        culture {
          id
          name
        }
      }
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

const SITE_QUERY = `
  query {
    sites {
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

function Row({site}) {
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
        <td><button onClick={() => console.log('select site')} className='btn btn-default'>select</button></td>
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

{/* <Collapse in={open} timeout="auto" unmountOnExit>
            <Box sx={{ margin: 1 }}>
              <Typography variant="h6" gutterBottom component="div">
                History
              </Typography>
              <Table size="small" aria-label="purchases">
                <TableHead>
                  <TableRow>
                    <td>Date</td>
                    <td>Customer</td>
                    <td align="right">Amount</td>
                    <td align="right">Total price ($)</td>
                  </TableRow>
                </TableHead>
                <TableBody>

                </TableBody>
              </Table>
            </Box>
          </Collapse> */}

function SiteSearchField({onSearchChange, searchValue}) {

  return (
    <input type='text' onChange={evt => onSearchChange(evt.target.value)} />
  );

  return (
    <Grid container direction="row" justifyContent='flex-end'>
      <Grid item xs={12}>
        <TextField
          sx={{marginLeft: 5}}
          id="standard-basic"
          label="Search"
          value={searchValue}
          onChange={(evt) => onSearchChange(evt.target.value)}
          variant="standard"
        />
      </Grid>
    </Grid>
  );
}

function GeographyDialog({open, selectedValue, onClose}) {
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
            <button className='btn-close' onClick={onClose} />
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
                  <Row key={site.id} site={site} />
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

{/* <TablePagination
                  rowsPerPageOptions={[5, 10, 25, { label: 'All', value: -1 }]}
                  colSpan={3}
                  count={data.sites.length}
                  rowsPerPage={rowsPerPage}
                  page={page}
                  SelectProps={{
                    inputProps: {
                      'aria-label': 'rows per page',
                    },
                    native: true,
                  }}
                  onPageChange={(_, newPage) => setPage(newPage)}
                /> */}

function GeographyButton({geography}) {
  const [dialogOpen, setDialogOpen] = React.useState(false);

  let text = 'No Geography selected';
  if(geography !== null) {
    text = 'Some Geography';
  }

  function selectGeography() {
    setDialogOpen(true);
  }

  function setGeography(value) {

  }

  return (
    <div>
      <GeographyDialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        selectedValue={geography}
        setGeography={setGeography}
      />
      <button className='btn btn-primary' onClick={selectGeography}>{text}</button>
    </div>
  );
}

function SkeletonForm({skeleton}) {
  const {control, setValue, register, handleSubmit} = useForm({
    defaultValues: skeleton
  });

  const { fields, append, prepend, remove, swap, move, insert } = useFieldArray({
    control, // control props comes from useForm (optional: if you are using FormContext)
    name: 'c14_dates', // unique name for your Field Array
  });

  const location = skeleton.location;

  return (
    <form
      onSubmit={handleSubmit((args) => console.log(args))}
    >
      <input {...register('skeleton_id')} />
      <h4>Geography</h4>
      <GeographyButton geography={location} />
      {JSON.stringify(skeleton.location)}
    </form>
  )
}

export default function SkeletonEditor({id}) {
  const { loading, error, data } = useQuery(GRAVES_QUERY, {
    variables: {
      id: parseInt(id),
    }
  });

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Oh no... {error.message}</p>;

  return (
    <SkeletonForm skeleton={data.skeleton} />
  );
}
