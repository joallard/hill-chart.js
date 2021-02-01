<template lang="pug">
svg.hill-chart.chart(v-bind="{width, height}")
  path.curve(:d="curvePathD" stroke="#999" fill="none")

  line.axis.x-axis(v-if="display.xAxis" v-bind="xAxis" stroke='#ccc')
  line.axis.middle-axis(v-if="display.middleAxis" v-bind="middleAxis" stroke='#ccc')

  hill-chart-item(v-for="(item, i) in items" :key="i" v-bind="item")
  slot
</template>

<script lang="coffee">
import HillChartItem from './HillChartItem.vue'
import * as d3 from 'd3'

# Maps 0..1 => 0..1 on a e^x2 curve
HillCurve = {
  f: (x) => Math.exp(-16 * (x-0.5)**2),
}

clone = (obj) => JSON.parse(JSON.stringify(obj))

Line = {
  horizontal: ({y, x1, x2}) => ({x1, x2, y1: y, y2: y})
  vertical: ({x, y1, y2}) => ({x1: x, x2: x, y1, y2})
}

height = ({width, aspectRatio}) => Math.round(width/aspectRatio)

# To define padding, either provide {x,y} or {top, bottom, left, right}
padding = (params) => ({
  top: params.top || params.y,
  bottom: params.bottom || params.y,
  left: params.left || params.x,
  right: params.right || params.x,
})

# Turns a chart mapped on (x,y) ∈ (0..1, 0..1), mapped to (width, height).
# On the svg, y goes from (up..down): top is y=0.
# See methods.s for scale.
export default {
  components: {HillChartItem},

  props: {
    items: Array,
    width: { type: Number, default: 600 },
    aspectRatio: { type: Number, default: 3 },
    height: { type: Number, default: -> height(this) },
    padding: { type: Object, default: -> padding({x: 12, y: 16}) }
  }

  data: -> {
    display: {
      xAxis: true,
      middleAxis: true,
    },
  }

  computed:
    # Short for 'scale'
    s: ->
      {top, bottom, left, right} = @padding
      {width, height} = this

      {
        x: d3.scaleLinear([0,1], [left, width-right]),
        y: d3.scaleLinear([0,1], [height-bottom, top])
      }

    # Reminder: On the svg, y goes from (up..down)
    middleAxis: Line.vertical({x: @s.x(0.5), y1: @s.y(0), y2: @s.y(0.95)})

    # Drawn below zero because curve bottoms out at zero
    xAxis: Line.horizontal({y: @s.y(-0.08), x1: @s.x(0), x2: @s.x(1)})

    # Returns the curve's path[d] SVG attribute
    curvePathD: ->
      N_POINTS = 500
      curvePoints = d3.range(0, 1, 1/N_POINTS).map((x) => [x, @f(x)])
      sv = [@s.x, @s.y]
      sdx = (d) => @scalePoint(d)[0]
      sdy = (d) => @scalePoint(d)[1]

      lineGenerator = d3.line().x(sdx).y(sdy)
      lineGenerator(curvePoints)

  methods: {
    scalePoint: ([x,y]) -> [@s.x(x), @s.y(y)],
    f: HillCurve.f,
  }
}
</script>

<style lang="sass">
.middle-axis
  stroke-dasharray: 8,8
</style>
