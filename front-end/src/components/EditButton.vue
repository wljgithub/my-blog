<template>
  <!-- pencil-square -->
  <div class="h2 mt-5" v-if="isAdmin">
    <b-button variant="outline-info" class="d-flex align-items-center" @click="click">
      <b-icon class="pen-size mr-2" icon="pencil-square" variant="success"></b-icon>Edit
    </b-button>
  </div>
</template>

<script>
import api from "@/fetch/login";

export default {
  data() {
    return {
      isAdmin: false
    };
  },
  created() {
    this.verifyPermission();
  },
  methods: {
    click() {
      this.$emit("click");
    },
    async verifyPermission() {
      api.verify().then(res => {
        if (res.code === 0) {
          this.isAdmin = true;
        }
      });
    }
  }
};
</script>
<style lang="scss">
.pen-size {
  width: 2rem;
  height: 2rem;
}
</style>