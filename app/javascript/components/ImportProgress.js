import React from 'react'
import MessageBus from '../message-bus'

export default function ImportProgress ({ lastID }) {
  const [messages, setMessages] = React.useState([])

  React.useEffect(() => {
    MessageBus.start()

    MessageBus.subscribe('/importprogress', (data) => {
      if (data.progress !== undefined) {
        setMessages(messages => {
          const lastElement = messages[messages.length - 1]
          if (lastElement.progress !== undefined) {
            return [...messages.slice(0, -1), data]
          } else {
            return [...messages, data]
          }
        })
      } else {
        setMessages(messages => [...messages, data])
      }
    }, lastID)
  }, [])

  return (
    <div className='row'>
      <div className='col-md-3' />
      <div className='col-md-6'>
        {messages.map((message, index) => {
          if (message.progress !== undefined) {
            return (
              <React.Fragment key={index}>
                <div>Analyzing Page Content</div>
                <div className='progress'>
                  <div className='progress-bar' style={{ width: message.progress * 100 + '%' }} />
                </div>
              </React.Fragment>
            )
          } else {
            return (<div key={index}>{message}</div>)
          }
        })}
      </div>

    </div>
  )
}
