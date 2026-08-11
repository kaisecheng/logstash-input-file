# encoding: utf-8
require 'stud/temporary'
require_relative 'spec_helper'
require 'filewatch/sincedb_collection'

module FileWatch
  describe SincedbCollection do
    let(:sincedb_path) { Stud::Temporary.pathname }
    let(:now) { Time.now.to_f }
    let(:expired_key) { InodeStruct.new('expired', 1, 1) }
    let(:active_key) { InodeStruct.new('active', 1, 1) }
    let(:settings) do
      Settings.from_options(
        :sincedb_path => sincedb_path,
        :sincedb_clean_after => 3600,
        :sincedb_write_interval => 0
      )
    end

    subject(:collection) { described_class.new(settings) }

    before do
      collection.set(expired_key, SincedbValue.new(42, now - 7200))
      collection.set(active_key, SincedbValue.new(99, now))
      collection.flush_at_interval
    end

    it 'removes expired entries from the collection' do
      expect(collection.keys).to contain_exactly(active_key)
    end

    it 'does not persist expired entries' do
      expect(File.read(sincedb_path)).to eq("#{active_key} 99 #{now}\n")
    end
  end
end
