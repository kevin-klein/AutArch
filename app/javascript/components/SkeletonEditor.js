import * as React from 'react';
import { useQuery } from 'graphql-hooks';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import {FormContainer, TextFieldElement} from 'react-hook-form-mui';
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

  return (
    <FormContainer
      formContext={formContext}
      handleSubmit={handleSubmit(() => console.log('submit'))}
    >
      <TextFieldElement name="outlined-basic" label="Outlined" variant="outlined" />
      <TextFieldElement name="filled-basic" label="Filled" variant="filled" />
      <TextFieldElement name="standard-basic" label="Standard" variant="standard" />
    </FormContainer>
  );
}
