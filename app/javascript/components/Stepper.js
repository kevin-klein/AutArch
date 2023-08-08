import React from 'react';

export default function Stepper ({active, steps}) {
  const stepItems = steps.map((step, index) => (
    <li key={index} className={index===active ? 'stepper-item active' : 'stepper-item'}>
      <h3 className="stepper-title">{step}</h3>
    </li>
  ));

  return (
    <ol className='stepper'>
      {stepItems}
    </ol >
  );
};
