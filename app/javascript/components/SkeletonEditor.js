/* eslint-disable react/prop-types */
import * as React from 'react';
import { useFieldArray, useForm, Controller } from 'react-hook-form';
import GeographyInput from './inputs/GeographyInput';
import TextInput from './inputs/TextInput';
import SimpleReferenceFieldDialog from './SimpleReferenceFieldDialog';
import SelectInput, { EnumSelectConverter, ObjectSelectConverter } from './inputs/SelectInput';
import { useQuery, useMutation } from 'graphql-hooks';
import GraveView from './GraveView';
import ErrorAlert from './ErrorAlert';
import {
  GRAVES_QUERY,
  UPDATE_SKELETON_MUTATION,
  CREATE_PERIOD_MUTATION,
  DELETE_PERIOD_MUTATION,
  CREATE_CULTURE_MUTATION,
  DELETE_CULTURE_MUTATION,
  CREATE_Y_HAPLOGROUP,
  DELETE_Y_HAPLOGROUP,
  CREATE_MT_HAPLOGROUP,
  DELETE_MT_HAPLOGROUP
} from './queries';

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

const sexEnum = [
  { id: 'female', text: 'Female' },
  { id: 'male', text: 'Male' },
  { id: 'unclear', text: 'Unclear' },
  { id: 'no_data', text: 'No Data' },
];

function SkeletonForm({skeleton, periods, bones, cultures, mtHaplogroups, yHaplogroups}) {
  let defaultValues = {};
  if(skeleton !== null && skeleton !== undefined) {
    defaultValues = (({grave, ...skeleton}) => skeleton)(skeleton);
    delete defaultValues.id;
    delete defaultValues.figure;
  }

  const {control, formState: { errors }, register, handleSubmit} = useForm({
    values: defaultValues
  });

  const { fields: c14Fields , append: c14Append, remove: c14Remove } = useFieldArray({
    control, // control props comes from useForm (optional: if you are using FormContext)
    name: 'chronology.c14Dates', // unique name for your Field Array
  });

  const { fields: isotopesFields , append: isotopesAppend, remove: isotopesRemove } = useFieldArray({
    control, // control props comes from useForm (optional: if you are using FormContext)
    name: 'stableIsotopes', // unique name for your Field Array
  });

  const { fields: geneticsFields , append: geneticsAppend, remove: geneticsRemove } = useFieldArray({
    control, // control props comes from useForm (optional: if you are using FormContext)
    name: 'genetics', // unique name for your Field Array
  });

  const [updateSkeleton] = useMutation(UPDATE_SKELETON_MUTATION);

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
        onSubmit={handleSubmit(async (args) => {
          console.log(args);
          const { data, error } = await updateSkeleton({ variables: { id: parseInt(skeleton.id), skeleton: args } });
          if(error) {
            ErrorAlert(error);
          }
          else {
            alert('Save successful');
          }
        })}
      >
        <TextInput register={register('skeletonId')} text='Skeleton ID' />

        <h6>Geography</h6>
        <Controller
          name='location'
          control={control}
          render={({ field: { onChange, value } }) =>
            <GeographyInput setGeography={(value) => onChange(value)} geography={value} />
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
            <div className='row'>
              <div className='col-md-6'>
                <h6>C14 Date {field.id}</h6>
              </div>
              <div className='col-md-6 align-items-end'>
                <button onClick={evt => { evt.preventDefault(); c14Remove(field.id); }} className='btn btn-sm btn-warning'>
                  Remove C14 Date
                </button>
              </div>
            </div>
            <TextInput
              text='Lab ID'
              register={register(`chronology.c14Dates.${index}.labId`)} />
            <TextInput
              type='number'
              text='Age BP'
              register={register(`chronology.c14Dates.${index}.ageBp`)} />
            <TextInput
              text='Interval'
              type='number'
              register={register(`chronology.c14Dates.${index}.interval`)} />
            <TextInput
              text='calbc1SigmaMax'
              type='number'
              register={register(`chronology.c14Dates.${index}.calbc1SigmaMax`)} />
            <TextInput
              text='calbc1SigmaMin'
              type='number'
              register={register(`chronology.c14Dates.${index}.calbc1SigmaMin`)} />
            <TextInput
              text='calbc2SigmaMax'
              type='number'
              register={register(`chronology.c14Dates.${index}.calbc2SigmaMax`)} />
            <TextInput
              text='calbc2SigmaMin'
              type='number'
              register={register(`chronology.c14Dates.${index}.calbc2SigmaMin`)} />
            <TextInput
              text='Date Note'
              register={register(`chronology.c14Dates.${index}.dateNote`)} />
            <TextInput
              text='Ref C14 Date'
              register={register(`chronology.c14Dates.${index}.ref14c`)} />
            <SelectInput
              converter={EnumSelectConverter}
              options={[
                {id: 'direct', text: 'Direct'},
                {id: 'indirect', text: 'Indirect'},
              ]}
              text='C14 Type'
              register={register(`chronology.c14Dates.${index}.c14Type`)} />
            <SelectInput
              converter={EnumSelectConverter}
              options={[
                {id: 'human_bone', text: 'Human Bone'},
                {id: 'lpp', text: 'LPP'},
                {id: 'charcocal', text: 'Charcocal' },
                {id: 'animal_bone', text: 'Animal Bone'}
              ]}
              text='Material'
              register={register(`chronology.c14Dates.${index}.material`)} />
            <SelectInput
              converter={EnumSelectConverter}
              options={[
                {id: 'oxcal_4_2_2', text: 'OxCal 4.2.2'},
                {id: 'int_cal_20', text: 'IntCal20'},
              ]}
              text='Calibration Method'
              register={register(`chronology.c14Dates.${index}.calMethod`)} />
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
            <div className='row'>
              <div className='col-md-6'>
                <h6>Stable Isotope {field.id}</h6>
              </div>
              <div className='col-md-6 align-items-end'>
                <button onClick={evt => { evt.preventDefault(); isotopesRemove(field.id); }} className='btn btn-sm btn-warning'>
                  Remove Stable Isotope
                </button>
              </div>
            </div>
            <TextInput
              text='ISO ID'
              register={register(`stableIsotopes.${index}.isoId`)} />
            <TextInput
              text='ISO Value'
              type='number'
              register={register(`stableIsotopes.${index}.isoValue`)} />
            <TextInput
              text='Ref ISO'
              register={register(`stableIsotopes.${index}.refIso`)} />
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
              register={register(`stableIsotopes.${index}.baseline`)} />
            <SelectInput
              converter={ObjectSelectConverter}
              options={bones}
              text='Bone'
              register={register(`stableIsotopes.${index}.boneId`)} />
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
            <div className='row'>
              <div className='col-md-6'>
                <h6>Genetic Data {field.id}</h6>
              </div>
              <div className='col-md-6 align-items-end'>
                <button onClick={evt => { evt.preventDefault(); geneticsRemove(field.id); }} className='btn btn-sm btn-warning'>
                  Remove Genetic Data
                </button>
              </div>
            </div>
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
              register={register(`genetics.${index}.boneId`)} />
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
              register={register(`genetics.${index}.mtHaplogroupId`)} />
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
              register={register(`genetics.${index}.yHaplogroupId`)} />
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
    <div className='row'>
      <div className='col-md-6'>
        <SkeletonForm {...data} />
      </div>

      <div className='col-md-6'>
        {data && <GraveView id={data.skeleton.skeleton_figure?.grave?.id} />}
      </div>
    </div>
  );
}
