<template>
  <div class="root">
    <div class="container-fluid">
      <div class="row">
        <div class="col">
          <blog-nav />
          <caroucel />
        </div>
      </div>
      <div class="row">
        <div class="col-10 offset-1 col-lg-6 offset-lg-2" v-html="articleHtml"></div>
      </div>
      <div class="row">
        <div class="col-12 d-flex justify-content-center">
          <edit-button @click="editArticle"></edit-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Nav from "@/components/Navbar.vue";
import Caroucel from "@/components/Carousel.vue";

import EditButton from "@/components/EditButton.vue";
import utils from "@/utils/markdownParser";

import api from "@/fetch/article";
export default {
  components: {
    "blog-nav": Nav,
    "caroucel": Caroucel,
    "edit-button": EditButton
  },
  created() {
    this.getArticle();
  },
  computed: {
    articleHtml() {
      return utils.convertMarkdown(this.articleContent);
    },
    articleContent() {
      return this.article.content
        ? this.article.content
        : "article content is empty";
    },
    articleLink() {
      let link = "#";
      if (this.article.id) {
        link = "/admin/edit/" + this.article.id;
      }
      return link;
    }
  },
  data() {
    return {
      article: "",
      articleData: ""
    };
  },
  methods: {
    async editArticle() {
      this.$router.push(this.articleLink);
    },
    async getArticle() {
      let id = parseInt(this.$route.params.id);
      api.getArticle(id).then(res => {
        this.article = res;
      });
    }
  }
};
</script>

<style lang="scss" scoped>

</style>