if (typeof Components === 'undefined') {
  if (Object.defineProperty) {
    Object.defineProperty(this || window || global, 'Components', {
      configurable: false,
      writable: true,
      value: {}
    })
  } else {
    (this || window || global)['Components'] = {};
  }
}
