<template lang="pug">
svg.hill-chart.chart(v-bind="{width, height}")
  path.curve(:d="curveD" stroke="#999" fill="none")

  line.axis.x-axis(v-if="display.xAxis" v-bind="xAxis" stroke='#ccc')
  line.axis.middle-axis(v-if="display.middleAxis" v-bind="middleAxis" stroke='#ccc')

  .items
    hill-chart-item(v-for="(item, i) in items" :key="i" v-bind="item")
    slot
</template>

<script>
// import HillChartItem from './HillChartItem.vue'
import range from 'lodash/range'
import {scaleLinear} from 'd3-scale'

// Maps 0..1 => 0..1 on a e^x2 curve
const ExpCurve = (x) => Math.exp(-16 * (x-0.5)**2)

const Line = {
  horizontal: ({y, x1, x2}) => ({x1, x2, y1: y, y2: y}),
  vertical: ({x, y1, y2}) => ({x1: x, x2: x, y1, y2})
}

const Rect = {
  height: ({width, aspectRatio}) => Math.round(width/aspectRatio)
}

// To define padding, either provide {x,y} or {top, bottom, left, right}
const padding = (params) => {
  return {
    top: params.top || params.y,
    bottom: params.bottom || params.y,
    left: params.left || params.x,
    right: params.right || params.x
  }
}

const Path = {
  d: (points) => "M" + points.join("L")
}

// Samples 'fn' over a normal (0..1) range, `samples` times
const sampleFunction = (fn, samples = 500) =>
  range(0, 1, 1/samples).map((x) => [x, fn(x)])


// Turns a chart mapped on (x,y) ∈ (0..1, 0..1), mapped to (width, height).
// On the svg, y goes from (up..down): top is y=0.
// See methods.s for scale.
export default {
  // components: {HillChartItem},

  props: {
    items: {type: Array, default: ()=> [] },
    width: { type: Number, default: 600 },
    aspectRatio: { type: Number, default: 3 },
    height: { type: Number, default: function(){ return Rect.height(this) } },
    padding: { type: Object, default: ()=> padding({x: 12, y: 16}) },
  },

  data: () => ({
    display: {
      xAxis: true,
      middleAxis: true,
    },

    curve: ExpCurve,
  }),

  computed: {
    // Short for 'scale'
    s: function(){
      const {top, bottom, left, right} = this.padding
      const {width, height} = this

      return {
        x: scaleLinear([0,1], [left, width-right]),
        y: scaleLinear([0,1], [height-bottom, top])
      }
    },

    // Reminder: On the svg, y goes from (up..down)
    middleAxis: function(){
      const {x,y} = this.s
      return Line.vertical({x: x(0.5), y1: y(0), y2: y(0.95)})
    },

    // Drawn below zero because curve bottoms out at zero
    xAxis: function(){
      const {x,y} = this.s
      return Line.horizontal({y: y(-0.08), x1: x(0), x2: x(1)})
    },

    // Charts `this.curve` on the local context
    // Returns the curve's path[d] SVG attribute
    curveD: function(){
      const curvePoints = sampleFunction(this.curve).map(this.scalePoint)
      return Path.d(curvePoints)
    }
  },

  methods: {
    scalePoint: function([x,y]){ return [this.s.x(x), this.s.y(y)] },
  }
}
</script>

<style lang="sass">
.middle-axis
  stroke-dasharray: 8,8
</style>
