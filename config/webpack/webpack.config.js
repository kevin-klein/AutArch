// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker');

const customConfig = {
  module: {
    rules: [
      { test: /\.res$/, loader: 'ignore-loader' },
    ]
  }
};

const webpackConfig = generateWebpackConfig(customConfig);

module.exports = webpackConfig;
