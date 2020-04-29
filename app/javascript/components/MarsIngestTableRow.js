import React from 'react';

const MarsIngestTableRow = (props) => (

    <tr key={ props.id }>
      <td scope='col'>{ props.id }</td>
      <td scope='col'><a href={ props.manifest_url }>{ props.manifest_url }</a></td>
      <td scope='col'>{ props.error_msg }</td>
      <td scope='col'>{ props.item_count }</td>
      <td scope='col'>{ props.created_at }</td>
      { props.is_index == true && <td><a href={ "/mars_ingests/" + props.id } className="btn btn-primary btn-small">View Ingest</a></td> }
    </tr>

);

export default MarsIngestTableRow;