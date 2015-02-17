require "budgets/version"

module Budgets
  # This will be executed in the ability class, by defalut, if the Feature is enabled.
  class Default
    def self.permissions
      [
        "can_access_child_budgets_associated_throu_budget_groups",
        "can_manage_budgets_assocated_from_budget_managers",
        "can_manage_budgets_assocated_from_budget_users"
      ]
    end
  end

  class BudgetsFeatureDefinition
    include FeatureSystem::Provides
    def permissions
      [
        {
          can: true,
          callback_name: 'can_manage_budgets',
          name: 'Can Manage Budgets'
        }
      ]
    end
  end

  module Authorization
    module Permissions

      ## permission to grant access to all budgets
      def can_manage_budgets
        can :manage, Budget
      end

      ## This will likely be used to define budgets accessible at checkout
      def can_access_child_budgets_associated_throu_budget_groups
        UserEditContext.call(@user, @site)
        budget_ids = @user.full_claims.flat_map do |claim|
          claim.budget_groups
        end.flat_map{ |bg| bg.budget_ids }
        can :read, Budget, id: budget_ids
      end

      ## users assocated from the admin/budgets interface
      def can_manage_budgets_assocated_from_budget_users
        can :read, Budget, id: BudgetUser.where(user_id: @user.id).map { |bu| bu.budget_id }
      end

      ## managers assocated from teh admin/budgets interface
      def can_manage_budgets_assocated_from_budget_managers
        ## budgets created by the user
        can :manage, Budget, user_id: @user.id
        can :read, Budget, id: BudgetManager.where(manager_id: @user.id).map { |bu| bu.budget_id }
      end

    end
  end

end

require 'budgets/railtie' if defined?(Rails)
