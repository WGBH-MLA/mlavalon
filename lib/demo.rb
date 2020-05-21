require 'avalon/role_controls'

# Module used for setting up demo.
#   * Intended for use in development environment.
#   * Use of class instance variables is not thread safe!
module Demo
  class << self
    def user
      @user ||= find_or_create_user 'woo@foo.edu'
    end

    def api_host
      '0.0.0.0'
    end

    def api_port
      3000
    end

    def api_token
      # Don't memoize. Depends on the state of the user, which may change.
      ApiToken.find_or_create_by(username: user.username, email: user.email, token: '9fcee031d3f8daeb26f320b9f2e7927fc4261b667de8cc3706a9dcfec04b411414fee426140d3333819b064c9e74ee322bf81ae7524722d669c92d2e33724314').token
    end

    def reset_user
      delete_user @user.username if @user
      @user = nil
    end

    private

      def find_or_create_user(username)
        User.where(username: username).first || create_user(username: username)
      end

      # Lifted from avalon.rake. The rake task should probably use a library
      # like this for consistency outside of rake tasks.
      def create_user(username:, password: 'pppppp', groups: [ 'administrator' ])
        # Ensure the User and Roles are gone before explicitly creating.
        delete_user(username)
        user = User.create!(username: username, email: username, password: 'pppppp', password_confirmation: 'pppppp')
        groups.each do |group|
          Avalon::RoleControls.add_role(group) unless Avalon::RoleControls.role_exists? group
          Avalon::RoleControls.add_user_role(username, group)
        end
        user
      end

      # Lifted from avalon.rake. The rake task should probably use a library
      # like this for consistency outside of rake tasks.
      def delete_user(username)
        groups = Avalon::RoleControls.user_roles username
        User.where(Devise.authentication_keys.first => username).destroy_all
        groups.each do |group|
          Avalon::RoleControls.remove_user_role(username, group)
        end
      end
  end
end
