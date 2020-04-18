<template>
  <b-card
    :title="article.title"
    img-src="https://picsum.photos/600/300/?image=25"
    img-alt="Image"
    img-top
    tag="article"
    class="mb-4"
  >
    <template v-slot:footer class="bg-success">
      <info-bar :info="article.info" />
    </template>

    <b-card-text v-html="articleHtml"></b-card-text>

    <b-button :to="'/article/'+article.id" variant="secondary">Read More</b-button>
  </b-card>
</template>

<script>
import Infobar from "@/components/ArticleInfoBar.vue";
import utils from "@/utils/markdownParser";

export default {
  props: ["article"],
  components: {
    "info-bar": Infobar
  },
  computed: {
    articleHtml() {
      return utils.convertMarkdown(this.article.content) + "  ......";
    }
  }
};
</script>

<style lang="scss" scoped>
// @import "../assets/style/custom.scss";


</style>