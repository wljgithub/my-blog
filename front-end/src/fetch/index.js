import async from "./base";

export default {
  getTag() {
    return async(`/getTag`);
  },
  getArchive() {
    return async(`/getArchive`);
  },
  getCategory() {
    return async(`/getCategory`);
  },
  getArticleList(category, offset = 0, limit = 5) {
    let para = {
      category: category.category,
      id: category.id,
      offset: offset,
      limit: limit
    };
    return async(`/getArticleList`, para, "post");
  }
};
