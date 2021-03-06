import axios from "axios";
import token from "@/utils/token";

const prefix = "/api";
if (process.env.VUE_APP_PROJECT_ENV != "production") {
  axios.defaults.baseURL = process.env.VUE_APP_LOCAL_API_URL;
}
axios.defaults.timeout = 30000;
axios.interceptors.request.use(
  function(config) {
    // carried token if exist in local storage
    if (token.checkToken()) {
      config.headers[token.tokenName] = token.getToken();
    }
    return config;
  },
  function(error) {
    return Promise.reject(error);
  }
);

export default (url = "", params = {}, method = "get") => {

  method = method.toLowerCase();
  let headers = {};

  url = `${prefix}${url}`;
  const options = {
    method: method,
    headers: headers,
    data: params,
    url
  };
  return new Promise((resolve, reject) => {
    axios(options)
      .then(res => {
        resolve(res.data);
      })
      .catch(err => reject(err.data));
  });
};
