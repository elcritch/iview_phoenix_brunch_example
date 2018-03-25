
<template>
  <div>
    <h1>I'm alive!</h1>
    <Slider v-model="value" range></Slider>
    <h2>scroller</h2>
    <div class="container">

    </div>
    <h2>scroller</h2>
    <Scroller> </Scroller>
  </div>
</template>

<script>

import Scroller from './Scroller.vue';

    var i = 0;
    var its = Array(1000).fill().map(function (x) { return {itemKey: i++, value: Math.random()}; });

    export default {
        components: { Scroller},
        data () {
            
            return {
                value: [20, 50],
                items: its,
            }
        }
    }
</script>

<style >
  .container {
    max-height: 200px;
  }

  h1 {
    color: red;
  }
</style>

