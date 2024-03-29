/*
 * Copyright 2011-2020, The Trustees of Indiana University and Northwestern
 *   University.  Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed
 *   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 *   CONDITIONS OF ANY KIND, either express or implied. See the License for the
 *   specific language governing permissions and limitations under the License.
 * ---  END LICENSE_HEADER BLOCK  ---
*/

import React from 'react';
import PropTypes from 'prop-types';
import CollectionCardShell from '../CollectionCardShell';
import CollectionCardThumbnail from '../CollectionCardThumbnail';
import CollectionCardBody from '../CollectionCardBody';

const CardMetaData = ({ doc, fieldLabel, fieldName }) => {
  let metaData = null;
  if (Array.isArray(doc[fieldName]) && doc[fieldName].length > 1) {
    metaData = doc[fieldName].join(', ');
  } else if (typeof doc[fieldName] == 'string') {
    const summary = doc[fieldName].substring(0, 30);
    metaData = doc[fieldName].length >= 30 ? `${summary}...` : doc[fieldName];
  } else {
    metaData = doc[fieldName];
  }

  if (doc[fieldName]) {
    return (
      <React.Fragment>
        <dt>{fieldLabel}</dt>
        <dd>{metaData}</dd>
      </React.Fragment>
    );
  }
  return null;
};

CardMetaData.propTypes = {
  doc: PropTypes.object,
  fieldLabel: PropTypes.string,
  fieldName: PropTypes.string
};

const millisecondsToFormattedTime = sec_num => {
  let tostring = num => {
    return `0${num}`.slice(-2);
  };
  let hours = Math.floor(sec_num / 3600);
  let minutes = Math.floor((sec_num % 3600) / 60);
  let seconds = sec_num - minutes * 60 - hours * 3600;
  return `${tostring(hours)}:${tostring(minutes)}:${tostring(
    seconds.toFixed(0)
  )}`;
};

const duration = ms => {
  if (Number(ms) > 0) {
    return millisecondsToFormattedTime(ms / 1000);
  }
};

const thumbnailSrc = (doc, props) => {
  if (doc['section_id_ssim']) {
    return `${props.baseUrl}master_files/${props.doc['section_id_ssim'][0]}/thumbnail`;
  }
};

const SearchResultsCard = props => {
  const { baseUrl, index, doc } = props;
  return (
    <CollectionCardShell>
      <CollectionCardThumbnail>
        <span className="timestamp badge badge-dark">
          {duration(doc['duration_ssi'])}
        </span>
        <a href={baseUrl + 'media_objects/' + doc['id']}>
          {thumbnailSrc(doc, props) && (
            <img
              className="card-img-top img-cover"
              src={thumbnailSrc(doc, props)}
              alt="Card image cap"
            />
          )}
        </a>
      </CollectionCardThumbnail>
      <CollectionCardBody>
        <>
          <h4>
            <a href={baseUrl + 'media_objects/' + doc['id']}>
              {doc['title_tesi'] || doc['id']}
            </a>
          </h4>
          <dl id={'card-body-' + index} className="card-text dl-horizontal">
            <CardMetaData doc={doc} fieldLabel="Date" fieldName="date_ssi" />
            <CardMetaData
              doc={doc}
              fieldLabel="Main Contributors"
              fieldName="creator_ssim"
            />
            <CardMetaData
              doc={doc}
              fieldLabel="Summary"
              fieldName="summary_ssi"
            />
          </dl>
        </>
      </CollectionCardBody>
    </CollectionCardShell>
  );
};

SearchResultsCard.propTypes = {
  baseUrl: PropTypes.string,
  index: PropTypes.number,
  doc: PropTypes.object
};

export default SearchResultsCard;
