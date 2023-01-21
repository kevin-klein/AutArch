/* eslint-disable react/prop-types */
import * as React from 'react';
import { useQuery, useMutation, useQueryClient } from 'graphql-hooks';
import { useFieldArray, useForm, Controller } from 'react-hook-form';
import Collapse from './Collapse';
import Tab from 'react-bootstrap/Tab';
import Tabs from 'react-bootstrap/Tabs';

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
    cultures {
      id
      name
    }
    mtHaplogroups {
      id
      name
    }
    yHaplogroups {
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
      genetics {
        id
        dataType
        endoContent
        boneId
        mtHaplogroupId
        yHaplogroupId
        refGen
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
      stableIsotopes {
        id
        isoId
        isoValue
        refIso
        isotope
        baseline
        bone {
          id
          name
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

const CREATE_PERIOD_MUTATION = `mutation CreatePeriod($name: String!) {
  createPeriod(name: $name) {
    period {
      id
      name
    }
  }
}`;

const DELETE_PERIOD_MUTATION = `mutation DeletePeriod($id: String!) {
  deletePeriod(id: $id) { id }
}`;

const CREATE_CULTURE_MUTATION = `mutation CreateCulture($name: String!) {
  createCulture(name: $name) {
    culture {
      id
      name
    }
  }
}`;

const DELETE_CULTURE_MUTATION = `mutation DeleteCulture($id: String!) {
  deleteCulture(id: $id) { id }
}`;

const CREATE_MT_HAPLOGROUP = `mutation CreateMTHaplogroup($name: String!) {
  createMtHaplogroup(name: $name) {
    mtHaplogroup {
      id
      name
    }
  }
}`;

const DELETE_MT_HAPLOGROUP = `mutation DeleteMtHaplogroup($id: String!) {
  deleteMtHaplogroup(id: $id) { id }
}`;

const CREATE_Y_HAPLOGROUP = `mutation CreateYHaplogroup($name: String!) {
  createYHaplogroup(name: $name) {
    yHaplogroup {
      id
      name
    }
  }
}`;

const DELETE_Y_HAPLOGROUP = `mutation DeleteYHaplogroup($id: String!) {
  deleteYHaplogroup(id: $id) { id }
}`;


const SITE_QUERY = `
  query($search: String) {
    sites(search: $search) {
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

function Row({site, setGeography}) {
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
        <td>
          <button
            onClick={(evt) => {
              evt.preventDefault();
              setGeography(site);
            }}
            className='btn btn-default'>
              select
          </button>
        </td>
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
    <input className='form-control' type='text' onChange={evt => onSearchChange(evt.target.value)} />
  );
}

function GeographyDialog({open, setGeography, selectedValue, onClose}) {
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
            <button className='btn-close' onClick={(evt) => { evt.preventDefault(); onClose(); }} />
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
                  <Row setGeography={(value) => { setGeography(value); onClose(); }} key={site.id} site={site} />
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

function GeographyButton({geography, setGeography}) {
  const [dialogOpen, setDialogOpen] = React.useState(false);

  let text = 'No Geography selected';
  if(geography !== null && geography !== undefined) {
    text = geography.name;
  }

  function selectGeography() {
    setDialogOpen(true);
  }

  return (
    <div className='mb-3 mt-3'>
      <GeographyDialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        selectedValue={geography}
        setGeography={setGeography}
      />
      <button className='btn btn-primary' onClick={(evt) => { evt.preventDefault(); selectGeography(); }}>{text}</button>
    </div>
  );
}

function TextInput({register, text, type='text'}) {
  return (
    <div className='mb-3 row'>
      <label className='col-sm-2 col-form-label'>{text}</label>

      <div className='col-sm-10'>
        <input {...register} type={type} className='form-control' />
      </div>
    </div>
  );
}

function SelectInput({options, helpText, text, register, converter}) {
  return (
    <div className='mb-3 row'>
      <label className='col-sm-2 col-form-label'>{text}</label>
      <div className='col-sm-10'>
        <select {...register} className='form-select form-select-sm'>
          {options?.map((item) => {
            const data = converter(item);
            return (
              <option key={data.key} value={data.value}>{data.text}</option>
            );
          })}
        </select>
        {helpText}
      </div>
    </div>
  );
}

function EnumSelectConverter(item) {
  return {
    key: item.id,
    text: item.text,
    value: item.id,
  };
}

function ObjectSelectConverter(item) {
  return {
    key: item.id,
    text: item.name,
    value: item.name,
  };
}

const sexEnum = [
  { id: 'female', text: 'Female' },
  { id: 'male', text: 'Male' },
  { id: 'unclear', text: 'Unclear' },
  { id: 'no_data', text: 'No Data' },
];

function SimpleReferenceFieldDialog({open, deleteMutation, existingItems, text, onClose, mutation}) {
  const {register, handleSubmit} = useForm();
  const [createItem] = useMutation(mutation, {
    onSuccess: () => {
      onClose();
    }
  });

  const [deleteItem] = useMutation(deleteMutation, {

  });

  function onSubmit(data) {
    createItem({
      variables: data
    });
  }

  function onDeleteItem(id) {
    deleteItem({variables: { id: id }});
  }

  return (
    <div className={`modal modal-xl ${open ? 'd-block' : ''}`}>
      <div className='modal-dialog'>
        <div className='modal-content'>
          <div className='modal-header'>
            <h4 className='modal-title'>{text}</h4>
            <button className='btn-close' onClick={(evt) => { evt.preventDefault(); onClose(); }} />
          </div>

          <div className="modal-body">
            <Tabs
              defaultActiveKey='createItem'
            >
              <Tab title='Create' eventKey='createItem'>
                <form onSubmit={handleSubmit(onSubmit)}>
                  <TextInput register={register('name', { required: true })} text='Name' />
                  <input type='submit' className='form-control' />
                </form>
              </Tab>

              <Tab title='Delete' eventKey='deleteItem'>
                <table className='table'>
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th />
                    </tr>
                  </thead>
                  <tbody>
                    {existingItems?.map((item) =>
                      (<tr key={item.id}>
                        <td>{item.name}</td>
                        <td>
                          <button onClick={() => onDeleteItem(item.id)} className='btn btn-secondary'>
                            Delete
                          </button>
                        </td>
                      </tr>)
                    )}
                  </tbody>
                </table>
              </Tab>
            </Tabs>
          </div>
        </div>
      </div>
    </div>
  );
}

function SkeletonForm({skeleton, periods, bones, cultures, mtHaplogroups, yHaplogroups}) {
  let defaultValues = {};
  if(skeleton !== null && skeleton !== undefined) {
    defaultValues = (({grave, ...skeleton}) => skeleton)(skeleton);
  }
  const {control, formState: { errors }, register, handleSubmit} = useForm({
    defaultValues: defaultValues
  });

  const { fields: c14Fields , append: c14Append, remove: c14Remove } = useFieldArray({
    control, // control props comes from useForm (optional: if you are using FormContext)
    name: 'chronology.c14dates', // unique name for your Field Array
  });

  const { fields: isotopesFields , append: isotopesAppend, remove: isotopesRemove } = useFieldArray({
    control, // control props comes from useForm (optional: if you are using FormContext)
    name: 'stableIsotopes', // unique name for your Field Array
  });

  const { fields: geneticsFields , append: geneticsAppend, remove: geneticsRemove } = useFieldArray({
    control, // control props comes from useForm (optional: if you are using FormContext)
    name: 'stableIsotopes', // unique name for your Field Array
  });

  const [showPeriodsModal, setShowPeriodsModal] = React.useState(false);
  const [showCulturesModal, setShowCulturesModal] = React.useState(false);
  const [showMtHaplogroupModal, setShowMtHaplogroupModal] = React.useState(false);
  const [showYHaplogroupModal, setShowYHaplogroupModal] = React.useState(false);
  return (
    <React.Fragment>
      <SimpleReferenceFieldDialog
        open={showPeriodsModal}
        existingItems={periods}
        text={'Manage Periods'}
        mutation={CREATE_PERIOD_MUTATION}
        deleteMutation={DELETE_PERIOD_MUTATION}
        onClose={() => setShowPeriodsModal(false)}
      />
      <SimpleReferenceFieldDialog
        open={showMtHaplogroupModal}
        existingItems={mtHaplogroups}
        text={'Manage MT Haplogroups'}
        mutation={CREATE_MT_HAPLOGROUP}
        deleteMutation={DELETE_MT_HAPLOGROUP}
        onClose={() => setShowMtHaplogroupModal(false)}
      />
      <SimpleReferenceFieldDialog
        open={showYHaplogroupModal}
        existingItems={yHaplogroups}
        text={'Manage Y Haplogroups'}
        mutation={CREATE_Y_HAPLOGROUP}
        deleteMutation={DELETE_Y_HAPLOGROUP}
        onClose={() => setShowYHaplogroupModal(false)}
      />
      <SimpleReferenceFieldDialog
        open={showCulturesModal}
        existingItems={cultures}
        text={'Manage Cultures'}
        mutation={CREATE_CULTURE_MUTATION}
        deleteMutation={DELETE_CULTURE_MUTATION}
        onClose={() => setShowCulturesModal(false)}
      />
      <form
        onSubmit={handleSubmit((args) => console.log(JSON.stringify(args, null, 2)))}
      >
        <TextInput register={register('skeletonId')} text='Skeleton ID' />

        <h6>Geography</h6>
        <Controller
          name='location'
          control={control}
          render={({ field: { onChange, value } }) =>
            <GeographyButton setGeography={(value) => onChange(value)} geography={value} />
          }
        />

        <h6>Chronology</h6>
        <TextInput register={register('chronology.contextFrom')} text='Chronology To' />
        <TextInput register={register('chronology.contextTo')} text='Chronology To' />
        <SelectInput
          register={register('chronology.periodId')}
          options={periods}
          text='Period'
          helpText={
            <div className="form-text">
              <a href='#' onClick={(evt) => { evt.preventDefault(); setShowPeriodsModal(true); }}>
                Manage Periods
              </a>
            </div>
          }
          converter={ObjectSelectConverter}
        />

        {c14Fields.map((field, index) => (
          <React.Fragment key={field.id}>
            <h6>C14 Date {field.id}</h6>
            <TextInput
              text='Lab ID'
              register={register(`chronology.c14_dates.${index}.labId`)} />
            <TextInput
              type='number'
              text='Age BP'
              register={register(`chronology.c14_dates.${index}.ageBp`)} />
            <TextInput
              text='Interval'
              type='number'
              register={register(`chronology.c14_dates.${index}.interval`)} />
            <TextInput
              text='calbc1SigmaMax'
              type='number'
              register={register(`chronology.c14_dates.${index}.calbc1SigmaMax`)} />
            <TextInput
              text='calbc1SigmaMin'
              type='number'
              register={register(`chronology.c14_dates.${index}.calbc1SigmaMin`)} />
            <TextInput
              text='calbc2SigmaMax'
              type='number'
              register={register(`chronology.c14_dates.${index}.calbc2SigmaMax`)} />
            <TextInput
              text='calbc2SigmaMin'
              type='number'
              register={register(`chronology.c14_dates.${index}.calbc2SigmaMin`)} />
            <TextInput
              text='Date Note'
              register={register(`chronology.c14_dates.${index}.dateNote`)} />
            <TextInput
              text='Ref C14 Date'
              register={register(`chronology.c14_dates.${index}.ref14c`)} />
            <SelectInput
              converter={EnumSelectConverter}
              options={[
                {id: 'direct', text: 'Direct'},
                {id: 'indirect', text: 'Indirect'},
              ]}
              text='C14 Type'
              register={register(`chronology.c14_dates.${index}.c14Type`)} />
            <SelectInput
              converter={EnumSelectConverter}
              options={[
                {id: 'human_bone', text: 'Human Bone'},
                {id: 'lpp', text: 'LPP'},
                {id: 'charcocal', text: 'Charcocal' },
                {id: 'animal_bone', text: 'Animal Bone'}
              ]}
              text='Material'
              register={register(`chronology.c14_dates.${index}.material`)} />
            <SelectInput
              converter={EnumSelectConverter}
              options={[
                {id: 'oxcal_4_2_2', text: 'OxCal 4.2.2'},
                {id: 'int_cal_20', text: 'IntCal20'},
              ]}
              text='Calibration Method'
              register={register(`chronology.c14_dates.${index}.calMethod`)} />
            <div className='mb-3'>
              <button onClick={(evt) => { evt.preventDefault(); c14Remove(index); }} className='btn btn-primary'>Delete</button>
            </div>
          </React.Fragment>
        ))}

        <button
          onClick={(evt) => { evt.preventDefault(); c14Append({}); }}
          className='btn btn-secondary'>
            Add C14 Date
        </button>

        <h6>Anthropology</h6>

        <SelectInput
          register={register('anthropology.sexMorph')}
          options={sexEnum}
          text='Sex Morphologic'
          converter={EnumSelectConverter} />

        <SelectInput
          register={register('anthropology.sexGen')}
          options={sexEnum}
          text='Sex Genetic'
          converter={EnumSelectConverter} />

        <SelectInput
          register={register('anthropology.sexConsensus')}
          options={sexEnum}
          text='Sex Consensus'
          converter={EnumSelectConverter} />

        <SelectInput
          converter={EnumSelectConverter}
          options={[
            {id: 'neonate', text: 'Neonate'},
            {id: 'child', text: 'Child'},
            {id: 'young_adult', text: 'young Adult'}
          ]}
          text='Age Class'
          register={register('anthropology.ageClass')} />

        <TextInput register={register('anthropology.ageAsReported')} text='Age as Reported' />
        <TextInput type='number' register={register('anthropology.height')} text='Height (cm)' />

        <TextInput register={register('anthropology.pathologiesType')} text='Pathologies Type' />

        <h6>Taxonomy</h6>
        <SelectInput
          converter={ObjectSelectConverter}
          options={cultures}
          text='Culture'
          helpText={
            <div className="form-text">
              <a href='#' onClick={(evt) => { evt.preventDefault(); setShowCulturesModal(true); }}>
                Manage Cultures
              </a>
            </div>
          }
          register={register('taxonomy.cultureId')} />
        <TextInput register={register('taxonomy.cultureReference')} text='Culture Reference' />
        <TextInput register={register('taxonomy.cultureNote')} text='Culture Note' />

        <h6>Stable Isotopes</h6>
        {isotopesFields.map((field, index) => (
          <React.Fragment key={field.id}>
            <TextInput
              text='ISO ID'
              register={register(`stableIsotopes.${index}.isoId`)} />
            <TextInput
              text='ISO Value'
              type='number'
              register={register(`stableIsotopes.${index}.isoId`)} />
            <TextInput
              text='Ref ISO'
              register={register(`stableIsotopes.${index}.isoId`)} />
            <SelectInput
              converter={EnumSelectConverter}
              options={[
                {id: 'c13', text: 'C13'},
                {id: 'n15', text: 'N15'},
                {id: 'sr', text: 'Sr' },
                {id: 's34', text: 'S34'}
              ]}
              text='Isotope'
              register={register(`stableIsotopes.${index}.isotope`)} />
            <TextInput
              text='Baseline'
              type='number'
              register={register(`stableIsotopes.${index}.isoId`)} />
            <SelectInput
              converter={ObjectSelectConverter}
              options={bones}
              text='Bone'
              register={register(`stableIsotopes.${index}.isotope`)} />
          </React.Fragment>
        ))}
        <button
          onClick={(evt) => { evt.preventDefault(); isotopesAppend({}); }}
          className='btn btn-secondary'>
            Add Stable Isotope
        </button>

        <h6>Genetics</h6>
        {geneticsFields.map((field, index) => (
          <React.Fragment key={field.id}>
            <SelectInput
              converter={EnumSelectConverter}
              options={[
                {id: 'k1240', text: '1240K.capture'},
                {id: 'mt', text: 'mt.capture'},
                {id: 'shotgun', text: 'Shotgun' },
                {id: 'screened', text: 'Screened'}
              ]}
              text='Data Type'
              register={register(`genetics.${index}.dataType`)} />
            <TextInput
              text='Endogenous Content'
              type='number'
              register={register(`genetics.${index}.endoContent`)} />
            <SelectInput
              converter={ObjectSelectConverter}
              options={bones}
              text='Bone'
              register={register(`genetics.${index}.bone`)} />
            <SelectInput
              converter={ObjectSelectConverter}
              options={mtHaplogroups}
              text='MT Haplogroup'
              helpText={
                <div className="form-text">
                  <a href='#' onClick={(evt) => { evt.preventDefault(); setShowMtHaplogroupModal(true); }}>
                    Manage MT Haplogroups
                  </a>
                </div>
              }
              register={register(`genetics.${index}.bone`)} />
            <SelectInput
              converter={ObjectSelectConverter}
              options={yHaplogroups}
              text='Y Haplogroup'
              helpText={
                <div className="form-text">
                  <a href='#' onClick={(evt) => { evt.preventDefault(); setShowYHaplogroupModal(true); }}>
                    Manage Y Haplogroups
                  </a>
                </div>
              }
              register={register(`genetics.${index}.bone`)} />
            <TextInput
              text='Reference Genetic'
              register={register(`genetics.${index}.refGen`)} />
          </React.Fragment>
        ))}
        <button
          onClick={(evt) => { evt.preventDefault(); geneticsAppend({}); }}
          className='btn btn-secondary'>
            Add Genetic Data
        </button>

        <input className='form-control mt-3' type='submit' />
      </form>
    </React.Fragment>
  );
}

export default function SkeletonEditor({id}) {
  const { loading, error, data } = useQuery(GRAVES_QUERY, {
    variables: {
      id: parseInt(id),
    },
    refetchAfterMutations: [
      {
        mutation: CREATE_PERIOD_MUTATION,
      },
      {
        mutation: DELETE_PERIOD_MUTATION
      },
      {
        mutation: CREATE_CULTURE_MUTATION
      },
      {
        mutation: DELETE_CULTURE_MUTATION
      },
      {
        mutation: CREATE_Y_HAPLOGROUP
      },
      {
        mutation: DELETE_Y_HAPLOGROUP
      },
      {
        mutation: CREATE_MT_HAPLOGROUP
      },
      {
        mutation: DELETE_MT_HAPLOGROUP
      }
    ]
  });

  // if (loading) return <p>Loading...</p>;
  // if (error) return <p>Oh no... {error.message}</p>;

  return (
    <SkeletonForm {...data} />
  );
}
