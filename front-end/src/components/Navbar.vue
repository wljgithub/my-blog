<template>
  <b-navbar toggleable="lg" type="dark" variant="primary">
    <b-navbar-brand to="/admin/login">Welcome</b-navbar-brand>

    <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>

    <b-collapse id="nav-collapse" is-nav>
      <b-navbar-nav>
        <b-nav-item to="/">Home</b-nav-item>
        <b-nav-item to="/articleList/recommend">Recommend</b-nav-item>
        <!-- <b-nav-item to="/about">About</b-nav-item> -->
      </b-navbar-nav>

      <!-- Right aligned nav items -->
      <b-navbar-nav class="ml-auto">
        <b-nav-form>
          <b-form-input size="sm" class="mr-sm-2" placeholder="Search"></b-form-input>
          <b-button size="sm" class="my-2 my-sm-0" type="submit">Search</b-button>
        </b-nav-form>

        <!-- <b-nav-item-dropdown text="Lang" right>
          <b-dropdown-item to="#">EN</b-dropdown-item>
          <b-dropdown-item to="#">ES</b-dropdown-item>
          <b-dropdown-item to="#">RU</b-dropdown-item>
          <b-dropdown-item to="#">FA</b-dropdown-item>
        </b-nav-item-dropdown>-->

        <b-nav-item-dropdown right v-if="isAdmin">
          <template v-slot:button-content>
            <em>User</em>
          </template>
          <b-dropdown-item to="#" @click="addPost">Add Post</b-dropdown-item>
          <b-dropdown-item to="#" @click="logout">Sign Out</b-dropdown-item>
        </b-nav-item-dropdown>
      </b-navbar-nav>
    </b-collapse>
  </b-navbar>
</template>

<script>
import token from "@/utils/token";
import api from "@/fetch/login";
export default {
  data() {
    return {
      isAdmin: false
    };
  },
  computed: {},
  created() {
    this.verifyPermission();
  },
  methods: {
    async logout() {
      api
        .logout()
        .then(rsp => {
          console.log(rsp);
          if (rsp.code === 0) {
            token.clearToken();
          }
        })
        .catch(err => console.log(err));
    },
    async addPost() {
      this.$emit("add-post");
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

<style lang="scss" scoped>
// @import "../assets/style/custom.scss";



</style>