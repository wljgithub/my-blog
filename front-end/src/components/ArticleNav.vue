<template>
  <div class="mb-4">
    <!-- <p v-for="(value,index) in content" :key="index">{{value}}</p> -->
    <b-card :header="title">
      <b-list-group-item
        v-for="(value,index) in content"
        :key="index"
        class="d-flex justify-content-between align-items-center"
        :to="route+value.id"
      >
        {{value.name}}
        <b-badge variant="primary" pill>{{value.amount}}</b-badge>
      </b-list-group-item>
    </b-card>
  </div>
</template>

<script>
export default {
  props: ["title", "content", "amount", "route"]
};
</script>

<style lang="scss" scoped>
@import "../assets/style/custom.scss";



</style>