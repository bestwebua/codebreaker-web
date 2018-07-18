require 'spec_helper'

module Codebreaker
  RSpec.describe RateTest do
    before(:context) do
      current_yml = "#{File.expand_path('../lib/data/scores.yml', File.dirname(__FILE__))}"
      current_log = "#{File.expand_path('../error.log', File.dirname(__FILE__))}"
      @env = RspecFileChef::FileChef.new(current_yml, current_log)
      @env.make
    end

    after(:context) do
      @env.clear
    end

    describe '#rate' do
      specify { expect(subject.send(:rate, :winner, true)).to eq(0) }
      specify { expect(subject.send(:rate, :winner, false)).to eq(1) }
      specify { expect(subject.send(:rate, :level, Game::HARD_LEVEL)).to eq(0) }
      specify { expect(subject.send(:rate, :level, Game::MIDDLE_LEVEL)).to eq(1) }
      specify { expect(subject.send(:rate, :level, Game::SIMPLE_LEVEL)).to eq(2) }
    end

    describe '#player_rate' do
      context 'score negative' do
        before { subject.token = '9fbdde77-c4a2-41c4-b425-ed9d253ca3ae' }
        specify { expect(subject.send(:player_rate)).to eq(6) }
      end

      context 'score positive' do
        context 'winner' do
          before { subject.token = 'fbe517bc-4718-4a2d-8527-b3e86429d43e' }
          specify { expect(subject.send(:player_rate)).to eq(4) }
        end

        context 'level' do
          before { subject.token = 'fbe517bc-2394-4a2d-8527-v7e86429d43e' }
          specify { expect(subject.send(:player_rate)).to eq(1) }
        end

        context 'score' do
          before { subject.token = 'fbe517bc-4718-4a2d-8527-v7e86429d43e' }
          specify { expect(subject.send(:player_rate)).to eq(3) }
        end
      end
    end
  end
end
