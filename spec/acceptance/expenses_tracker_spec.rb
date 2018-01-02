require "rack/test"
require "json"
require_relative "../../app/api"

module ExpensesTracker
    RSpec.describe "Expences tracker api", :db do
      include Rack::Test::Methods

      def post_expense(expense)
        post '/expenses', JSON.generate(expense)
        expect(last_response.status).to eq(200)

        parsed = JSON.parse(last_response.body)
        expect(parsed).to include('expense_id' => a_kind_of(Integer))
        expense.merge('id' => parsed['expense_id'])
      end

      it "records expenses" do
        coffee = post_expense(
          'payee' => 'Starbucks',
          'amount' => 5.75,
          'date' => '2017-06-10'
        )
        zoo = post_expense(
        'payee' => 'zoo',
        'amount' => 15.75,
        'date' => '2017-06-10'
        )
        groceries = post_expense(
        'payee' => 'whole foods',
        'amount' => 95.75,
        'date' => '2017-06-11'
        )
        get '/expenses/2017-06-10'
        expect(last_response.status).to eq(200)

        expenses = JSON.parse(last_response.body)
        expect(expenses).to contain_exactly(coffee, zoo)
      end
    end
  end

  def app
    ExpensesTracker::API.new
  end
