require 'fileutils'
require 'yaml'
require 'json'

require_relative './utilities/common'
require_relative './utilities/generate'

desc 'Generate Terraform DNS configuration'
task :generate_terraform do
  Dir.mkdir(TMP_DIR) unless File.exist?(TMP_DIR)

  # Clean the tmp-dir
  files = Dir["./#{TMP_DIR}/*/*.tf"]
  files << Dir["./#{TMP_DIR}/*.tf"]
  if ! files.empty?
    FileUtils.rm files
  end

  # Load configuration
  config_file = YAML.load_file(zonefile)
  records = config_file['records']
  deployment = config_file['deployment']

  # Render all the expected files
  providers.each { |current_provider|
    abort("Must set deployment options in configuration file") if deployment[current_provider.to_sym].empty?

    deploy_vars = deployment[current_provider.to_sym]

    out = generate_terraform_object(current_provider, records, deploy_vars)

    provider_dir = "#{TMP_DIR}/#{current_provider}"
    Dir.mkdir(provider_dir) unless File.exist?(provider_dir)
    # Use pretty_generate so the JSON is still vaguely human readable
    File.write("#{provider_dir}/zone.tf", JSON.pretty_generate(out))
  }
end
