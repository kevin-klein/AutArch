import * as React from 'react';
import { useQuery } from 'graphql-hooks';
import { useFieldArray, useForm } from 'react-hook-form';


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
`

function Row({site}) {
  const [open, setOpen] = React.useState(false);

  // {row.history.map((historyRow) => (
  //   <TableRow key={historyRow.date}>
  //     <TableCell component="th" scope="row">
  //       {historyRow.date}
  //     </TableCell>
  //     <TableCell>{historyRow.customerId}</TableCell>
  //     <TableCell align="right">{historyRow.amount}</TableCell>
  //     <TableCell align="right">
  //       {Math.round(historyRow.amount * row.price * 100) / 100}
  //     </TableCell>
  //   </TableRow>
  // ))}

  return (
    <React.Fragment>
      <TableRow sx={{ '& > *': { borderBottom: 'unset' } }}>
        <TableCell>
          <IconButton
            aria-label="expand row"
            size="small"
            onClick={() => setOpen(!open)}
          >
            {open ? <KeyboardArrowUpIcon /> : <KeyboardArrowDownIcon />}
          </IconButton>
        </TableCell>
        <TableCell component="th" scope="row">{site.name}</TableCell>
        <TableCell>{site.locality}</TableCell>
        <TableCell>{site.countryCode}</TableCell>
        <TableCell>{site.siteCode}</TableCell>
        <TableCell>{site.protein}</TableCell>
      </TableRow>
      <TableRow>
        <TableCell style={{ paddingBottom: 0, paddingTop: 0 }} colSpan={6}>
          <Collapse in={open} timeout="auto" unmountOnExit>
            <Box sx={{ margin: 1 }}>
              <Typography variant="h6" gutterBottom component="div">
                History
              </Typography>
              <Table size="small" aria-label="purchases">
                <TableHead>
                  <TableRow>
                    <TableCell>Date</TableCell>
                    <TableCell>Customer</TableCell>
                    <TableCell align="right">Amount</TableCell>
                    <TableCell align="right">Total price ($)</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>

                </TableBody>
              </Table>
            </Box>
          </Collapse>
        </TableCell>
      </TableRow>
    </React.Fragment>
  );
}

function SiteSearchField({onSearchChange, searchValue}) {

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

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Oh no... {error.message}</p>;

  return (
    <Dialog maxWidth='lg' onClose={onClose} open={open}>
      <DialogTitle>Select Site</DialogTitle>

      <SiteSearchField onSearchChange={setSearchValue} searchValue={searchValue} />
      <TableContainer>
        <Table sx={{ minWidth: 1200 }}>
          <TableHead>
            <TableRow>
              <TableCell />
              <TableCell>Name</TableCell>
              <TableCell>Locality</TableCell>
              <TableCell>Country Code</TableCell>
              <TableCell>Site Code</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {data.sites.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(site => (
              <Row key={site.id} site={site} />
            ))}
          </TableBody>

          <TableFooter>
            <TableRow>
              <TablePagination
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
              />
            </TableRow>
          </TableFooter>
        </Table>
      </TableContainer>
    </Dialog>
  )
}

function GeographyButton({geography}) {
  const [dialogOpen, setDialogOpen] = React.useState(false);

  let text = 'No Geography selected';
  if(geography !== null) {
    text = 'Some Geography';
  }

  function selectGeography() {
    setDialogOpen(true);
  }

  return (
    <div>
      <GeographyDialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        selectedValue={geography}
      />
      <Button onClick={selectGeography} variant="outlined">{text}</Button>
    </div>
  );
}

export default function SkeletonEditor({id}) {
  const formContext = useForm();
  const {control, register, handleSubmit} = formContext;

  const { fields, append, prepend, remove, swap, move, insert } = useFieldArray({
    control, // control props comes from useForm (optional: if you are using FormContext)
    name: "c14_dates", // unique name for your Field Array
  });

  const { loading, error, data } = useQuery(GRAVES_QUERY, {
    variables: {
      id: parseInt(id),
    }
  });

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Oh no... {error.message}</p>;
  const location = data.skeleton.location;

  return (
    <FormContainer
      formContext={formContext}
      handleSubmit={handleSubmit(() => console.log('submit'))}
    >
      <TextFieldElement fullWidth name="outlined-basic" label="Outlined" variant="outlined" />
      <h4>Geography</h4>
      <GeographyButton geography={location} />
      {JSON.stringify(data.skeleton.location)}
      <TextFieldElement name="filled-basic" label="Filled" variant="filled" />
      <TextFieldElement name="standard-basic" label="Standard" variant="standard" />
    </FormContainer>
  );
}
