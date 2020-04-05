<template>
  <section class="menu">
    <div class="logo">
      <img src="../assets/logo.png" />
    </div>
    <ul class="menu-list">
      <li class="menu-item">
        <router-link to="/">Main</router-link>
      </li>
      <li class="menu-item">
        <router-link to="/postList">Post List</router-link>
      </li>
      <li class="menu-item">
        <router-link to="/edit">Edit</router-link>
      </li>
      <li class="menu-item">
        <router-link to="/category">Category</router-link>
      </li>
      <li class="menu-item">
        <router-link to="/tag">Tag</router-link>
      </li>
    </ul>
  </section>
</template>

<script>
export default {};
</script>

<style scoped>

*{
    padding:0;
    margin:0;
}
.menu{
    position: sticky;
    top:0;
    left: 0;
    background-color: #495060;
    max-width:8rem;
    height: 100rem;    
    display: flex;
    flex-direction: column;
    align-items: center;    

}
.logo{
    margin-top:1rem;
    max-width:100px;
    max-height:auto;
}
.logo img{
    /* background-color: red; */
    height: auto;
    max-width: 100%;
    margin-bottom: 1rem
}

.menu-item{
    list-style-type: none;
    display:block;
    margin: auto;
    /* background-color: blue; */
    
}
a:focus{background-color: #2d8cf0;}
a{
    display: inline-block;
    text-decoration:none;
    color:#fff;
    width: 6rem;
    padding:1rem;

}

</style>