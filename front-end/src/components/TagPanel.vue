<template>
  <b-dropdown :text="buttonName" ref="dropdown" class="m-2">
    <b-dropdown-form id="dropdown-form">
      <b-form-group class="d-flex">
        <div class="d-flex">
          <b-form-input size="sm" v-model="input" placeholder="Enter Name"></b-form-input>
          <b-button class="ml-2" variant="primary" size="sm" @click="addTag">add</b-button>
        </div>
      </b-form-group>

      <b-form-group :label="name">
        <b-button
          v-for="(tag,index) in tags"
          variant="primary"
          class="m-2"
          size="sm"
          @click="linkTag(tag)"
          :key="index"
        >{{tag.name}}</b-button>
      </b-form-group>
    </b-dropdown-form>
    <b-dropdown-divider></b-dropdown-divider>
  </b-dropdown>
</template>

<script>
export default {
  props: ["tags", "name"],
  computed: {
    buttonName() {
      return this.name;
    }
  },
  data() {
    return {
      input: ""
    };
  },
  methods: {
    linkTag(tag) {
      this.$emit("link", tag);
      this.$refs.dropdown.hide(true);
    },
    addTag() {
      this.$emit("send", this.input);
      this.$refs.dropdown.hide(true);
    }
  }
};
</script>

<style lang="scss" scoped>
// @import "../assets/style/custom.scss";



#dropdown-form {
  min-width: 300px;
}
</style>