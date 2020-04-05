<template>
  <div class="root">
    <div class="container-fluid">
      <div class="row">
        <div class="col">
          <blog-nav @add-post="addPost" />
          <carousel />
        </div>
      </div>
      <div class="row">
        <div class="col-10 offset-1 col-lg-6 offset-lg-2">
          <article-list v-for="(article,index) in articles" :key="index" :article="article" />
          <div class="row d-flex justify-content-center overflow-auto">
            <b-pagination-nav
              :number-of-pages="pageNo"
              :link-gen="linkGen"
              variant="secondary"
              use-router
            ></b-pagination-nav>
          </div>
        </div>
        <div class="d-none d-lg-block col-lg-3 offset-lg-1 max-w min-w">
          <article-nav
            v-if="showCategory"
            route="/articleList/category/"
            :title="categories.title"
            :content="categories.content"
          />
          <article-nav
            v-if="showTag"
            route="/articleList/tag/"
            :title="tags.title"
            :content="tags.content"
          />
          <article-nav
            v-if="showArchive"
            route="/articleList/archive/"
            :title="archives.title"
            :content="archives.content"
          />
        </div>
      </div>
    </div>
  </div>
  <!-- </div> -->
</template>

<script>
import Nav from "@/components/Navbar.vue";
// import Motto from "@/components/Motto.vue";
import Caroucel from "@/components/Carousel.vue";
import ArticleNav from "@/components/ArticleNav.vue";
import ArticleList from "@/components/ArticleList.vue";
import api from "@/fetch/index";
export default {
  name: "Home",
  components: {
    "blog-nav": Nav,
    // motto: Motto,
    carousel: Caroucel,
    "article-nav": ArticleNav,
    "article-list": ArticleList
  },
  created() {
    this.getArticleList(this.pageLink);
    this.getTag();
    this.getCategory();
    this.getArchive();
  },
  data() {
    return {
      articles: [],
      tags: {},
      archives: {},
      categories: {},
      totalArticle: 2,
      offset: 0,
      limit: 5
    };
  },
  watch: {
    routerWatch: function() {
      if (this.$route.query.page > 0) {
        this.offset = (this.$route.query.page - 1) * this.limit;
        this.getArticleList(this.pageLink, this.offset);
      } else {
        this.offset = 0;
        this.getArticleList(this.pageLink);
      }
    }
  },
  computed: {
    pageLink() {
      let articleType = {
        category: this.$route.params.category,
        id: parseInt(this.$route.params.id)
      };
      return articleType;
    },
    routerWatch() {
      return this.$route.params;
    },
    pageNo() {
      let num = Math.round(this.totalArticle / this.limit);
      return num > 2 ? num : 2;
    },
    showCategory() {
      return Object.keys(this.categories).length > 0 ? true : false;
    },
    showArchive() {
      return Object.keys(this.archives).length > 0 ? true : false;
    },
    showTag() {
      return Object.keys(this.tags).length > 0 ? true : false;
    }
  },

  methods: {
    async addPost() {
      this.$router.push("/admin/edit");
    },
    async getArticleList(articleType) {
      api.getArticleList(articleType, this.offset, this.limit).then(rsp => {
        rsp.posts.forEach(ele => {
          ele.info = {
            view: ele.view,
            // author: ele.author,
            comments: 0,
            author: "jack",
            date: ele.date,
            id: ele.id
          };
        });
        if (rsp) {
          this.articles = rsp.posts;
          this.totalArticle = rsp.total_amount;
        }
      });
    },
    async getTag() {
      api.getTag().then(rsp => {
        this.tags = rsp;
      });
    },
    async getCategory() {
      api.getCategory().then(rsp => {
        this.categories = rsp;
      });
    },
    async getArchive() {
      api.getArchive().then(rsp => {
        this.archives = rsp;
      });
    },
    linkGen(pageNum) {
      return pageNum === 1 ? "?" : `?page=${pageNum}`;
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../assets/style/custom.scss";



.max-w {
  max-width: 300px;
}
.min-w {
  min-width: 200px;
}
</style>