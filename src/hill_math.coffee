HillMath = {
  methods: {
    # fHill: (x) => 0.5 * (1 - Math.cos(2 * Math.PI * x)),
    fHill: (x) => Math.exp(-16*(x-0.5)**2),
    xyHill: (x) -> [x, @fHill(x)]
  }
}

export default HillMath
