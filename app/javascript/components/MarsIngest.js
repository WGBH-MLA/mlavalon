import React, { Component } from 'react';
import Axios from 'axios';
import PropTypes from 'prop-types';
import MarsIngestTableRow from './MarsIngestTableRow';
import MarsIngestItemTableRow from './MarsIngestItemTableRow';

class MarsIngest extends Component {
  constructor(props) {
    super(props);
    this.state = {
      searchResult: [],
    };
  }

  componentDidMount() {
    this.retrieveResults();
    this.timer = setInterval(()=> this.retrieveResults(), 10000);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
    this.timer = null;
  }

  async retrieveResults() {
    let url = this.props.baseUrl;

    try {
      const response = await Axios({ url });
      let data = response.data;

      if(!(data instanceof Array)){
         data = [data];
      };

      this.setState({
        searchResult: data,
      });
    } catch (error) {
      console.log('Error in retrieveResults(): ', error);
      Promise.resolve([]);
    }
  }

  render() {

    function resultsComplete(_that, statuses) {
      if ( !statuses.includes("processing") || !statuses.includes("enqueued") ){
        clearInterval(_that.timer);
        _that.timer = null;
      }
    };

    let mars_ingest_data = this.state.searchResult;
    let mars_ingest_items = ( Array.isArray(mars_ingest_data) && mars_ingest_data.length > 0 && Object.keys(mars_ingest_data[0]).includes("mars_ingest_items") ) ? mars_ingest_data[0].mars_ingest_items : [];
    let ingest_items_status = mars_ingest_items.map(item => { return item.status } );
    resultsComplete(this, ingest_items_status);

    return (

      <div className={'mars-ingest-list table-responsive col-md-12'}>
          <table className={'table table-condensed'}>
            <thead>
              <tr>
                <th scope='col'>ID</th>
                <th scope='col'>Manifest URL</th>
                <th scope='col'>Error</th>
                <th scope='col'>Item Count</th>
                <th scope='col'>Created</th>
              </tr>
            </thead>
            <tbody>
              { mars_ingest_data.map((row) => <MarsIngestTableRow
                  key={ row.id }
                  id={ row.id }
                  error_msg={ row.error_msg }
                  item_count={ row.item_count }
                  manifest_url={ row.manifest_url }
                  created_at={ row.created_at }
                  is_index={ false }
                />
              )}
            </tbody>
          </table>

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
                error={ row.error }
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
