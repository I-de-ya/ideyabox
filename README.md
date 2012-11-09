# Ideyabox

TODO: Write a gem description

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

1. Generate new rails app    
    rails new <your_app_name>

2. Add our gem to your app's Gemfile
    gem "ideyabox"

3. Generate all administrative staff
    rails g ideyabox:admin

4. Generate some model or scaffold for your project

5. Add route in your config/routes.rb in :admin namespace
    namespace :admin do 
      root :to => "<your controller>#<your action>"
    end

like this
    namespace :admin do 
      root :to => "guests#index"
    end

## TODO

1. Add scaffolds
2. Use it

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
