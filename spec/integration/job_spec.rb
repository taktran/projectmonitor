require 'spec_helper'


describe 'Mocks across threads' do
  context 'with code all in one class' do
    class Foo
      attr_accessor :obj

      def initialize(obj)
        self.obj = obj
      end

      def go
        self.obj.execute
        # r, w = IO.pipe
        # fork do
          # puts "Process: #{Process.pid}"
          # self.obj.execute
          # w.puts "hello"
        # end
        # puts "Parent? #{Process.pid}"
        # puts r.gets
      end
    end

    class Worker
      def execute
        sleep 2
      end
    end

  end

  it 'should call execute' do
    
    r,w = IO.pipe

    d = double
    d.should_receive(:execute).and_yield do
      # debugger
      w.puts 'bar'
    end
    f = Foo.new(Worker.new)
    f.go
    r.gets should == 'foo'
  end
end


# describe 'Failing, deferred jobs' do
  # class FailingJob
    # def perform
      # puts 'performed!'
    # end
  # end

  # before do
    # Delayed::Job.delete_all
  # end


  # it 'should be retried 3 times' do
    # debugger

    # j = double
    # j.should_receive(:perform)

    # Delayed::Worker.delay_jobs = true
    # Delayed::Job.enqueue(j)
    # w = Delayed::Worker.new(:quiet => false)
    # w.start
    # w.stop
  # end
# end


# RSpec.configure do |c|
  # c.use_transactional_examples = false
# end

# describe 'Job domain logic' do

  # let(:worker) do
    # Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY'], :queues => (ENV['QUEUES'] || ENV['QUEUE'] || '').split(','), :quiet => false)
  # end

  # before :all do
    # Delayed::Job.delete_all

    # @old_delay_jobs_setting = Delayed::Worker.delay_jobs
    # Delayed::Worker.delay_jobs = true
    # @old_destroy_failed_jobs_setting = Delayed::Worker.destroy_failed_jobs
    # Delayed::Worker.destroy_failed_jobs = false

    # # ActiveRecord::Base.connection_pool.with_connection do
      # # @worker_thread = Thread.new do
        # # worker.start
      # # end
    # # end
    # @worker_thread = Thread.new do
      # connection = ActiveRecord::Base.connection_pool.checkout
      # worker.start
      # ActiveRecord::Base.connection_pool.checkin(connection)
    # end
  # end

  # after :all do
    # Delayed::Worker.delay_jobs = @old_delay_jobs_setting
    # Delayed::Worker.destroy_failed_jobs = @old_destroy_failed_jobs_setting
    # worker.stop
    # # @worker_thread.join
  # end

  # # it 'should increase the interval between failing jobs' do
    # # # FactoryGirl.create(:jenkins_project)
  # # end

  # it 'should attempt a failing job 3 times' do
    # # job = double
    # # job.stub(:perform).and_raise(ArgumentError)
    # # StatusFetcher::Job.stub(:new).and_return(job)
    # Delayed::Job.enqueue(StatusFetcher::Job.new('hello'), priority: 0)


    # # Timeout.timeout(20) do
      # puts "looking for latest job"
      # job = Delayed::Job.last
      # while job.reload.failed_at.nil? do
        # puts job.inspect
        # sleep 0.5
      # end
      # puts "done looking at failed_at"
    # # end

    # puts 'job.failed at was set'

  # end

  # # it 'should notify someone when a job fails for the final time'

# end
