import React, { Component } from 'react';
import Axios from 'axios';
import PropTypes from 'prop-types';
import MarsIngestTableRow from './MarsIngestTableRow';
import MarsIngestItemTableRow from './MarsIngestItemTableRow';
import LoadingSpinner from './ui/LoadingSpinner';

class MarsIngest extends Component {
  constructor(props) {
    super(props);
    this.state = {
      searchResult: [],
      sort: 'created_at',
      isLoading: false
    };
  }

  componentDidMount() {
    this.retrieveResults();
  }

  async retrieveResults() {
    this.setState({ isLoading: true });
    let url = this.props.baseUrl;

    try {
      const response = await Axios({ url });
      let data = response.data;

      if(!(data instanceof Array)){
         data = [data];
      };

      this.setState({
        searchResult: data,
        isLoading: false
      });
    } catch (error) {
      console.log('Error in retrieveResults(): ', error);
      Promise.resolve([]);
    }
  }

  render() {
    let mars_ingest_data = this.state.searchResult;
    let isLoading = this.state.isLoading;
    let mars_ingest_items = ( Array.isArray(mars_ingest_data) && mars_ingest_data.length > 0 && Object.keys(mars_ingest_data[0]).includes("mars_ingest_items") ) ? mars_ingest_data[0].mars_ingest_items : []

    return (

      <div className={'mars-ingest-list table-responsive col-md-12'}>
          <table className={'table table-condensed'}>
            <thead>
              <tr>
                <th scope='col'>ID</th>
                <th scope='col'>Manifest URL</th>
                <th scope='col'>Status</th>
                <th scope='col'>Error</th>
                <th scope='col'>Item Count</th>
                <th scope='col'>Created</th>
              </tr>
            </thead>
            <tbody>
              { mars_ingest_data.map((row) => <MarsIngestTableRow
                  key={ row.id }
                  id={ row.id }
                  status={ row.status }
                  error_msg={ row.error_msg }
                  item_count={ row.count }
                  manifest_url={ row.manifest_url }
                  created_at={ row.created_at }
                  loading={ isLoading }
                />
              )}
            </tbody>
          </table>

        {isLoading && <LoadingSpinner isLoading={isLoading} />}

        <div className={"page-title-wrapper"}>
          <h1 className={"page-title"}>Mars Ingest Items</h1>
        </div>

        <table className={'table table-condensed'}>
          <thead>
            <tr>
              <th scope='col'>ID</th>
              <th scope='col'>Created</th>
              <th scope='col'>Error</th>
              <th scope='col'>Status</th>
            </tr>
          </thead>
          <tbody>
            { mars_ingest_items.length > 0 && mars_ingest_items.map((row) => <MarsIngestItemTableRow
                key={ row.id }
                id={ row.id }
                created_at={ row.created_at }
                error_msg={ row.error_msg }
                status={ row.status }
              />
            )}
          </tbody>
        </table>
      </div>

    );
  }
}

MarsIngest.propTypes = {
  baseUrl: PropTypes.string,
};

export default MarsIngest;
