require 'json'

class MongoCommand < Inspec.resource(1)
  name 'mongo_command'
  desc 'Runs a MongoDB command using the mongo CLI against a given database (default database: admin)'
  example <<-EOL
    describe mongo_command('db.showRoles()') do
      its('params.length') { should be > 0 }
    end
    EOL

  attr_reader :command, :database, :params

  def initialize(command, options = {})
    @command           = command
    @username          = options[:username]
    @password          = options[:password]
    @database          = options.fetch(:database, 'admin')
    @allow_auth_errors = options.fetch(:allow_auth_errors, false)
    @verify_ssl        = options.fetch(:verify_ssl, true)

    check_for_cli_command
    @inspec_command = run_mongo_command(command)
    @params = parse(@inspec_command.stdout)
  end

  def stdout
    @inspec_command.stdout
  end

  def stderr
    @inspec_command.stderr
  end

  def to_s
    str = "MongoDB Command (#{@command}"
    str += ", username: #{@username}" unless @username.nil?
    str += ", password: <hidden>" unless @password.nil?
    str += ')'

    str
  end

  private

  def parse(output)
    # return right away if stdout is nil
    return [] if output.nil?

    # strip any network warnings from the output
    # Unfortunately, it appears the --sslAllowInvalidHostnames doesn't actually squelch
    # any warnings, even when using --quiet mode
    output_lines = output.lines.delete_if { |line| line.include?(' W NETWORK ')}

    # if, after removing any network warnings, there are no lines to process,
    # we received no command output.
    return [] if output_lines.empty?

    # put our output back together as a string
    output = output_lines.join

    # skip the whole resource if we could not run the command at all
    return skip_resource "User is not authorized to run command #{command}" if 
      is_auth_error?(output) && !auth_errors_allowed?

    # if the output indicates there's an authorization error, and we allow auth
    # errors, we won't throw an exception, just set the params to an empty array.
    return [] if is_auth_error?(output) && auth_errors_allowed?

    # At this point, we should have parseable JSON we can use and no auth errors.
    # Let's read it in.
    JSON.parse(output)
  rescue JSON::ParserError => e
    skip_resource "Unable to parse JSON response from mongo client: #{e.message}" unless @allow_auth_errors
    []
  end

  def check_for_cli_command
    check_command = inspec.command(format_command("db.version()"))
    if check_command.exit_status != 0
      skip_resource "Unable to run mongo commands: #{check_command.stderr}"
    end
  end

  def run_mongo_command(command)
    inspec.command(format_command(command))
  end

  def ssl_verify_disabled?
    ['false', false].include?(@verify_ssl)
  end

  def is_auth_error?(output)
    output.include?('Error: not authorized')
  end

  def auth_errors_allowed?
    @allow_auth_errors == true
  end

  def format_command(command)
    command = %{echo "#{command}" | mongo --quiet #{database} --ssl}
    command += " --username #{@username}" unless @username.nil?
    command += " --password #{@password}" unless @password.nil?
    command += " --sslAllowInvalidCertificates" if ssl_verify_disabled?
    command += " --sslAllowInvalidHostnames" if ssl_verify_disabled?
    command
  end
end
