<template>
  <div class="container-fluid">
    <div class="row d-flex justify-content-center bg-light">
      <b-nav class="d-flex justify-content-between align-items-center w-75">
        <b-nav-item>
          <h3>
            <router-link to="/">Home</router-link>
          </h3>
        </b-nav-item>
        <b-dropdown id="dropdown-right" text="Post It As" variant="success" class="m-2">
          <b-dropdown-item-button @click="editArticle">Post</b-dropdown-item-button>
          <b-dropdown-item-button>Draft</b-dropdown-item-button>
        </b-dropdown>
      </b-nav>
      <div class="col-12 d-flex justify-content-center">
        <b-form-input
          class="w-75"
          v-model="article.title"
          placeholder="Enter Title"
        >{{article.title}}</b-form-input>
      </div>
      <div class="col-10 offset-1 my-2">
        <tag-panel
          @link="linkCategory"
          @send="addCategories"
          name="selectCategories"
          :tags="categories"
        ></tag-panel>
        <tag-panel @link="linkTag" @send="addTags" name="addTags" :tags="tags"></tag-panel>
      </div>
    </div>
    <div class="row d-flex justify-content-center">
      <div class="col offset-1">
        <b-form-textarea id="textarea-plaintext" :rows="textRows" v-model="article.content"></b-form-textarea>
      </div>
      <div class="col">
        <div v-html="markdownPreview"></div>
      </div>
    </div>
  </div>
</template>

<script>
import TagPanel from "@/components/TagPanel.vue";
import utils from "@/utils/markdownParser";
import art from "@/fetch/article";
import api from "@/fetch/index";
import admin from "@/fetch/admin";
import hint from "@/utils/hint";

export default {
  watch: {},
  computed: {
    markdown() {
      return this.article.content;
    },
    markdownPreview() {
      return utils.convertMarkdown(this.markdown);
    },
    textRows() {
      let rows = 20;
      if (this.article.content) {
        rows += this.article.content.split("\n").length;
      }

      return rows;
    }
  },

  created() {
    let id = parseInt(this.$route.params.id);
    art.getArticle(id).then(res => {
      this.article = res;
    });
    api.getTag().then(res => {
      this.tags = res.content;
    });
    api.getCategory().then(res => {
      this.categories = res.content;
    });
  },
  data() {
    return {
      article: {},
      tags: [],
      categories: []
    };
  },
  methods: {
    editArticle() {
      // hint.toast("succeed", this, { contextualStyle: "danger" });
      art
        .editArticle(this.article)
        .then(res => {
          console.log(res);
          if (res.code === 0) {
            this.$router.push(`/article/${res.article_id}`);
            hint.toast(res.msg, this, { contextualStyle: "success" });
          } else {
            hint.toast(res.msg, this, { contextualStyle: "danger" });
          }
        })
        .catch(err => {
          hint.toast(err, this, { contextualStyle: "danger" });
        });
    },
    addTags(para) {
      admin
        .addTag(para)
        .then(res => {
          if (res.code === 0) {
            this.tags.push(res.tag);
            hint.toast(res.msg, this, { contextualStyle: "success" });
          } else {
            hint.toast(res.msg, this, { contextualStyle: "danger" });
          }
        })
        .catch(err => {
          hint.toast(err.msg, this, { contextualStyle: "danger" });
        });
    },
    addCategories(para) {
      console.log("add", para);
      admin
        .addCategory(para)
        .then(res => {
          if (res.code === 0) {
            this.categories.push(res.category);
            hint.toast(res.msg, this, { contextualStyle: "info" });
          } else {
            hint.toast(res.msg, this, { contextualStyle: "danger" });
          }
        })
        .catch(err => {
          hint.toast(err, this, { contextualStyle: "danger" });
        });
    },
    linkTag(tag) {
      admin
        .linkTag(this.article.id, tag.id)
        .then(res => {
          console.log(res);
          if (res.code === 0) {
            hint.toast(res.msg, this);
          } else {
            hint.toast(res.msg, this, { contextualStyle: "danger" });
          }
        })
        .catch(err => {
          let msg = err && err.msg ? err.msg : "failed";
          hint.toast(msg, this, { contextualStyle: "danger" });
        });
    },
    linkCategory(category) {
      this.article.category_id = category.id;
      hint.toast("success", this, { contextualStyle: "info" });
    }
  },
  components: {
    "tag-panel": TagPanel
  }
};
</script>

<style  scoped>
</style>