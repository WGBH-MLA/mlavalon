import React, { Component } from 'react';
import Axios from 'axios';
import PropTypes from 'prop-types';
import LoadingSpinner from './ui/LoadingSpinner';
import MarsIngest from './MarsIngest';

class MarsIngestList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      searchResult: [],
      sort: 'created_at',
      isLoading: false
    };
  }

  componentDidMount() {
    console.log('Mounted dat')
    this.retrieveResults();
  }

  async retrieveResults() {
    this.setState({ isLoading: true });
    let url = this.props.baseUrl;

    console.log('Retrieved dat')

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

    return (
      <div className={'mars-ingest-list table-responsive'}>

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
            {isLoading && <LoadingSpinner isLoading={isLoading} />}

            { mars_ingest_data.map((row) => <MarsIngest
                key={ row.id }
                id={ row.id }
                status={ row.status }
                error_msg={ row.error_msg }
                item_count={ row.count }
                manifest_url={ row.manifest_url }
                created_at={ row.created_at }
              />
            )}
          </tbody>
        </table>
      </div>
    );
  }
}

MarsIngestList.propTypes = {
  baseUrl: PropTypes.string,
};

export default MarsIngestList;
