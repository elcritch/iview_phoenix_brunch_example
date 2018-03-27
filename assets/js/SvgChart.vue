<template>
  <div>
    <!-- UI controls that can are used to manipulate the display of the chart -->
    
    <Card class="controls">
      
      <div>
	      <label>Chart width</label>
  	    <input type="range" v-model="settings.width" min="0" max="800" />
      </div>
     
      <div>
        <label>Stroke color</label>
	      <input type="color" v-model="settings.strokeColor" />
      </div>
      
      <div>
	      <label>Search…</label>
  	    <input type="text" v-model="search" />
			</div>
      
      <button v-on:click="add">Add node</button>
       
      <div>
	      Selected: {{ selected }}
      </div>
    </Card>

    <!-- SVG that renders the chart based on the "width" and "height" setting from the Vue instance’s data object -->
    
		<svg width="100%" height="50vh" v-bind:viewBox="`${settings.width} 0 250 50`" preserveAspectRatio="none">
    
      <rect x="0" y="0" width="1000" height="50" style="stroke: #000000; fill: none" ></rect>

      <transition-group tag="g" name="list">
        <g class="node"
           v-for="(node, index) in bars"
           v-bind:key="index">

          <!-- <path v-for="link in links"
                  v-bind:key="link.id"
                  v-bind:d="link.d"
                  v-bind:style="link.style"></path> -->

          <rect v-for="i in 100" v-bind:x="15*node.x + i*10" v-bind:y="node.y" v-bind:width="3" v-bind:height="1" ></rect>

        </g>
    	</transition-group>
  	</svg>

      <div>
	      Test: {{ tests }}
      </div>
  </div>

</template>

<script>
export default {
    
    data: function() {
        return {
            csv: null,
            selected: null,
            search: "force",
            settings: {
                strokeColor: "#19B5FF",
                width: 0,
                height: 600
            },
            bars: [
                {y: 10, x: 10},
                {y: 10, x: 20},
                {y: 10, x: 30},
                {y: 10, x: 40},
                {y: 10, x: 50},

                {y: 30, x: 10},
                {y: 30, x: 20},
                {y: 30, x: 30},
                {y: 30, x: 40},
                {y: 30, x: 50},
            ],
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
    },
    
    computed: {
        
        
        // once we have the CSV loaded, the "root" will be calculated
        
        root: function() {
            
            var that = this;
            
            if (this.csv) {
                var stratify = d3.stratify().parentId(function(d) {
                    return d.id.substring(0, d.id.lastIndexOf("."));
                });
                
                // attach the tree to the Vue data object
                return this.tree(
                    stratify(that.csv).sort(function(a, b) {
                        return a.height - b.height || a.id.localeCompare(b.id);
                    })
                );
            }
        },
        
        // the "tree" is also a computed property so that it is always up to date when the width and height settings change
        
        tree: function() {
            return d3
                .cluster()
                .size([this.settings.height, this.settings.width - 160]);
        },
        
        // Instead of enter, update, exit, we mainly use computed properties and instead of "d3.data()" we can use array.map to create objects that hold class names, styles, and other attributes for each datum
        
        nodes: function() {
            var that = this;
            if (this.root) {
                return this.root.descendants().map(function(d) {
                    return {
                        id: d.id,
                        r: 2.5,
                        className: "node" +
                            (d.children ? " node--internal" : " node--leaf"),
                        text: d.id.substring(d.id.lastIndexOf(".") + 1),
                        highlight: d.id.toLowerCase().indexOf(that.search.toLowerCase()) != -1 && that.search != "",
                        style: {
                            transform: "translate(" + d.y + "px," + d.x + "px)"
                        },
                        textpos: {
                            x: d.children ? -8 : 8,
                            y: 3
                        },
                        textStyle: {
                            textAnchor: d.children ? "end" : "start"
                        }
                    };
                });
            }
        },
        
        // Instead of enter, update, exit, we mainly use computed properties and instead of "d3.data()" we can use array.map to create objects that hold class names, styles, and other attributes for each datum
        
        links: function() {
            var that = this;
            
            if (this.root) {
                
                // here we’ll calculate the "d" attribute for each path that is then used in the template where we use "v-for" to loop through all of the links to create <path> elements
                
                return this.root.descendants().slice(1).map(function(d) {
                    return {
                        id: d.id,
                        d: "M" + d.y + "," + d.x + "C" + (d.parent.y + 100) + "," + d.x + " " + (d.parent.y + 100) + "," + d.parent.x + " " + d.parent.y + "," + d.parent.x,
                        
                        // here we could of course calculate colors depending on data but for now all links share the same color from the settings object that we can manipulate using UI controls and v-model
                        
                        style: {
                            stroke: that.settings.strokeColor
                        }
                    };
                });
            }
        },
        tests: function() {
          window.test = {}
          window.test.root = this.root
          window.test.nodes = this.nodes
          window.test.links = this.links
      }
    },
    methods: {
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
    
    .list-enter-active, .list-leave-active {
      transition: all 1s;
    }
    .list-enter, .list-leave-to /* .list-leave-active for <2.1.8 */ {
      opacity: 0;
      transform: translateY(30px);
    }
    
    .line-enter-active, .line-leave-active {
      transition: all 2s;
      stroke-dashoffset: 0;
    }
    .line-enter, .line-leave-to /* .list-leave-active for <2.1.8 */ {
      stroke-dashoffset: 1000;
    }
</style>
