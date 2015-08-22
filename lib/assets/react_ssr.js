/*! (c) 2015 @tovvry */

window.Components = window.Components || {};

(function (undefined) {
  function ready () {
    var scripts = document.getElementsByTagName('script');
    Components.__loaded = Components.__loaded || {};
    var _ = Components.__loaded;

    if (!scripts.length) return;
    if (typeof Components === 'undefined') typeof console !== 'undefined' && console.error && console.error("`Components` global object not found.");

    for (var i = 0, script; i < scripts.length; i++) {
      script = scripts[i];

      var view;
      var node;
      var props;

      var lastView, len;
      if (script.hasAttribute && script.hasAttribute('data-reactssr-class')) {
        view = script.getAttribute('data-reactssr-class');
        _[view] = _[view] || [];
        len = (_[view]).length;
        lastView = (_[view])[len - 1];
        if (!lastView) {
          lastView = {};
          _[view].push(lastView);
        }
        lastView.script = script;
      } else {
        continue;
      }

      node = script.previousSibling;
      lastView.node = node;

      if (!(view in Components)) {
        continue;
      }

      view = Components[view];
      if (!view) return;

      if (!node.hasAttribute('data-react-props')) {
        continue;
      } else {
        props = node.getAttribute('data-react-props');
      }

      if (props) {
        props = JSON.parse(props);
      } else {
        props = {};
      }

      React.render(React.createElement(view, props), node);
    }
  }

  if (document.addEventListener) {
    document.addEventListener('DOMContentLoaded', ready);
  } else if (document.attachEvent) {
    var whenReady = function () {
      if (document.readyState === 'complete') {
        document.detachEvent('onreadystatechange', whenReady);
        ready();
      }
    };
    document.attachEvent('onreadystatechange', whenReady);
  }
}());
