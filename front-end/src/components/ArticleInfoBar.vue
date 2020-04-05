<template>
  <div class="d-flex justify-content-center">
    <div class="icon w-75 w-lg-50 d-flex justify-content-between align-items-center">
      <!-- date -->
      <div class="d-flex align-items-center">
        <b-icon icon="archive "></b-icon>
        <div class="ml-1">{{createdTime}}</div>
      </div>

      <!-- author -->
      <div class="d-flex align-items-center">
        <b-icon icon="person-fill"></b-icon>
        <div class="ml-1">{{info.author}}</div>
      </div>

      <!-- comment -->
      <div class="d-flex align-items-center">
        <b-icon icon="chat"></b-icon>
        <div class="ml-1">{{info.comments}}</div>
      </div>

      <!-- views -->
      <div class="d-flex align-items-center">
        <b-icon icon="eye-fill"></b-icon>
        <div class="ml-1">{{info.view}}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: ["info"],
  computed: {
    createdTime() {
      let d = "";
      if (this.info && this.info.date) {
        d = new Date(this.info.date);
        d = `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`;
      }
      return d;
    }
  }
};
</script>

<style>
</style>