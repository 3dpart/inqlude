class Cli < Thor

  default_task :global

  class_option :version, :type => :boolean, :desc => "Show version"

  def self.settings= s
    @@settings = s
  end

  def self.distro= d
    @@distro = d
  end

  desc "global", "Global options", :hide => true
  def global
    if options[:version]
      puts "Inqlude: #{@@settings.version}"

      qmake_out = `qmake -v`
      qmake_out =~ /Qt version (.*) in/
      puts "Qt: #{$1}"

      if @@distro
        puts "OS: #{@@distro.name} #{@@distro.version}"
      else
        puts "OS: unknown"
      end
    else
      Cli.help shell
    end
  end

  desc "list", "List libraries"
  method_option :remote, :type => :boolean, :aliases => "-r",
    :desc => "List remote libraries"
  def list
    handler = ManifestHandler.new @@settings
    handler.read_remote

    if options[:remote]
      handler.manifests.each do |manifest|
        puts manifest["name"] + "-" + manifest["version"]
      end
    else
      manifests = @@distro.installed handler
      manifests.each do |manifest|
        puts manifest["name"]
      end
    end
  end

  desc "view", "Create view"
  method_option :output_dir, :type => :string, :aliases => "-o",
    :desc => "Output directory", :required => true
  def view
    view = View.new ManifestHandler.new @@settings
    view.create options[:output_dir]
  end

  desc "show <library_name>", "Show library details"
  def show name
    get_involved "Add command for showing library details"
  end

  desc "verify", "Verify manifests"
  def verify
    get_involved "Add command for verifying manifests"
  end

  desc "create", "Create manifest"
  method_option :dry_run, :type => :boolean,
    :desc => "Dry run. Don't write files."
  method_option :recreate_source_cache, :type => :boolean,
    :desc => "Recreate cache with meta data of installed RPMs"
  method_option :recreate_qt_source_cache, :type => :boolean,
    :desc => "Recreate cache with meta data of Qt library RPMs"
  def create
    m = RpmManifestizer.new @@settings
    m.dry_run = options[:dry_run]

    if options[:recreate_source_cache]
      m.create_source_cache
    end
    
    if options[:recreate_qt_source_cache]
      m.create_qt_source_cache
    end
    
    m.process_all_rpms
  end

  desc "get_involved", "Information about how to get involved"
  def get_involved
    puts
    puts "If you would like to help with development of the Inqlude tool,"
    puts "have a look at the git repository, in particular the list of open"
    puts "issues: https://github.com/cornelius/inqlude/issues"
    puts
    puts "If you would like to contribute information about a Qt based"
    puts "library, have a look at the git repository containing the library"
    puts "meta data: https://github.com/cornelius/inqlude_data"
    puts
    puts "Your help is appreciated."
    puts
    puts "If you have questions or comments, please let me know:"
    puts "Cornelius Schumacher <schumacher@kde.org>"
    puts
  end

end
