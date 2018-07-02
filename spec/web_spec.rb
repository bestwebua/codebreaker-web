require 'spec_helper'

module Codebreaker
  RSpec.describe Web do
    include Rack::Test::Methods

    let(:app)            { Rack::Builder.parse_file('config.ru').first }
    let(:session)        { last_request.env['rack.session'] }
    let(:error_template) { expect(last_response.body).to include('error-template') }

    describe "'#{Web::ROOT_URL}' request" do
      before { get(Web::ROOT_URL) }

      it 'clear session' do
        expect(session).to be_empty
      end
      
      specify do
        expect(last_response.status).to eq(200)
      end
      
      it 'render index template' do
        expect(last_response.body).to include('index-template')
      end
    end

    describe "'#{Web::PLAY_URL}' request" do
      context 'game configuration data valid' do
        before do
          get(Web::PLAY_URL, player_name: 'Tester', level: Game::SIMPLE_LEVEL.to_s)
        end

        context "#{Web::PLAY_URL}" do
          specify do
            expect(last_response.status).to eq(200)
          end

          it 'sets game instance' do
            expect(session[:game]).to be_an_instance_of(Game)
          end

          it 'sets player token' do
            expect(session[:token]).to be_an_instance_of(String)
          end

          it 'sets player ip' do
            expect(session[:ip]).to be_an_instance_of(String)
          end
        end

        describe 'scenario' do
          context 'the game is still going on' do
            it 'load scores' do
              expect(session[:scores]).to be_an_instance_of(Array)
            end

            it 'render game template' do
              expect(last_response.body).to include('game-template')
            end
          end

          context 'game over' do
            before do
              allow_any_instance_of(Game).to receive(:won?).and_return(true)
            end

            it "redirects to '#{Web::FINISH_URL}'" do
              get(Web::FINISH_URL)
              expect(last_response.status).to eq(200)
            end
          end

          context 'system error' do
            before { session.clear }

            it "redirects to '#{Web::ROOT_URL}'" do
              get(Web::ROOT_URL)
              expect(last_response.status).to eq(200)
            end
          end
        end
      end

      context 'game configuration data not valid' do
        context "#{Web::PLAY_URL}" do
          before { get Web::PLAY_URL }
          specify { expect(last_response.status).to eq(403) }
          specify { error_template }
        end
      end
    end



    skip describe 'application errors' do
      context 'restricted access' do
        context "#{Web::LANG_URL}" do
          before { get Web::LANG_URL }
          specify { expect(last_response.status).to eq(403) }
          specify { error_template }
        end

        

        context "#{Web::HINT_URL}" do
          before { get Web::HINT_URL }
          specify { expect(last_response.status).to eq(403) }
          specify { error_template }
        end

        context "#{Web::SUBMIT_URL}" do
          before { get Web::SUBMIT_URL }
          specify { expect(last_response.status).to eq(403) }
          specify { error_template }
        end

        context "#{Web::FINISH_URL}" do
          before { get Web::SUBMIT_URL }
          specify { expect(last_response.status).to eq(403) }
          specify { error_template }
        end
      end

      context 'not found' do
        context '/unknown_url' do
          before { get '/unknown_url' }
          specify { expect(last_response.status).to eq(404) }
          specify { error_template }
        end
      end
    end

  end
end
