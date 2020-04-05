<template>
  <div>
    <div class="container">
      <div class="row height d-flex justify-content-center align-items-center">
        <div class="col-md-7 col-lg-6 col-xl-5">
          <b-card>
            <b-form @submit="onSubmit" @reset="onReset" v-show="show">
              <b-form-group label="Account" label-for="account">
                <b-form-input
                  id="account"
                  v-model="form.account"
                  required
                  placeholder="Enter Account"
                ></b-form-input>
              </b-form-group>
              <b-form-group label="Password" label-for="password">
                <b-input
                  type="password"
                  id="password"
                  aria-describedby="password-help-block"
                  required
                  placeholder="Enter Password"
                  v-model="form.password"
                ></b-input>
              </b-form-group>
              <div v-if="err.msg" class="text-danger text-center">{{err.msg}}</div>
              <div class="mt-4 d-flex justify-content-end">
                <b-button type="reset" variant="secondary">Reset</b-button>
                <b-button class="ml-2" type="submit" variant="secondary">Submit</b-button>
              </div>
            </b-form>
          </b-card>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from "@/fetch/login";
import token from "@/utils/token";
export default {
  data() {
    return {
      show: true,
      err: {
        msg: ""
      },
      form: {
        account: "",
        password: ""
      }
    };
  },
  created() {
  },
  methods: {
    onSubmit(evt) {
      evt.preventDefault();
      //   alert(JSON.stringify(this.form));
      api
        .login(this.form.account, this.form.password)
        .then(res => {
          if (res.code == 0) {
            this.errMsg = "";
            token.setToken(res.token);
            this.$router.push("/");
          } else {
            this.err.msg = res.msg ? res.msg : "something wrong";
          }
        })
        .catch((res) => {
          this.err.msg = res.msg ? res.msg : "something wrong";
        });
    },
    onReset(evt) {
      evt.preventDefault();
      // Reset our form values
      this.form = {};
      // Trick to reset/clear native browser form validation state
      this.show = false;
      this.$nextTick(() => {
        this.show = true;
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../../assets/style/custom.scss";



.height {
  min-height: 100vh;
}
</style>