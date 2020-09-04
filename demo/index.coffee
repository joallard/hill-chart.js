import '../src/index'
import HillChart from '../src/HillChart.vue'
import HillChartItem from '../src/HillChartItem.vue'

import chroma from 'chroma-js'
Vue.prototype.$chroma = chroma
# window.chroma = chroma

vm = new Vue(
  components: {HillChart, HillChartItem},
  el: window.appDiv
)
