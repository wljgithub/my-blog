import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import "./assets/style/custom.scss"

import { BootstrapVue, BootstrapVueIcons } from 'bootstrap-vue'
// import BootstrapVue from "bootstrap-vue";
// import BootstrapVueIcons from "bootstrap-vue-icons";

Vue.use(BootstrapVue);
Vue.use(BootstrapVueIcons);
Vue.config.productionTip = false;

new Vue({
  router,
  render: (h) => h(App),
}).$mount("#app");
