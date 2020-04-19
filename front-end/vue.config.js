const CompressionPlugin = require("compression-webpack-plugin");
const BundleAnalyzerPlugin = require("webpack-bundle-analyzer")
  .BundleAnalyzerPlugin;
// const HtmlWebpackExternalsPlugin = require("html-webpack-externals-plugin");

module.exports = {
  configureWebpack: (config) => {
    // let remoteBundles = new HtmlWebpackExternalsPlugin({
    //   externals: [
    // {
    //   module: "vue",
    //   entry: "https://unpkg.com/vue@latest/dist/vue.min.js",
    //   global: "Vue",
    // },
    // {
    //   module: "bootstrap-vue",
    //   entry:
    //     "https://unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.min.js",
    //   global: "BootstrapVue",
    // },
    // {
    //   module: "bootstrap-vue-icons",
    //   entry:
    //     "https://unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue-icons.min.js",
    //   global: "BootstrapVueIcons",
    // },
    // {
    //   module: "bootstrap.css",
    //   entry: "https://unpkg.com/bootstrap/dist/css/bootstrap.min.css",
    // },
    // {
    //   module: "bootstrap-vue.css",
    //   entry:
    //     "https://unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.min.css",
    // },
    // ],
    // });
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
      };
    } else if (process.env.VUE_APP_PROJECT_ENV === "test") {
      return {
        plugins: [new BundleAnalyzerPlugin(), remoteBundles],
      };
    } else {
      return {
        plugins: [],
      };
    }
  },
};
