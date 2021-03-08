function myAlert() {
    const domContainer = document.querySelector('#root');
    ReactDOM.render(e(LikeButton), domContainer); 
}

'use strict';

const e = React.createElement;

class LikeButton extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {

    return e(
      'div',
      {},
      'Hey I was created from React!'
    );
  }
}

