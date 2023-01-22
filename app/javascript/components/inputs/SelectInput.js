/* eslint-disable react/prop-types */
import React from 'react';


export function EnumSelectConverter(item) {
  return {
    key: item.id,
    text: item.text,
    value: item.id,
  };
}

export function ObjectSelectConverter(item) {
  return {
    key: item.id,
    text: item.name,
    value: parseInt(item.id),
  };
}

export function TitleSelectConverter(item) {
  return {
    key: item.id,
    text: item.title,
    value: parseInt(item.id),
  };
}

export default function SelectInput({options, helpText, text, register, converter, includeBlank, wrap=true}) {
  const select = (
    <select {...register} className='form-select form-select-sm'>
      {includeBlank && <option value='' key='' />}
      {options?.map((item) => {
        const data = converter(item);
        return (
          <option key={data.key} value={data.value}>{data.text}</option>
        );
      })}
    </select>
  );

  if(wrap) {
    return (
      <div className='mb-3 row'>
        <label className='col-sm-2 col-form-label'>{text}</label>
        <div className='col-sm-10'>
          {select}
          {helpText}
        </div>
      </div>
    );
  }
  else {
    return (
      <React.Fragment>
        {select}
        {helpText}
      </React.Fragment>
    );
  }
}
