require 'sidekiq'
require 'sidekiq/worker'

module Sidekiq::Worker::ClassMethods
  def perform_async(*args)
    @host_specific_worker ||= get_sidekiq_options["host_specific"]

    if @host_specific_worker
      perform_async_on_host current_hostname, *args
    else
      client_push('class' => self, 'args' => args)
    end
  end

  def perform_async_on_host(host, *args)
    client_push('class' => self, 'args' => args, 'queue' => queue_for_host(host))
  end

  def perform_async_on_current_host(*args)
    client_push('class' => self, 'args' => args, 'queue' => queue_for_host(current_hostname))
  end

  def perform_in_on_host(interval, host, *args)
    int = interval.to_f
    ts = (int < 1_000_000_000 ? Time.now.to_f + int : int)
    client_push('class' => self, 'args' => args, 'at' => ts, 'queue' => queue_for_host(host))
  end
  alias_method :perform_at_on_host, :perform_in_on_host

  def queue_for_host(host)
    worker_queue = get_sidekiq_options['queue']
    "#{worker_queue}_host_#{host}"
  end

  def current_hostname
    @current_hostname ||= `hostname`.strip
  end
end