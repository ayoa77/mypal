namespace :translations do
  desc "Export translations"
  task export: :environment do
    begin
      Rake::Task["tmp:clear"].invoke
    rescue => err
      ExceptionNotifier.notify_exception(err)
    end
    begin
      Rake::Task["i18n:js:export"].invoke
    rescue => err
      ExceptionNotifier.notify_exception(err)
    end
  end

end
