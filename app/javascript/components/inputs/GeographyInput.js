import React from 'react';
import GeographyDialog from '../GeographyDialog';

export default function GeographyInput({geography, setGeography}) {
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
