[![Gem](https://img.shields.io/gem/v/reactssr-rails.svg?style=flat-square)](http://rubygems.org/gems/reactssr-rails)

* * *

# Reactssr::Rails

React SSR in Rails.

This gem is to solve one problem, that's `react-rails` will compile all React 
components in one file. 

This gem will works well with `webpackrails` to let you use commonjs feature, 
and only evaluate js code as few as possible, and in production environment it
will use precompiled static file **instead of** compiling the files again and again.

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

The SSR file is a js file whose name ends with `ssr.js` under base folder, and 
base folder is the folder where you put all your SSR files at, the default base
folder name is `components`.

You can config the base folder, put this within your `config/application.rb` file, 
`config.reactssr.assets_base = 'folder_name'`.

#### react server rendering

`react_ssr` is a view helper just like `react_component` in `react-rails`. Here is
an example how to use it:

```js
<%= react_ssr('IndexView', {props}) %>
```

So, suppose the current `controller_path` is `home`, then reactssr-rails will look
up a ssr file in components named `home.ssr.js`, just like below:

```js
// home.ssr.js

Components.IndexView = require('./IndexView.jsx');
```

## Example

http://github.com/towry/reactssr-rails-example

## TODO

- [x] In production env, do not run `webpackrails`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/towry/reactssr-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
