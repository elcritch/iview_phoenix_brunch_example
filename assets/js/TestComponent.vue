
<template>
  <div>
  <h1>I'm alive!</h1>
    <Slider v-model="value" range></Slider>
    </div>
</template>
<script>
    export default {
        data () {
            return {
                value: [20, 50]
            }
        }
    }
</script>

<style scoped>
  h1 {
    color: "red";
  }
</style>

