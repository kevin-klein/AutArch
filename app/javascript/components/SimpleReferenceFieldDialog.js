import React from 'react';
import Tab from 'react-bootstrap/Tab';
import Tabs from 'react-bootstrap/Tabs';
import TextInput from './inputs/TextInput';
import { useForm } from 'react-hook-form';
import { useMutation } from 'graphql-hooks';


export default function SimpleReferenceFieldDialog({open, deleteMutation, existingItems, text, onClose, mutation}) {
  const {register, handleSubmit} = useForm();
  const [createItem] = useMutation(mutation, {
    onSuccess: (result) => {
      console.log(result);
    }
  });

  const [deleteItem] = useMutation(deleteMutation, {

  });

  function onSubmit(data) {
    createItem({variables: data}).then((result) => {
      if(result.error) {
        alert(result.error);
      }

      onClose();
    });
  }

  function onDeleteItem(id) {
    deleteItem({variables: {id}}).then((result) => {
      if(result.error) {
        alert(result.error);
      }
    });
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
