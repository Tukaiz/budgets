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
          name: 'Can Manage All Budgets'
        },
        {
          can: true,
          callback_name: 'can_create_budgets',
          name: 'Can Create Budgets'
        },
        {
          can: true,
          callback_name: 'can_manage_budget_groups',
          name: 'Can Manage All Budget Groups'
        },
        {
          can: true,
          callback_name: 'can_create_budget_groups',
          name: 'Can Create Budget Groups'
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

      def can_create_budgets
        can :access_budgets_section, Budget
        can :create, Budget
        can :update, Budget, id: @user.id
      end

      def can_manage_budget_groups
        can :manage, BudgetGroup
      end

      def can_create_budget_groups
        can :access_budget_groups_section, BudgetGroup
        can :create, BudgetGroup
      end


      ## This will likely be used to define budgets accessible at checkout
      def can_access_child_budgets_associated_throu_budget_groups
        UserEditContext.call(@user, @site)
        budget_ids = @user.full_claims.flat_map do |claim|
          claim.budget_groups
        end.flat_map{ |bg| bg.budget_ids }
        can :read, Budget, id: budget_ids
      end

      ## budgets accessible for one-off users added via admin/budgets interface
      def can_manage_budgets_assocated_from_budget_users
        ids = BudgetUser.where(user_id: @user.id).map { |bu| bu.budget_id }
        if ids.any?
          can :read, Budget, id: ids
        end
      end

      ## managers assocated from the admin/budgets interface
      def can_manage_budgets_assocated_from_budget_managers
        ids = BudgetManager.where(manager_id: @user.id).map { |bu| bu.budget_id }
        if ids.any?
          can :access_budgets_section, Budget
          can :read, Budget, id: ids
        end
      end

    end
  end

end

require 'budgets/railtie' if defined?(Rails)
