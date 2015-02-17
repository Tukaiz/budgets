module Budgets
  class Railtie < Rails::Railtie

    initializer "my_railtie.configure_rails_initialization" do |app|
      FeatureBase.register(app, Budgets)
    end

    config.after_initialize do
      FeatureBase.inject_feature_record("Budgets",
        "Budgets",
        "Allows a site to checkout with a budget."
      )
      FeatureBase.inject_permission_records(
        Budgets,
        BudgetsFeatureDefinition.new.permissions
      )
    end

  end
end

