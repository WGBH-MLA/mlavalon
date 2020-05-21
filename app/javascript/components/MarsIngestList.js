import React, { Component } from 'react';
import Axios from 'axios';
import PropTypes from 'prop-types';
import MarsIngestTableRow from './MarsIngestTableRow';
import LoadingSpinner from './ui/LoadingSpinner';

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

    return (

      <div className={'mars-ingest-list table-responsive col-md-12'}>

          {isLoading && <LoadingSpinner isLoading={isLoading} />}

          <table className={'table table-condensed'}>
            <thead>
              <tr>
                <th scope='col'>ID</th>
                <th scope='col'>Manifest URL</th>
                <th scope='col'>Error</th>
                <th scope='col'>Item Count</th>
                <th scope='col'>Created</th>
                <th scope='col'></th>
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
                  loading={ isLoading }
                  is_index= { true }
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
