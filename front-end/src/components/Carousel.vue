<template>
  <div class="mb-5">
    <b-carousel
      id="carousel-1"
      v-model="slide"
      :interval="4000"
      controls
      indicators
      background="#ababab"
      img-width="1024"
      img-height="400gggg"
      style="text-shadow: 1px 1px 2px #333;"
      @sliding-start="onSlideStart"
      @sliding-end="onSlideEnd"
    >
      <b-carousel-slide
        v-for="(value,index) in imageList"
        :key="index"
        :caption="value.caption"
        :text="value.text"
        :img-src="'https://picsum.photos/1024/400/?image='+value.id"
        style="text-shadow: 1px 1px 2px #333;"
      ></b-carousel-slide>
    </b-carousel>
  </div>
</template>

<script>
export default {
  data() {
    return {
      slide: 0,
      sliding: null,
      imageList: [
        { id: 20, caption: "hello", text: "hello,world" },
        { id: 30, caption: "hello", text: "hello,world" },
        { id: 6, caption: "hello", text: "hello,world" }
      ]
    };
  },
  computed: {},
  methods: {
    onSlideStart() {
      this.sliding = true;
    },
    onSlideEnd() {
      this.sliding = false;
    }
  },
  imageLink(id) {
    (id);
    return `https://picsum.photos/1024/400/?image=${5}`;
  }
};
</script>

<style>
</style>