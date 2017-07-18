require 'stripe/event'
module Stripe
  module EventDispatch
    def dispatch_stripe_event(params)
      retrieve_stripe_event(params) do |evt|
        if evt.respond_to?(:data) && evt.data.respond_to?(:object)
          target = evt.data.object
          ::Stripe::Callbacks.run_callbacks(evt, target)
        else
          target = evt.data[:object]
          ::Stripe::Callbacks.run_callbacks(evt, target)
        end
      end
    end

    def retrieve_stripe_event(params)
      id = params['id']
      user_id = params['user_id']
      if id == 'evt_00000000000000' #this is a webhook test
        yield Stripe::Event.construct_from(params)
      elsif user_id.nil?
        yield Stripe::Event.retrieve(id)
      else 
        event = Stripe::Event.retrieve(id, {stripe_account: user_id})
        event.user_id = user_id
        yield event
      end
    end
  end
end