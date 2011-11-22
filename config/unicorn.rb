working_directory "/var/rails/biofab-web"
pid "/var/rails/biofab-web/tmp/pids/unicorn.pid"
stderr_path "/var/rails/biofab-web/log/unicorn.log"
stdout_path "/var/rails/biofab-web/log/unicorn.log"

preload_app true

listen "/var/rails/biofab-web/tmp/unicorn.sock"
worker_processes 2
timeout 30
