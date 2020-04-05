import async from "./base";

const prefix = "/admin";

export default {
  addTag(tag) {
    return async(`${prefix}/addTag`, { tag: tag }, "post");
  },
  addCategory(category) {
    return async(`${prefix}/addCategory`, { category: category }, "post");
  },
  linkTag(articleId, tagId) {
    return async(
      `${prefix}/linkTag`,
      {
        post_id: articleId,
        tag_id: tagId
      },
      "post"
    );
  },
  linkCategory(articleId, categoryId) {
    return async(
      `${prefix}/linkCategory`,
      {
        post_id: articleId,
        category_id: categoryId
      },
      "post"
    );
  }
};
