desc "provides example field partials (with and without errors) to app/views/forms"
namespace :form_assistant do
  task :install do
    RAILS_ROOT  = Object.const_defined?(:Rails) && Rails.respond_to?(:root) ? Rails.root : RAILS_ROOT
    PLUGIN_ROOT = File.join(File.dirname(__FILE__), '..')
    VIEW_PATH   = File.join(RAILS_ROOT, 'app', 'views')
    DESTINATION = File.join(VIEW_PATH, 'forms')
    
    FileUtils.mkpath(DESTINATION) unless File.directory?(DESTINATION)
    forms = Dir[File.join(PLUGIN_ROOT, 'forms/*')].select { |f| File.file?(f) }
    longest_filename = forms.inject([]) { |sizes, f| sizes << f.gsub(PLUGIN_ROOT, '').length }.max

    forms.each do |partial|
      file_to_copy = File.join(DESTINATION, '/', File.basename(partial))
      puts " - form_assistant%-#{longest_filename}s copied to %s" % 
        [partial.gsub(PLUGIN_ROOT, ''), DESTINATION.gsub(RAILS_ROOT, '')]
      FileUtils.cp [partial], DESTINATION    
    end
  end
end