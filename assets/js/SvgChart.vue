<template>
  <div>
    <!-- UI controls that can are used to manipulate the display of the chart -->
    
    <Card class="controls">
      
      <div>
	      <label>Graph Postion</label>
  	    <Slider v-model="user_view.xpos_frac"
                :min="0.0"
                :max="1.0"
                :step="0.001"
                :tip-format="v => `Position: ${(100*v).toFixed(1)}%`"
              ></Slider>
	      <label>Graph Zoom</label>
  	    <Slider v-model="user_view.width_frac"
                :min="0.1"
                :max="1.0"
                :step="0.1"
                :tip-format="v => `Zoom: ${(100*v).toFixed(0)}%`"
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
      
      <pre >port: {{JSON.stringify(port, 2)}}</pre> <br>
      <pre >indexes: {{JSON.stringify(indexes, 2)}}</pre> <br>
       
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

        <transition-group  tag="g" name="list">

          <g  
            v-for="row_idx in rows.length" 
            v-bind:key="row_idx"
            :id="`data_row${row_idx}`"
            >

            <line 
              v-for="(i, index) in rows[row_idx]"
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

//  Array(1000).fill(0).map(idx(0)).map( (i) => { return { x: 10.0*i, y: 10, z: rand(0,1) } }),

export default {
    
    data: function() {
        return {
            csv: null,
            selected: null,
            search: "force",
            data_info: {
                ncols: 10,
                nrows: 3,
            },
            user_view: {
                xpos_frac: 0.0,
                width_frac: 0.2,
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
        this.datum = Array(nrows).fill(0)
            .map((i) => {return new Int8Array(new ArrayBuffer(ncols));});
        
        console.log("dataum: ", this.datum[0]);
    },
    
    computed: {
        
        port: function() {
            let width = this.data_info.ncols
            let height = 10 * (this.data_info.nrows + 2)
            
            let x_min = 0.0
            let x_size = this.user_view.width_frac * this.data_info.ncols
            let x_pos = ((width - x_size) * this.user_view.xpos_frac).toFixed(3)
            
            let y_min = 0.0
            let y_pos = 0.0
            let y_size = height
            
            return {
                width, height, x_size, x_pos, y_size, y_pos, y_min, x_min, 
            }
        },
        
        indexes: function() {
            let idx_width = Math.ceil(this.port.x_size/2)
            let idx_pos = Math.floor(this.port.x_pos) 
            let idx_max = this.data_info.ncols
            return {
                min: Math.max(idx_pos - idx_width, 0),
                max: Math.min(idx_max, idx_pos + idx_width),
            }
        },
        rows: function() {
            return Array(this.data_info.row_count).fill(0);
        },

    },
    methods: {
      move: function ({deltaY: dY, deltaX: dX}) {
        let dL = Math.min(dY, 10);
        this.user_view.xpos_frac += dL / 1000.0;
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
    
</style>
