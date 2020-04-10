import React from 'react';

const MarsIngest = (props) => (
  <tr key={ props.id }>
    <td scope='col'><a href={ "/mars_ingests/" + props.id }>{ props.id }</a></td>
    <td scope='col'><a href={ "/mars_ingests/" + props.id }>{ props.manifest_url }</a></td>
    <td scope='col'><a href={ "/mars_ingests/" + props.id }>{ props.status }</a></td>
    <td scope='col'><a href={ "/mars_ingests/" + props.id }>{ props.error_msg }</a></td>
    <td scope='col'><a href={ "/mars_ingests/" + props.id }>{ props.item_count }</a></td>
    <td scope='col'><a href={ "/mars_ingests/" + props.id }>{ props.created_at }</a></td>
  </tr>
);

export default MarsIngest;