# hill-chart.js
Generate hill charts in the browser, in Javascript, or in the shell.

On a [Codepen](https://codepen.io/joallard/pen/WNwwoJY) for now.

*Item dragging is unimplemented yet; this is read-only.*

<img src="https://raw.githubusercontent.com/joallard/hill-chart.js/meta/hillchart.png" width=560>

Hill charts are a central element in the Building part of methodology book *Shape Up*<sup>[webbook][1]</sup> by Ryan Singer (Basecamp).

[1]: https://basecamp.com/shapeup

Uses Vue under the hood.

Highly inspired from Ahmed Nagi's (@nagi1) [hill-chart][2].

[2]: https://github.com/nagi1/hill-chart


## Usage
This interface is designed with *convention over configuration* in mind.

#### Legend
* **required** items are in bold
* *(defaults)* are between parentheses
* ***recommended*** but not required items are bold italic.

#### Parameters
* **`<hill-chart>`**
  * `width` *(`600`)*
  * `aspectRatio` *(`3`)*
  * `height` *(`null`)*
  * `items` *(`[]`)*

* ***`<hill-chart-item>`***
  * **`progress`**
  * ***`label`*** *(`null`)*
  * `color` *(`#333`)*

### \<hill-chart> — Vue component/HTML element
*(Custom HTML element without Vue is not implemented yet.)*

```html
<hill-chart>
    <hill-chart-item :progress="0" label="Zero"></hill-chart-item>
    <hill-chart-item :progress="0.4" label="Progress 0.4"></hill-chart-item>
    <hill-chart-item :progress="0.1" label="Start climb"></hill-chart-item>
    <hill-chart-item :progress="0.81" label="Almost there"></hill-chart-item>
    <hill-chart-item :progress="1" label="One"></hill-chart-item>
</hill-chart>
```

```html
<hill-chart  :items="[{progress: 0.3, label: 'Data item'}, ...otherItems]"></hill-chart>
```

### hill-chart [*options*] *items* — Shell
*(Not implemented yet)*

> hill-chart [--width|-w *width*] [--aspect-ratio|-r *ratio*] [...*chart options*] ...*items-array*

```console
$ hill-chart --width 200 '[{label: "First item", progress: 0.2}, {label: "Second item", progress: 0.7}]'

<svg>...</svg>
```

### HillChart.generate({...*options*, items}) — Function
*(Not implemented yet)*

```js
HillChart.generate({width: 400, items: [{progress: 0.3, label: "Climbing"}, ...otherItems]})
// <svg>...</svg>
```

## Internals (simplified)

### Templates

(Pug syntax follows)

```pug
template#hill-chart

  svg.hill-chart.chart(:width="$width" :height="$height")
    path.curve

    line.axis.x-axis
    line.axis.mid-y-axis

    hill-chart-item(v-for="(item, i) in items" :key="i" v-bind="item")
    slot
```

```pug
template#hill-chart-item

  g.hill-chart-item.item(:transform="transform")
    circle(:fill="color || '#333'" cx=0 cy=0 r=8)
    text.label(v-bind="labelAttrs") {{label}}
```

### JS
The chart model is mapped from 0 to 1 on both axes, and then scaled to
the chart's lengths using D3.

#### Hill curve
The hill curve is defined as such:

![h(x) = (1/2)*(1-cos(2pi\*x))](https://render.githubusercontent.com/render/math?math=\large+h(x)+%3D+\frac{1}{2}+\left(1+-+\text{cos}(2+\pi+\cdot+x)+\right))

<!--tex
    h(x) = \frac{1}{2} \left(1 - \text{cos}(2 \pi \cdot x) \right)
-->

```coffee
$fHill = (x) => 0.5 * (1 - Math.cos(2 * Math.PI * x))
```

Meaning it has a wavelength of 1, peak to peak; it maps h(0) to 1 (as cos
does); its height goes from 0 to 1 (instead of -1 to 1 – which is why it is raised by 1, then
halved).

(Thanks: [A hack for showing LaTeX formulas in GitHub markdown](https://gist.github.com/a-rodin/fef3f543412d6e1ec5b6cf55bf197d7b) @a-rodin)

## CSS
Defaults are commented.

```sass
svg.hill-chart

  .curve
    // stroke: #999

  .axis
    // stroke: #ccc

  .mid-y-axis
    // stroke-dasharray: 8,8

  // // Properties here will override attributes such as circle[fill]!
  // .item circle
  //   fill: #777
```

## Licence: AGPL
*If you make changes to this library that you then make available, you must make them available too.*

See the [license](https://github.com/joallard/hill-chart.js/blob/trunk/LICENSE).

To use it under another license, contact the author.
