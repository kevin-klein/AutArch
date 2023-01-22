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

export default function SelectInput({options, helpText, text, register, converter}) {
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
