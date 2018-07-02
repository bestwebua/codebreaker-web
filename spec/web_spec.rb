require 'spec_helper'

module Codebreaker
  RSpec.describe Web do
    include Rack::Test::Methods

    let(:app)     { Rack::Builder.parse_file('config.ru').first }
    let(:session) { last_request.env['rack.session'] }

    describe 'basic scenario' do
      before { get Web::ROOT_URL }

      describe "'#{Web::ROOT_URL}' request" do
        context 'session' do
          specify { expect(session).to be_empty }
        end

        context 'response' do
          specify { expect(last_response.status).to eq(200) }
        end

        context 'template' do
          specify { expect(last_response.body).to include('index-template') }
        end
      end

      describe "'#{Web::PLAY_URL}' request" do
        before do
          get Web::PLAY_URL,
          player_name: 'Tester',
          level: Game::SIMPLE_LEVEL.to_s
        end

        context 'data from game configuration form are valid' do
          specify { expect(last_response.status).to eq(200) }
        end

        context 'self.game' do
          specify { expect(session[:game]).to be_an_instance_of(Game) }
        end

        context 'self.token' do
          specify { expect(session[:token]).to be_an_instance_of(String) }
        end

        context 'self.ip' do
          specify { expect(session[:ip]).to be_an_instance_of(String) }
        end

        context 'self.scores' do
          specify { expect(session[:scores]).to be_an_instance_of(Array) }
        end

        context 'template' do
          specify { expect(last_response.body).to include('game-template') }
        end
      end



    end

    skip describe 'application errors' do
      let(:error_template) { expect(last_response.body).to include('error-template') }

      context 'restricted access' do
        context "#{Web::LANG_URL}" do
          before { get Web::LANG_URL }
          specify { expect(last_response.status).to eq(403) }
          specify { error_template }
        end

        context "#{Web::PLAY_URL}" do
          before { get Web::PLAY_URL }
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
