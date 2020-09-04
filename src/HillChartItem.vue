<template lang="pug">

g.hill-chart-item.item(:transform="transform")
  circle(cx=0 cy=0 r=8 v-bind="style.circle")

  text.label(v-bind="labelAttrs" v-if="text")
    | {{text}}

</template>

<script lang="coffee">
import HillMath from './hill_math'
import * as d3 from 'd3'

# Rounds number to `precision` decimals
round = (number, precision) =>
  precision = 3
  factor = 10**precision

  Math.round(number*factor)/factor


export default {
  mixins: [HillMath],

  props: {
    progress: Number,

    color: {
      type: String,
      default: '#666',
    },

    text: {
      type: String,
      default: -> @$slots?.default?[0]?.text,
    },
  },

  data: -> {
    currentProgress: @progress,

    style: {
      circle: {
        stroke: @shades(@color).dark,
        strokeWidth: 1.4,
        fill: @color,
      },

      label: {
        fill: @shades(@color).darker,
      }
    },
  },

  mounted: ->
    @setupDrag()

  computed:
    s: -> @$parent.s
    pos: -> @$parent.scalePoint(@point)

    point: -> @xyHill(@currentProgress)

    transform: ->
      joined = @pos.join(",")
      "translate(#{joined})"

    labelPosition: ->
      if @point[0] >= 0.8 then "left" else "right"

    labelAttrs: ->
      positionLeft = (@labelPosition == "left")
      klass = "position-#{@labelPosition}"
      padding = 14

      x = if positionLeft then -padding else padding
      y = 5

      textAnchor = if positionLeft then "end"

      {
        x, y,
        class: klass,
        "text-anchor": textAnchor,
        ...@style.label
      }

  methods:
    # concerning Dragging:
    setupDrag: ->
      drag = d3.drag()
        .on('drag', => @onDrag(d3.event))
        .on('end', => @onDragEnd(d3.event))

      d3.select(@$el).call(drag).style("cursor", "move")

    onDrag: (ev) ->
      {x,y} = ev
      p = @s.x.invert(x)

      return if (p < 0) or (p > 1)
      @currentProgress = p

    onDragEnd: (ev) ->
      @$emit('change', {@currentProgress})
      # console.log('change', {@currentProgress})

    # concerning Color:
    shades: (color) ->
      {
        color: color,
        darker: @luminance(color, 0.08, '#111'),
        dark: @luminance(color, 0.20),
      }

    luminance: (color, quantity, fallback = null) ->
      if chroma = @$chroma || globalThis.chroma
        chroma(color).luminance(quantity).css('hsl')
      else
        fallback || color
}

</script>

<style lang="sass">
</style>
