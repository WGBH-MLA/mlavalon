import React from 'react';

const MarsIngestItemTableRow = (props) => (

  <tr key={ props.id }>
    <td scope='col'>{ props.id }</td>
    <td scope='col'>{ props.created_at }</td>
    <td scope='col'>{ props.error_msg }</td>
    <td scope='col'>{ props.status }</td>
  </tr>

);

export default MarsIngestItemTableRow;