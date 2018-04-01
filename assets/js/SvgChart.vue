<template>
  <div>
    <!-- UI controls that can are used to manipulate the display of the chart -->
    
    <Card class="controls">
      
      <div>
	      <label>Graph Postion: {{`${(100*user_view.xpos_frac).toFixed(1)}%`}}</label>
  	    <Slider v-model="user_view.xpos_frac"
                :min="0.0"
                :max="1.0"
                :step="0.000001"
                :tip-format="v => `Position: ${(100*v).toFixed(1)}%`"
              ></Slider>
	      <label>Number Elements Displayed: {{user_view.width_count}}</label>
  	    <Slider v-model="user_view.width_count"
                :min="10"
                :max="1000"
                :step="1"
                :tip-format="v => `Count: ${v}`"
                show-stops
              > </Slider>
      </div>
     
      <div>
        <label>Stroke color</label>
	      <input type="color" v-model="settings.strokeColor" />
      </div>
      
      <div>
	      <label>Search…</label>
  	    <input type="text" v-model="search" />
			</div>
      
      <!-- <pre >port: {{JSON.stringify(port)}}</pre> <br> -->
      <!-- <pre >idxs: {{JSON.stringify(idxs)}}</pre> <br> -->
       
      <div> Selected: {{ selected }} </div>
    </Card>

    <!-- SVG that renders the chart based on the "width" and "height" setting from the Vue instance’s data object -->
    
    <div
          v-on:wheel.prevent="move($event)" 
      >

      <svg width="100%" height="50vh"
          v-bind:viewBox="`${port.x_pos} ${port.y_pos} ${port.x_size} ${port.y_size}`" preserveAspectRatio="none">

        <rect :x="port.x_min - 0.045*port.width"
              :y="port.y_min"
              :width="port.width + 0.085*port.width"
              :height="port.height"
              style="stroke: #000000; fill: none" ></rect>

        <transition-group v-if="this.datum" tag="g" name="list">

          <g  
            v-for="row_idx in data_info.nrows" 
            v-bind:key="row_idx"
            :id="`data_row${row_idx}`"
            >

            <!-- <line  -->
            <!--   v-for="(_idx, i) in idxs.count" -->
            <!--   v-bind:key="(idxs.min + i) + row_idx / 100 " -->
            <!--   :id="(idxs.min + i) + row_idx / 100 " -->
            <!--   v-bind:x1="x_idx_pos(i) " -->
            <!--   v-bind:x2="x_idx_pos(i+1) " -->
            <!--   v-bind:y1="y_idx_pos(row_idx)" -->
            <!--   v-bind:y2="y_idx_pos(row_idx)" -->
            <!--   v-bind:stroke-width="2*elem(row_idx,idxs.min+i) + 1" -->
            <!--   stroke="grey" -->
            <!--   stroke-linecap="round" -->
            <!--   > -->
            <!-- </line> -->


            <rect 
              v-for="(_idx, i) in idxs.count"
              v-bind:key="(idxs.min + i) + row_idx / 100 "
              :id="(idxs.min + i) + row_idx / 100 "
              v-bind:x="x_idx_pos(i) "
              v-bind:width="1.01"
              v-bind:y="y_idx_pos(row_idx) - user_view.signal_height*elem(row_idx,idxs.min+i) "
              v-bind:height="user_view.signal_height*elem(row_idx,idxs.min+i) + 0.5"

              class="data-block"
              >
            </rect>


            <!--
              v-bind:stroke-width="datum[row_idx][idxs.min+i]"
                -->
          </g>
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
            data_info: {
                ncols: 100000,
                nrows: 5,
            },
            user_view: {
                xpos_frac: 0.0,
                width_count: 50,
                signal_height: 3.18,
            },
            settings: {
                strokeColor: "#19B5FF",
            },
        };
    },
    mounted: function() {
        var self = this;
        let nrows = this.data_info.nrows;
        let ncols = this.data_info.ncols;
        
        // datum
        this.datum = Array(nrows).fill(0).
            map((i) => {return new Int8Array(new ArrayBuffer(ncols));});
        
        this.datum.map( (d) => {
            for (var i = 0; i < ncols; i++) {
                d[i] = rand(0,128)
                // d[i] = i % 254
            }
        });
        
        for (var i = 0; i < ncols; i++) {
            this.datum[0][i] = 0xAA;
            // d[i] = i % 254
        }

        console.log("dataum: ", this.datum[0]);
    },
    
    computed: {
        
        port: function() {
            let width = this.data_info.ncols
            let height = 10 * (this.data_info.nrows + 2)
            
            let x_min = 0.0
            let x_size = this.user_view.width_count // * this.data_info.ncols
            let x_pos = ((width - x_size) * this.user_view.xpos_frac).toFixed(3)
            
            let x_delta = this.data_info.ncols*1.0
            
            let y_min = 0.0
            let y_pos = 0.0
            let y_size = height
            
            return {
                width, height, x_size, x_pos, y_size, y_pos, y_min, x_min, x_delta,
            }
        },
        
        idxs: function() {
            let idx_width = Math.ceil(this.port.x_size/2)
            let idx_pos = Math.floor(this.port.x_pos) 
            let idx_max = this.data_info.ncols - 1
            
            let min = Math.max(idx_pos - idx_width, 0)
            let max = Math.min(idx_max, idx_pos + 2*idx_width + 1)
            let count = max - min
            
            return { min, max, count, idx_max}
        },
        
    },
    methods: {
        elem: function(row, col) {
            return (this.datum[row-1][Math.floor(col/8)] >>> (col %8)) & 1;
        },
        x_idx_width: function(idx) {
            return 1;
        },
        x_idx_pos: function(idx) {
            let xpos = this.idxs.min + idx + 1
            return xpos;
        },
        y_idx_pos: function(idx) {
            return 10*idx+5;
        },
        move: function ({deltaY: dY, deltaX: dX}) {
            let xf = this.user_view.xpos_frac
            // let xs = ( 0.8 * this.port.x_size ) - 6
            let xs = Math.log( 3* this.port.x_size ) - 2
            let mv = dY / 10 / this.port.width * xs
            this.user_view.xpos_frac = Math.max(0.0, Math.min(1.0, xf + mv ));
      },
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

label {
    display: block;
}

.data-block {
    fill: #1c2438;
    stroke-linejoin: square;
}

</style>
