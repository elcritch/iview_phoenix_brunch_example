<template>
  <div>
    <!-- UI controls that can are used to manipulate the display of the chart -->
    
    <Card class="controls">
      
      <div>
	      <label>Chart width</label>
  	    <Slider v-model="settings.width.value" :min="settings.width.min" :max="settings.width.max"></Slider>
      </div>
     
      <div>
        <label>Stroke color</label>
	      <input type="color" v-model="settings.strokeColor" />
      </div>
      
      <div>
	      <label>Search…</label>
  	    <input type="text" v-model="search" />
			</div>
      
      <button v-on:click="add">widthPos: {{widthPos}}</button> <br>
      <button v-on:click="add">currPos: {{currPos}}</button> <br>
      <button v-on:click="add">currSlice: {{currSlice}}</button> <br>
      <button v-on:click="add">this.bars2.length: {{this.bars2.length}}</button> <br>
       
      <div> Selected: {{ selected }} </div>
    </Card>

    <!-- SVG that renders the chart based on the "width" and "height" setting from the Vue instance’s data object -->
    
    <div
          v-on:wheel.prevent="move($event)" 
      >

      <svg width="100%" height="50vh"
          v-bind:viewBox="`${settings.width.value} 0 ${settings.width.view} 50`" preserveAspectRatio="none">

        <rect x="0" y="0" width="1000" height="50" style="stroke: #000000; fill: none" ></rect>

        <transition-group  tag="g" name="list">

          <!-- <g  
              v-for="(node, index) in currBars" 
              v-bind:key="index"> -->

          <line 
            v-for="(node, index) in currBars"
            v-bind:key="node.x + node.y / 1000.0"
            v-bind:x1="node.x "
            v-bind:x2="node.x + 10.1"
            v-bind:y1="node.y"
            v-bind:y2="node.y"
            v-bind:stroke-width="node.z + 0.5"
            stroke="grey"
            stroke-linecap="round"
            >
          </line>

          <!-- </g> -->
        </transition-group>
      </svg>
    </div>

      <div>
	      Test: {{ tests }}
      </div>
  </div>

</template>

<script>
function rand(min, max) {
  return Math.round(Math.random() * (max - min) + min);
}

function idx(min) {
  let i = min;
  function idxer() {return i++; };
  return idxer;
}

export default {
    
    data: function() {
        return {
            csv: null,
            selected: null,
            search: "force",
            settings: {
                strokeColor: "#19B5FF",
                width: {
                    value: 0,
                    min: 0,
                    max: 800,
                    view: 250,
                },
                height: 600
            },
            bars: [
                {y: 10, x: 100, z: 0},
                {y: 10, x: 200, z: 1},
                {y: 10, x: 300, z: 1},
                {y: 10, x: 400, z: 0},
                {y: 10, x: 500, z: 0},
                
                {y: 30, x: 100, z: 0},
                {y: 30, x: 200, z: 0},
                {y: 30, x: 300, z: 1},
                {y: 30, x: 400, z: 1},
                {y: 30, x: 500, z: 0},
            ],
            bars2: Array.concat(
                Array(1000).fill(0).map(idx(0)).map( (i) => { return { x: 10.0*i, y: 10, z: rand(0,1) } }),
                Array(1000).fill(0).map(idx(0)).map( (i) => { return { x: 10.0*i, y: 20, z: rand(0,1) } }),
                Array(1000).fill(0).map(idx(0)).map( (i) => { return { x: 10.0*i, y: 30, z: rand(0,1) } }),
            ).sort( (i, j) => { return i.x - j.x } ),
        };
    },
    mounted: function() {
        var that = this;
        
        d3.csv("flare.csv").then(
            function(data) {
                
         	      // Load the CSV data
	              // After the CSV has been loaded, the computed properties will automatically re-compute (root, tree, and then nodes & links…)
                
                that.csv = data;
            }
        ).catch(function(error) { throw error;});
        
        console.log("bars2: ", JSON.stringify(this.bars2));
    },
    
    computed: {
        
        widthFactor: function() { return 3; },
        widthLen: function() { return Math.round( this.bars2.length / this.widthFactor ); },
        widthPos: function() { return Math.round( (this.settings.width.value / this.settings.width.max) * this.widthLen ); },
        
        currPos: function () { return [ this.settings.width.value - 125, this.settings.width.value + 250 + 125 ]; }, 
        
        currSlice: function() {
            
            let viewCorrect = 100.0;

            // let [x1, x2] = this.currPos;
            let vw = this.widthFactor*this.settings.width.view

            let wp = this.widthPos * this.widthFactor / viewCorrect ;
            
            return [ Math.round(Math.max(wp - vw, 0)), Math.round(Math.min(wp + vw, this.bars2.length)) ];
            // console.log(`x1,x2: ${x1}, ${x2}`);
            // return this.bars2.filter( i => x1 <= i.x && i.x <= x2 );
        },
        
        currBars: function() {
            
            return this.bars2.slice( ...this.currSlice );

            // console.log(`x1,x2: ${x1}, ${x2}`);
            // return this.bars2.filter( i => x1 <= i.x && i.x <= x2 );
        },
        // once we have the CSV loaded, the "root" will be calculated
        
    },
    methods: {
        /**
 * Returns a random number between min (inclusive) and max (exclusive)
 */

      move: function ({deltaY: dY, deltaX: dX}) {
        // console.log("move: ", dY, dX);
        let dL = Math.min(dY, 10);

          this.settings.width.value += dL;

      },
			add: function () {
       this.csv.push({
         id: "flare.physics.Dummy",
         value: 0
       })
      },
      select: function(index, node) {
        this.selected = index;
      }
    }
  }
</script>

<style >
     body {
      width: 100%;
      height: 100%;
      font-family: monospace;
     }
    
    .node {
    	opacity: 1;
    }

    .node circle {
      fill: #999;
      cursor: pointer;
    }

    .node text {
      font: 10px sans-serif;
      cursor: pointer;
    }

    .node--internal circle {
      fill: #555;
    }

    .node--internal text {
      text-shadow: 0 1px 0 #fff, 0 -1px 0 #fff, 1px 0 0 #fff, -1px 0 0 #fff;
    }

    .link {
      fill: none;
      stroke: #555;
      stroke-opacity: 0.4;
      stroke-width: 1.5px;
      stroke-dasharray: 1000;
    }

    .node:hover {
      pointer-events: all;
      stroke: #ff0000;
    }

    .node.highlight {
      fill: red;
    }
    
    /* .controls { */
    /*   position: fixed; */
    /*   top: 16px;  */
    /*   left: 16px; */
    /*   background: #f8f8f8; */
    /*   padding: 0.5rem; */
    /*   display: flex; */
    /*   flex-direction: column; */
    /* } */
    
    /* .controls > * + * { */
    /*   margin-top: 1rem; */
    /* } */
    
    label {
      display: block;
    }
    
    /* .list-enter-active, .list-leave-active { */
    /*   transition: all 0.2s; */
    /* } */
    /* .list-enter, .list-leave-to /\* .list-leave-active for <2.1.8 *\/ { */
    /*   opacity: 0; */
    /*   /\* transform: translateY(30px); *\/ */
    /* } */
    
    /* .line-enter-active, .line-leave-active { */
    /*   transition: all 0.2s; */
    /*   stroke-dashoffset: 0; */
    /* } */
    /* .line-enter, .line-leave-to /\* .list-leave-active for <2.1.8 *\/ { */
    /*   stroke-dashoffset: 1000; */
    /* } */
</style>
