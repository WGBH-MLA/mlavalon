import React, { Component } from 'react';
import Axios from 'axios';
import PropTypes from 'prop-types';
// import LoadingSpinner from './ui/LoadingSpinner';
// import MarsIngest from './MarsIngest';

class MarsIngestNew extends Component {
  constructor(props) {
    super(props);
    this.state = {
      manifest_url: null,
      error: null,
      token: props.token
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleClick = this.handleClick.bind(this);
  }

  handleChange(event){
    this.setState({manifest_url: event.target.value});
  }

  handleClick(){
    // AUTHORIZED
    let headers = {
      'Content-Type': 'application/json',
      'X-CSRF-Token': this.state.token
    }

    Axios.post('/mars_ingests', {mars_ingest: {manifest_url: this.state.manifest_url}}, {headers: headers}).then(resp => console.log(resp));
  }

  render() {

    let error;
    if(this.state.error){
      error = this.state.error;
    }

    return (
      <div>

        <div>
          <button data-toggle="modal" data-target="#new_mars_ingest" className="btn btn-primary btn-large">New Mars Ingest
          </button>
        </div>
      
        <div id="new_mars_ingest" class="modal fade" role="dialog" data-backdrop="true">

          <div class="modal-dialog modal-lg">

            <div class="modal-content">
              <div class="modal-header">
                Please enter a URL for your formatted ingest manifest:

                <div>{ error }</div>
                <input placeholder="Manifest URL" onChange={ this.handleChange } type="text" value={ this.state.manifest_url } />
                <button onClick={ this.handleClick }>Submit</button>
              </div>
            </div>
            
          </div>
        </div>
      </div>
      
    );
  }
}

MarsIngestNew.propTypes = {
  token: PropTypes.string,
};

export default MarsIngestNew;
