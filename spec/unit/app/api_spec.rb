require_relative '../../../app/api'

module ExpensesTracker
  # RecordResult = Struct.new(:success?, :expense_id, :error_message)

  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end
    let(:ledger) { instance_double('ExpensesTracker::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { {'some' => 'data'} }
        before do
          allow(ledger).to receive(:record).with(expense)
          .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id'do
          post '/expenses', JSON.generate(expense)
          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('expense_id' => 417)
        end

        it 'responnds with 200' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'whe the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end
        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unoprocessed entry)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date' do
      context 'when expenses exist on the given date' do
      before do
        allow(ledger).to receive(:expenses_on)
        .with('2017-06-12')
        .and_return(['expense_one', 'expense_two'])
      end
        it 'returns the expense record as JSON' do
          get '/expenses/2017-06-12'
          expenses = JSON.parse(last_response.body)
          expect(expenses).to eq(['expense_one', 'expense_two'])
        end
        it 'responses with a 200' do
          get '/expenses/2017-06-12'
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
          .with('2017-06-12')
          .and_return([])
        end
        it 'returns empty array as JSON' do
          get '/expenses/2017-06-12'
          expenses = JSON.parse(last_response.body)
          expect(expenses).to eq([])
        end
        it 'responds with a 200' do
          get '/expenses/2017-06-12'
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
