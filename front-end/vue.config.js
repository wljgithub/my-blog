const CompressionPlugin = require("compression-webpack-plugin");

module.exports = {
  configureWebpack: (config) => {
    if (process.env.NODE_ENV === "development") {
      return {
        plugins: [
          new CompressionPlugin({
            algorithm: "gzip",
            test: /\.(js|css)$/, // patter name
            threshold: 10240, // compress file that sizes large than 10k
            deleteOriginalAssets: true, // delete source
            minRatio: 0.8, // compress ratio
          }),
        ],
      };
    }
  },
};