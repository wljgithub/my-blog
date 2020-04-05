import async from "./base";
import encrypt from "@/utils/encrypt";

const prefix = "/admin";

export default {
  login(account, password) {
    password = encrypt.md5WithSalt(password);
    return async(
      `${prefix}/login`,
      {
        account: account,
        password: password
      },
      "post"
    );
  },
  logout() {
    return async(`${prefix}/logout`, {}, "post");
  },
  verify() {
    return async(`${prefix}/verify`, {}, "post");
  }
};
