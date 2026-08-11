# encoding: utf-8
require_relative 'spec_helper'
require 'filewatch/watch'

module FileWatch
  describe Watch do
    let(:watched_files) { double('watched files', :empty? => true, :close_all => nil) }
    let(:discoverer) { double('discoverer', :watched_files_collection => watched_files) }
    let(:processor) { double('processor', :add_watch => nil, :initialize_handlers => nil) }
    let(:settings) do
      double(
        'settings',
        :discover_interval => 2,
        :exit_after_read => false,
        :stat_interval => 0
      )
    end
    let(:sincedb_collection) { double('sincedb collection', :write_if_requested => nil, :flush_at_interval => nil) }
    let(:observer) { double('observer') }

    subject(:watch) { described_class.new(discoverer, processor, settings) }

    it 'flushes sincedb after each sleep interval' do
      allow(watch).to receive(:sleep) { watch.quit }

      watch.subscribe(observer, sincedb_collection)

      expect(sincedb_collection).to have_received(:flush_at_interval).once
    end
  end
end
