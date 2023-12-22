# frozen_string_literal: true

require 'mina/rails'
require 'mina/git'

set :application_name, 'asdf_mina'
set :domain, 'ec2-3-137-223-113.us-east-2.compute.amazonaws.com'
set :deploy_to, '/home/ubuntu/asdf_mina'
set :repository, 'git@github.com:DougNeo/asdf_mina.git'
set :branch, 'main'
set :user, 'ubuntu'
set :ssh_options, '-i /home/doug/.ssh/Chave_EC2_Amazon.pem'
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log', 'tmp']

task :asdf_install do
  comment %{Realizando a instalação do Asdf na maquina remota}
  command %{sudo apt-get update}
  command %{sudo apt-get install -y git}
  command %{git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1}
  command %{echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc}
  command %{echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc}
  command %{source ~/.bashrc}
  comment %{Concluido a instalação do Asdf na maquina remota}
end

task :asdf_install_node do
  comment %{Realizando a instalação do Node na maquina remota}
  invoke :'asdf:load'
  command %{asdf plugin-add nodejs}
  command %{asdf install nodejs latest}
  command %{asdf global nodejs latest}
  command %{node -v}
  comment %{Concluido a instalação do Node na maquina remota}
end

task :'asdf:load' do
  comment %{Loading asdf}
  command %{. $HOME/.asdf/asdf.sh}
  command %{
    if ! which asdf >/dev/null; then
      echo "! asdf not found"
      echo "! If asdf is installed, check your :asdf_path setting."
      exit 1
    fi
  }
end

task :version_ruby do
  invoke :'asdf:load'
  command %{asdf local ruby 3.2.2}
  command %{ruby -v}
end

task :setup_ruby do
  comment %{Realizando a instalação do Ruby na maquina remota}
  # command %{sudo apt-get update}
  # command %{sudo apt-get install -y autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev}
  invoke :'asdf:load'
  command %{asdf plugin-add ruby}
  command %{asdf install ruby 3.1.3}
  command %{asdf global ruby 3.1.3}
  command %{gem install bundler}
  comment %{Concluido a instalação do Ruby na maquina remota}
end


task :setup do
end

desc 'Deploys the current version to the server.'
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    invoke :'asdf:load'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    # invoke :'rails:db_migrate'
    # invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %(mkdir -p tmp/)
        command %(touch tmp/restart.txt)
      end
    end
  end
end