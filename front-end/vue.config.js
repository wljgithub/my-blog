const CompressionPlugin = require("compression-webpack-plugin");
const BundleAnalyzerPlugin = require("webpack-bundle-analyzer")
  .BundleAnalyzerPlugin;
// const HtmlWebpackExternalsPlugin = require("html-webpack-externals-plugin");

module.exports = {
  configureWebpack: (config) => {
    let optimization = {
      splitChunks: {
        minSize: 10000,
        maxSize: 250000,
      },
    };
    if (process.env.VUE_APP_PROJECT_ENV === "production") {
      return {
        plugins: [
          new CompressionPlugin({
            algorithm: "gzip",
            test: /\.(js|css)$/, // patter name
            threshold: 10240, // compress file that sizes large than 10k
            deleteOriginalAssets: false, // delete source
            minRatio: 0.8, // compress ratio
          }),
        ],
        optimization: optimization,
      };
    } else if (process.env.VUE_APP_PROJECT_ENV === "test") {
      return {
        plugins: [new BundleAnalyzerPlugin()],
        optimization: optimization,
      };
    } else {
      return {
        plugins: [],
      };
    }
  },
};
