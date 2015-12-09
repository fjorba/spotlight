module Spotlight
  ##
  # Default Spotlight CanCan abilities
  module Ability
    include CanCan::Ability

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def initialize(user)
      user ||= Spotlight::Engine.user_class.new

      alias_action :process_import, to: :import

      can :manage, :all if user.superadmin?

      # exhibit admin
      can [:update, :import, :export, :destroy], Spotlight::Exhibit, id: user.admin_roles.pluck(:exhibit_id)
      can :manage, [Spotlight::BlacklightConfiguration, Spotlight::Role], exhibit_id: user.admin_roles.pluck(:exhibit_id)

      can :manage, PaperTrail::Version if user.roles.any?

      # exhibit curator
      can :manage, [
        Spotlight::Attachment,
        Spotlight::Search,
        Spotlight::Resource,
        Spotlight::Page,
        Spotlight::Contact,
        Spotlight::CustomField], exhibit_id: user.roles.pluck(:exhibit_id)

      can :manage, Spotlight::Lock, by: user

      can [:read, :curate, :tag], Spotlight::Exhibit, id: user.roles.pluck(:exhibit_id)

      # public
      can :read, Spotlight::HomePage
      can :read, Spotlight::Exhibit, published: true
      can :read, Spotlight::Page, published: true
      can :read, Spotlight::Search, published: true
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
