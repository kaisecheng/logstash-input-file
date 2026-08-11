# encoding: utf-8
require 'timeout'
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

    it 'flushes sincedb after a sleep interval' do
      sleep_started = Queue.new
      sleep_release = Queue.new
      allow(watch).to receive(:sleep) do
        sleep_started << true
        sleep_release.pop
      end

      run_thread = Thread.new do
        Thread.current.abort_on_exception = true
        watch.subscribe(observer, sincedb_collection)
      end

      begin
        Timeout.timeout(30) { sleep_started.pop }
      ensure
        watch.quit
        sleep_release << true
      end

      expect(run_thread.join(30)).not_to be_nil
      expect(sincedb_collection).to have_received(:flush_at_interval).once
    end
  end
end
