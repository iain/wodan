# Wodan

## Current State: thought experiment

Wodan is a framework for executing use cases. It is designed so that your
business logic is completely isolated and independant from Wodan, or any other
library. Think Rack Middleware, but for service objects.

## Usage

### Creating use cases

A use case is a plain Ruby object, without any external dependencies. This is
what a typical use case can look like:

``` ruby
class EatFood

  attr_reader :context, :person, :food

  # Sets up the world.
  # The context object will always be passed and contains your access to other use cases.
  # The other arguments are entirely optional and depend on which information you need for the use case.
  def initialize(context, options = {})
    @context = context
    @person  = options.fetch(:person)
    @food    = options.fetch(:food)
  end

  # What this use case does.
  # You can use the context to trigger other use cases. In this case a use case
  # called :chew_food is called, and the person is passed as an argument.
  def call
    person.mouth << food
    context.chew_food(person: person)
  end

  # Determines if the use case can be executed (optional)
  def preconditions
    not food.expired?
  end

  # Can be used to check if everything worked (optional)
  def postconditions
    person.eaten?(food)
  end

  # If everything went well, this is the return value of calling the use case (optional)
  def result
    person.stomach
  end

  # What to do if the postconditions were not met (optional)
  def fallback
    raise "The person #{person} forgot how to eat #{food}"
  end

  # Define to catch errors anywhere in the use case.
  def on_error(error)
    # send to error notifier, and possibly raise the same error again:
    raise error
  end

end
```

Except for the `initialize` and `call` methods, none of the other methods need
to be defined. Wodan will intelligently decide what do. More on that later.

### Testing use cases

As you can see, there is nothing that explicitly references other classes or
even Wodan. No inheritence, no mixin, nothing. This means that you can easily
create fast isolated unit tests. Here is an example in RSpec:

``` ruby
require 'eat_food'

describe EatFood do

  let(:context) { double :context }
  let(:food) { double :food }
  let(:person) { double :person }
  subject(:use_case) { EatFood.new(context, person: person, food: food) }

  it "puts food in mouth and chews it" do
    mouth_contents = []
    person.stub(:mouth => mouth_contents)
    context.should_receive(:chew_food).with(person: person)
    use_case.call
    mouth_contents.should eq [food]
  end

  it "will not eat expired food" do
    food.stub(:expired? => true)
    use_case.preconditions.should be_false
  end

end
```

Wodan is responsible for calling the right methods at the right moment. For
example, it will not execute your use case when you have preconditions and they
return false. But you don't need to do this in your tests. This means that you
can test the preconditions independent from the actual use case as well.

### Executing a use case

You can execute a single use case:

``` ruby
Wodan.call(EatFood, context, person: @customer, food: @soup)
```

This way of calling doesn't require your use cases to have a context, like
shown in previous examples. I still recommend using a context. They will
automatically be set to the current *domain*.

### Domains

In order to execute a use case, you need to create domain. In contrast to use
cases, domains are tightly coupled to Wodan, much like ActiveRecord models are
tied to ActiveRecord. It is therefore smart not to put business logic in here.
A domain is just for putting it all together.

``` ruby
class RestaurantDomain < Wodan::Domain

  # register which use cases can be called
  use_case :eat_food, class: "EatFood"
  use_case :pay_bill, class: "PayBill"

  # provide (custom) integration to be used in the use cases
  def menu
    @menu ||= Menu.items(available_at: Date.today)
  end

end
```

To execute a use case:

``` ruby
restaurant = RestaurantDomain.new
restaurant.eat_food(person: @user, food: @pancake)
```

You are free to define your own initializer for a domain. You can use that to
keep a reference to "global" settings, like the current user, or a database
connection. The `context` in the use case initializer is the instance of the
domain.

The reason for defining other methods in a domain, is to integrate with the
rest of the system. Your isolated use cases can stub these methods, so they
don't have to integrate with heavier systems like ActiveRecord.

Use case methods, like `eat_food`, are created inside a mixed in module.
This means you can override them and call super.

## Installation

Add this line to your application's Gemfile:

    gem 'wodan'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wodan

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
