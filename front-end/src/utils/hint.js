export default {
  toast(
    content,
    that,
    {
      title = "hint",
      position = "b-toaster-top-center",
      contextualStyle = "primary",
      append = false
    } = {}
  ) {
    that.$bvToast.toast(`${content}`, {
      title: `${title}`,
      toaster: position,
      variant: contextualStyle,
      solid: true,
      appendToast: append
    });
  },
  myAlert(para) {
    alert(para);
  }
};
