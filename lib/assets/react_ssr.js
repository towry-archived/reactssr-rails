/*! (c) 2015 @tovvry */

(function (undefined) {
  var scripts = document.getElementsByTagName('script');

  if (!scripts.length) return;
  if (typeof Components === 'undefined') typeof console !== 'undefined' && console.error && console.error("`Components` global object not found.");

  for (var i = 0, script; i < scripts.length; i++) {
    script = scripts[i];

    var view;
    var node;
    var props;

    if (script.hasAttribute && script.hasAttribute('data-reactssr-class')) {
      view = script.getAttribute('data-reactssr-class');
    } else {
      continue;
    }

    if (!(view in Components)) {
      continue;
    }

    view = Components[view];
    if (!view) return;

    node = script.previousSibling;

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
}());
