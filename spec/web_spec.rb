require 'spec_helper'

module Codebreaker
  RSpec.describe Web do
    before(:context) do
      current_yml = "#{File.expand_path('../lib/data/scores.yml', File.dirname(__FILE__))}"
      current_log = "#{File.expand_path('../error.log', File.dirname(__FILE__))}"
      @env = RspecFileChef::FileChef.new(current_yml, current_log)
      @env.make
    end

    after(:context) do
      @env.clear
    end

    let(:app)             { Rack::Builder.parse_file('config.ru').first }
    let(:session)         { last_request.env['rack.session'] }
    let(:status_200)      { expect(last_response.status).to eq(200) }
    let(:status_302)      { expect(last_response.status).to eq(302) }
    let(:status_403)      { expect(last_response.status).to eq(403) }
    let(:status_404)      { expect(last_response.status).to eq(404) }
    let(:error_template)  { expect(last_response.body).to include('error-template') }
    let(:game_template)   { expect(last_response.body).to include('game-template') }
    let(:scores_template) { expect(last_response.body).to include('scores-template') }
    let(:current_score)   { scores_template; expect(last_response.body).to include('current-score') }
    let(:play_instance)   { post(Web::PLAY_URL, player_name: 'Tester', level: Game::SIMPLE_LEVEL.to_s) }
    let(:won_a_game)      { allow(session[:game]).to receive(:won?).and_return(true) }
    let(:lost_a_game)     { allow(session[:game]).to receive(:attempts).and_return(0) }
    let(:use_all_hints)   { allow(session[:game]).to receive(:hints).and_return(0) }

    describe "#{Web::ROOT_URL}" do
      context 'get-request' do
        before { get(Web::ROOT_URL) }

        it 'clear session' do
          expect(session).to be_empty
        end
        
        specify { status_200 }
        
        it 'render index template' do
          expect(last_response.body).to include('index-template')
        end
      end
    end

    describe '/unknown_url' do
      context 'get-request' do
        before { get('/unknown_url') }

        specify { status_404 }

        it 'render error template' do
          error_template
        end
      end
    end

    describe "#{Web::LANG_URL}" do
      context 'lang selector valid' do
        context 'post-request' do
          before do
            get(Web::ROOT_URL)
            post(Web::LANG_URL, lang: 'ru')
          end

          let(:current_locale) do
            last_request.env['rack.session.options'][:locale].lang
          end

          describe 'scenario' do
            it 'change current locale' do
              expect(current_locale).to eq(:ru)
            end

            specify { status_302 }

            context 'no referer' do
              before { follow_redirect! }

              specify { status_200 }

              it 'load new locale' do
                expect(last_response.body).to include("<html lang=\"ru\">")
              end
            
              it 'render index template' do
                expect(last_response.body).to include("index-template")
              end
            end

            context 'change locale from root path' do
              before do
                allow_any_instance_of(Rack::Request).to receive(:referer).and_return('url_without_double_slash')
                post(Web::LANG_URL, lang: 'ru')
                follow_redirect!
              end

              specify { status_200 }

              it 'load new locale' do
                expect(last_response.body).to include("<html lang=\"ru\">")
              end
            
              it 'render index template' do
                expect(last_response.body).to include("index-template")
              end
            end

            context 'change locale from other places' do
              before do
                allow_any_instance_of(Rack::Request).to receive(:referer).and_return("http://example.com#{Web::SCORES_URL}")
                post(Web::LANG_URL, lang: 'ru')
                follow_redirect!
              end

              specify { status_200 }

              it 'load new locale' do
                expect(last_response.body).to include("<html lang=\"ru\">")
              end
            
              it 'render current template' do
                expect(last_response.body).to include("scores-template")
              end
            end
          end
        end
      end

      context 'lang selector invalid' do
        context 'get-request' do
          before { get(Web::LANG_URL) }

          specify { status_403 }

          it 'render error template' do
            error_template
          end
        end

        context 'post-request' do
          before do
            get(Web::ROOT_URL)
            post(Web::LANG_URL, lang: 'fake')
          end

          specify { status_403 }

          it 'render error template' do
            error_template
          end
        end
      end
    end

    describe "#{Web::PLAY_URL}" do
      context 'game configuration data valid' do
        context 'post-request' do
          before { play_instance }

          context 'session' do
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
            context 'game still going on' do
              it 'load scores' do
                expect(session[:scores]).to be_an_instance_of(Array)
              end

              specify { status_200 }

              it 'render game template' do
                game_template
              end

              it 'motivation message' do
                expect(last_response.body).to include('hideAlert')
              end
            end

            context 'game over' do
              before do
                allow_any_instance_of(Game).to receive(:won?).and_return(true)
              end

              it "GET: '#{Web::FINISH_URL}' 200" do
                get(Web::FINISH_URL)
                status_200
              end
            end

            context 'system error' do
              before { session.clear }

              it "GET: '#{Web::ROOT_URL}' 200" do
                get(Web::ROOT_URL)
                status_200
              end
            end
          end
        end
      end

      context 'game configuration data invalid' do
        context 'get-request' do
          before { get Web::PLAY_URL }

          specify { status_403 }

          it 'render error template' do
            error_template
          end
        end

        context 'post-request' do
          before do
            get(Web::ROOT_URL)
            post(Web::PLAY_URL)
          end

          specify { status_403 }

          it 'render error template' do
            error_template
          end
        end
      end
    end

    describe "#{Web::HINT_URL}" do
      context 'game configuration data valid' do
        context 'get-request' do
          before { play_instance }

          describe 'method call' do
            before do
              allow(session[:game]).to receive(:attempts).and_return(10)
              allow(session[:game]).to receive(:hints).and_return(10)
              get(Web::HINT_URL)
            end

            after { get(Web::HINT_URL) }

            context '#hints_allowed?' do
              specify { expect(session[:game]).to receive(:won?) }
              specify { expect(session[:game]).to receive(:attempts) }
              specify { expect(session[:game]).to receive(:hints) }
            end

            context '#hint' do
              specify { expect(session[:game]).to receive(:hint) }
            end
          end

          describe 'scenario' do
            context 'hints are allowed' do
              before { get(Web::HINT_URL) }

              it 'session: sets player hint' do
                expect(session[:hint]).to be_an_instance_of(Integer)
              end

              it "GET: '#{Web::HINT_URL}' 302" do
                status_302
              end

              context 'next action' do
                before { follow_redirect! }

                it "GET: '#{Web::PLAY_URL}' 200" do
                  status_200
                end

                it 'render hint' do
                  expect(last_response.body).to include('badge badge-light')
                end
              end
            end

            context 'hints are not allowed' do
              before { get(Web::HINT_URL) }
              after { get(Web::HINT_URL) }
              let(:not_receive_hint) { expect(session[:game]).to_not receive(:hint) }

              context 'game won' do
                specify do
                  won_a_game
                  not_receive_hint
                end
              end

              context 'no attempts left' do
                specify do
                  lost_a_game
                  not_receive_hint
                end
              end

              context 'no hints left' do
                specify do
                  use_all_hints
                  not_receive_hint
                end
              end
            end
          end
        end
      end

      context 'game configuration data invalid' do
        context 'get-request' do
          before { get Web::HINT_URL }

          specify { status_403 }

          it 'render error template' do
            error_template
          end
        end
      end
    end

    describe "#{Web::SUBMIT_URL}" do
      let(:valid_user_input) { '1234' }
      let(:invalid_user_input) { 1234 }

      context 'game configuration data valid' do
        before { play_instance }

        context 'post-request' do
          before { post(Web::SUBMIT_URL, number: valid_user_input) }

          describe 'method call' do
            before do
              allow(session[:game]).to receive(:guess_valid?)
            end

            after { post(Web::SUBMIT_URL, number: valid_user_input) }

            it '#guess_valid?' do
              expect(session[:game]).to receive(:won?)
            end
          end

          describe 'session' do
            it 'sets last guess' do
              expect(session[:last_guess]).to eq(valid_user_input)
            end

            it 'sets marker' do
              expect(session[:marker]).to_not be_nil
            end
          end

          describe 'scenario' do
            context 'game over' do
              after { post(Web::SUBMIT_URL, number: valid_user_input) }
              let(:follow_redirect_twice!) { 2.times { follow_redirect! } }

              specify { status_302 }

              context '#save_game_data' do
                let(:yml) { "#{File.expand_path('../lib/data', File.dirname(__FILE__))}" }
                let(:last_saved_object) { GameData.new(yml).send(:load_game_data).last }
                let(:object_token) { last_saved_object.token }
                let(:object_ip) { last_saved_object.ip }

                context 'score object token' do
                  specify { expect(object_token).to_not be_nil }
                end

                context 'score object ip' do
                  specify { expect(object_ip).to_not be_nil }
                end
              end

              context 'game won' do
                before do
                  won_a_game
                  follow_redirect_twice!
                end

                it "GET: '#{Web::FINISH_URL}' 200" do
                  status_200
                end

                it 'render player results' do
                  current_score
                end
              end

              context 'no attempts left' do
                before do
                  lost_a_game
                  follow_redirect_twice!
                end

                it "GET: '#{Web::FINISH_URL}' 200" do
                  status_200
                end

                it 'render player results' do
                  current_score
                end
              end
            end

            context 'game still going on' do
              before { follow_redirect! }

              it 'session: sets hint' do
                expect(session[:hint]).to be(false)
              end

              it "GET: '#{Web::PLAY_URL}' 200" do
                status_200
              end

              it 'render game template' do
                game_template
              end
            end
          end
        end

        context 'get-request' do
          before { get(Web::SUBMIT_URL) }

          specify { status_302 }

          context 'next action' do
            before { follow_redirect! }

            it "GET: '#{Web::PLAY_URL}' 200" do
              status_200
            end

            it 'render game template' do
              game_template
            end
          end
        end
      end

      context 'game configuration data invalid' do
        describe 'post-request' do
          context 'empty session' do
            before { post Web::SUBMIT_URL }
            specify { status_403 }
            specify { error_template }
          end

          context 'fake input' do
            before do
              play_instance
              post(Web::SUBMIT_URL, number: invalid_user_input)
            end

            specify { status_302 }

            context 'next action' do
              before { follow_redirect! }

              it "GET: '#{Web::PLAY_URL}' 200" do
                status_200
              end

              it 'render game template' do
                game_template
              end
            end
          end
        end

        describe 'get-request' do
          before { get Web::SUBMIT_URL }
          specify { status_403 }
          specify { error_template }
        end
      end
    end

    describe "#{Web::FINISH_URL}" do
      context 'game configuration data valid' do
        describe 'get-request' do
          before { play_instance }

          context 'game over' do
            context 'game won' do
              before do
                won_a_game
                get(Web::FINISH_URL)
              end

              it "GET: '#{Web::FINISH_URL}' 200" do
                status_200
              end

              it 'render player results' do
                current_score
              end
            end

            context 'no attempts left' do
              before do
                lost_a_game
                get(Web::FINISH_URL)
              end

              it "GET: '#{Web::FINISH_URL}' 200" do
                status_200
              end

              it 'render player results' do
                current_score
              end
            end
          end

          context 'game still going on' do
            before { get(Web::FINISH_URL) }

            specify { status_302 }

            context 'next action' do
              before { follow_redirect! }

              it "GET: '#{Web::PLAY_URL}' 200" do
                status_200
              end

              it 'render game template' do
                game_template
              end
            end
          end
        end
      end

      context 'game configuration data invalid' do
        describe 'get-request' do
          before { get Web::FINISH_URL }
          specify { status_403 }
          specify { error_template }
        end
      end
    end

    describe "#{Web::SCORES_URL}" do
      describe 'get-request' do
        before { get(Web::SCORES_URL) }

        it 'empty player session' do
          expect(session[:game]).to be_nil
        end

        it 'load scores' do
          expect(session[:scores]).to be_an_instance_of(Array)
        end
        
        specify { status_200 }
        
        it 'render index template' do
          expect(last_response.body).to include('scores-template')
        end

        describe 'scenario' do
          context 'no results' do
            before do
              allow_any_instance_of(Web).to receive(:storage_path).and_return(false)
              get(Web::SCORES_URL)
            end

            specify { expect(last_response.body).to include('empty-scores') }
          end

          context 'results exists' do
            specify { expect(last_response.body).to include('top-scores') }
          end
        end
      end
    end

    describe 'ErrorLogger middleware' do
      before { delete_error_log }
      after  { delete_error_log }

      let(:error_log) { @env.tracking_files.last }
      let(:delete_error_log) { FileUtils.rm(error_log, :force => true) }
      let(:check_log) { expect(File.zero?(error_log)).to_not be(true) }

      describe 'tracked errors' do
        context '403' do
          before { get(Web::PLAY_URL) }
          specify { check_log }
        end
        
        context '404' do
          before { get('/unknown_url') }
          specify { check_log }
        end
      end
    end
  end
end
