import MD5 from "crypto-js/md5";

const salt = process.env.VUE_APP_SALT;
export default {
  md5WithSalt(password) {
    return MD5(password + salt).toString();
  }
};
