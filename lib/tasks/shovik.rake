# frozen_string_literal: true

namespace :shovik do
  desc "Fail when a rescue clause under app/ or lib/ names an undefined constant or a non-exception"
  task rescue_classes: :environment do
    Rails.application.eager_load!
    paths = Rails.root.glob("{app,lib}/**/*.rb").map(&:to_s)
    violations = Shovik::RescueClassCheck.call(paths, root: Rails.root)
    abort(["shovik:rescue_classes found #{violations.size} problem(s):", *violations].join("\n")) if violations.any?

    puts "shovik:rescue_classes: #{paths.size} files, every rescued constant is an exception class"
  end
end
