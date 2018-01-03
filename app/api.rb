require 'sinatra/base'
require 'json'
require 'ox'
require_relative 'ledger'
require 'pry'

module ExpensesTracker
  class API < Sinatra::Base
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end

    post '/expenses' do
      if request.content_type == 'text/xml'
        xml = request.body.read
        xml_expense = Ox.load(xml, mode: :hash)
        expense = JSON.parse(xml_expense)
      else
        expense = JSON.parse(request.body.read)
        result = @ledger.record(expense)
        if result.success?
          JSON.generate('expense_id' => result.expense_id)
        else
          status 422
          JSON.generate('error' => result.error_message)
        end
      end
    end

    get '/expenses/:date' do
      JSON.generate(@ledger.expenses_on(params[:date]))
    end


  end
end
