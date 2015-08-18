[![Gem](https://img.shields.io/gem/v/reactssr-rails.svg?style=flat-square)](http://rubygems.org/gems/reactssr-rails)

* * *

# Reactssr::Rails

Works with `react-rails` and `webpackrails` to server render react components by
views.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reactssr-rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reactssr-rails

## Usage

The javascript assets folder structure is like views folder, but the base folder
should be `components`, for example: 

```
javascripts -|
  components -|
    home -|
      index -|
```

In the above folder structure, the home folder is the controller name, if your
controller is under `some_namespace`, then the home folder should under `some_namespace`
folder, just like `views` folder structure.

You can config the base folder, put this within your `config/application.rb` file, 
`config.reactssr.assets_base = 'folder_name'`.

#### react server rendering

`react_ssr` is a view helper just like `react_component` in `react-rails`. Here is
an example how to use it:

```js
<%= react_ssr('IndexView', {props}, {prerender: true}) %>
```
If you specific `prerender: false` in the options, the `react_ssr` will use
`react_component` instead (will be changed in future). For now, please just use
`prerender: true`.

So, how reactssr look up the `IndexView` react component in assets? Well, it will
look up the view by controller name and action name, so the controller name is `home`
and action name is `index`, then it will look up a file named `index.ssr.js` in 
folder `components/home/index/`. You just put your components in that file and 
expose those components on `Components` js global object. Here is an example of
`index.ssr.js`:

```js
// index.ssr.js

Components.IndexView = require('./IndexView.jsx');
```

And put your `IndexView.jsx` file under `components/home/index/` folder. Such 
file would be like this:

```js
// IndexView.jsx

module.exports = React.createClass({
  render: function () {
    return <p>Hello world</p>
  }
})
```

## NOTICE

Not tested in production environment.

## TODO

- [ ] In production env, do not run `webpackrails`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/reactssr-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
