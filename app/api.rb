require 'sinatra/base'
require 'json'
require 'ox'
require_relative 'ledger'

module ExpensesTracker
  class API < Sinatra::Base
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end

    post '/expenses' do

      # if request.content_type == 'aplication/json'
        expense = JSON.parse(request.body.read)
        result = @ledger.record(expense)
        if result.success?
          JSON.generate('expense_id' => result.expense_id)
        else
          status 422
          JSON.generate('error' => result.error_message)
        end
      end
    # else
    #   expense = JSON.parse(request.body.read)
    #   result = @ledger.record(expense)
    #   if result.success?
    #     JSON.generate('expense_id' => result.expense_id)
    #   else
    #     status 422
    #     JSON.generate('error' => result.error_message)
    #   end
    # end


    get '/expenses/:date' do
      JSON.generate(@ledger.expenses_on(params[:date]))
    end


  end
end
