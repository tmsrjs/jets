require "thor"

class Jets::Commands::Base < Thor
  class << self
    # Track all command subclasses.
    def subclasses
      @subclasses ||= []
    end

    def inherited(base)
      super

      if base.name
        self.subclasses << base
      end
    end

    # useful for help menu
    def eager_load!
      path = File.expand_path("../../", __FILE__)
      Dir.glob("#{path}/commands/**/*.rb").each do |path|
        next if path =~ /templates/
        require path
      end
    end

    # Fully qualifed task names. Examples:
    #   build
    #   process:controller
    #   dynamodb:migrate:down
    def namespaced_commands
      eager_load!
      subclasses.map do |klass|
        klass.all_tasks.keys.map do |task_name|
          klass = klass.to_s.sub('Jets::Commands::','')
          namespace = klass =~ /^Main/ ? nil : klass.underscore.gsub('/',':')
          [namespace, task_name].compact.join(':')
        end
      end.flatten.sort
    end

    # thor_args is an array of commands. Examples:
    #   ["help"]
    #   ["dynamodb:migrate"]
    #
    # Same signature as RakeCommand.perform.  Not using full_command.
    def perform(full_command, thor_args)
      config = {} # doesnt seem like config is used
      dispatch(nil, thor_args, nil, config)
    end
  end
end
