<template>
  <div class="Home">
    <h1>Space Opera</h1>

    <router-link
      :to="{
        name: 'board',
        params: {
          stage: 1,
        },
      }"
    >
      <button class="Home-button">Free Movement</button>
    </router-link>

    <router-link
      :to="{
        name: 'board',
        params: {
          stage: 2,
        },
      }"
    >
      <button class="Home-button">Match2 Movement</button>
    </router-link>
  </div>
</template>

<script>
export default {
  name: "HomePage",
};
</script>

<style lang="scss" scoped>
.Home {
  &-button {
    padding: 20px;
    border: 5px solid orange;
    border-radius: 50%;
    background-color: red;
    cursor: pointer;
  }
}
</style>
