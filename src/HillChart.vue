<template lang="pug">

svg.hill-chart.chart(v-bind="{width, height}")
  path.curve(:d="curvePathD" stroke="#999" fill="none")

  line.axis.x-axis(v-if="display.xAxis" v-bind="lineAxesXY.x" stroke='#ccc')
  line.axis.middle-axis(v-if="display.middleAxis" v-bind="lineAxesXY.middle" stroke='#ccc')

  hill-chart-item(v-for="(item, i) in items" :key="i" v-bind="item")
  slot

</template>

<script lang="coffee">
import HillMath from './hill_math'
import HillChartItem from './HillChartItem.vue'
import * as d3 from 'd3'

orthogonalLine = (opts) ->
  opts = JSON.parse(JSON.stringify(opts))
  if opts.y then (opts.y1 = opts.y2 = opts.y; delete opts.y)
  if opts.x then (opts.x1 = opts.x2 = opts.x; delete opts.x)
  opts

# Turns a chart mapped on (x,y) ∈ (0..1, 0..1), mapped to (width, height).
# On the svg, y goes from (up..down): top is y=0.
# See methods.s for scale.
export default {
  components: {HillChartItem},
  mixins: [HillMath],

  props: {
    items: Array,

    width: {
      type: Number,
      default: 600
    },

    aspectRatio: {
      type: Number,
      default: 3
    },

    height: {
      type: Number,
      default: -> Math.round(@width / @aspectRatio)
    },

    padding: {
      type: Object,
      default: -> {x: 12, y: 16}
    }
  }

  data: -> {
    display: {
      xAxis: true,
      middleAxis: true,
    },
  }

  computed:
    $padding: -> {
      top: @padding.top || @padding.y,
      bottom: @padding.bottom || @padding.y,
      left: @padding.left || @padding.x,
      right: @padding.right || @padding.x,
    }

    # Short for 'scale'
    s: ->
      {top, bottom, left, right} = @$padding

      {
        x: d3.scaleLinear([0,1], [left, @width-right]),
        y: d3.scaleLinear([0,1], [@height-bottom, top])
      }

    # Reminder: On the svg, y goes from (up..down)
    lineAxesXY: ->
      {
        # Vertical middle line
        middle: @orthogonalLine(
          x: @s.x(0.5), y1: @s.y(0), y2: @s.y(0.95)
        ),

        # Drawn below zero because curve bottoms out at zero
        x: @orthogonalLine(
          y: @s.y(-0.08), x1: @s.x(0), x2: @s.x(1)
        )
      }

    # Returns the curve's path[d] SVG attribute
    curvePathD: ->
      nPoints = 500
      curvePoints = d3.range(0, 1, 1/nPoints).map(@xyHill.bind(this))

      sv = [@s.x, @s.y]

      sdx = (d) => @scalePoint(d)[0]
      sdy = (d) => @scalePoint(d)[1]

      lineGenerator = d3.line().x(sdx).y(sdy)
      lineGenerator(curvePoints)

  methods: {
    orthogonalLine,

    scalePoint: ([x,y]) -> [@s.x(x), @s.y(y)]
  }
}

</script>

<style lang="sass">

.middle-axis
  stroke-dasharray: 8,8

</style>
