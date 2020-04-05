import async from "./base";

const prefix = "/admin";
export default {
  getArticle(id) {
    return async(`/getArticle?id=${id}`);
  },
  editArticle(article) {
    return async(`${prefix}/addPost`, article, "post");
  }
};
