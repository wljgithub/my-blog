import Vue from "vue";
import VueRouter from "vue-router";
import Login from "../views/admin/Login.vue";
import Index from "../views/Index.vue";
import EditArticle from "../views/admin/EditArticle.vue";
import Article from "../views/Article.vue";
Vue.use(VueRouter);

const routes = [
  {
    path: "/",
    name: "Index",
    component: Index
  },

  { path: "/article/:id", component: Article },
  { path: "/articleList/:category", component: Index },
  { path: "/articleList/:category/:id", component: Index },

  {
    path: "/admin/login",
    name: "Login",
    component: Login
  },
  { path: "/admin/edit", component: EditArticle },

  { path: "/admin/edit/:id", component: EditArticle },

  {
    path: "/about",
    name: "About",
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () =>
      import(/* webpackChunkName: "about" */ "../views/About.vue")
  }
];

const router = new VueRouter({
  mode: "history",
  base: process.env.BASE_URL,
  routes
});

export default router;
