export default {
  tokenName:process.env.VUE_APP_BLOG_TOKEN,
  getToken() {
    return localStorage.getItem(this.tokenName);
  },
  setToken(token) {
    if (token) {
      localStorage.setItem(this.tokenName, `${token.key}&${token.value}`);
    }
  },
  clearToken() {
    localStorage.removeItem(this.tokenName);
  },
  checkToken() {
    return this.getToken() ? true : false;
  }
};
