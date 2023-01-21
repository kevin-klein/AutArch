import React from 'react';

export default function TextInput({register, text, type='text'}) {
  return (
    <div className='mb-3 row'>
      <label className='col-sm-2 col-form-label'>{text}</label>

      <div className='col-sm-10'>
        <input {...register} type={type} className='form-control' />
      </div>
    </div>
  );
}
