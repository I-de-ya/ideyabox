# Ideyabox

TODO: Write a gem description

## Our statuses

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/I-de-ya/ideyabox)
[![Dependency Status](https://gemnasium.com/I-de-ya/ideyabox.png)](https://gemnasium.com/I-de-ya/ideyabox)

## Installation

Add this line to your application's Gemfile:

    gem 'ideyabox'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ideyabox

## Usage

Hey, people!

It's simple like this:

After installation generate all administrative staff
    
    $ rails g ideyabox:admin -f

Generate some model or scaffold for your project

Add */admin* route in your *config/routes.rb* in :admin namespace
    
    namespace :admin do 
      root :to => "your_controller#your_action"
    end

like this
    
    namespace :admin do 
      root :to => "guests#index"
    end

## TODO

1. Add search engine
2. Add scopes to models
2. Use it

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
