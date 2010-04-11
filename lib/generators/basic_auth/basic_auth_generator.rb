class BasicAuthGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      
      # Controller
      m.file "lib/basic_auth.rb", "lib/basic_auth.rb"
      m.file "controllers/user_controller.rb", "app/controllers/user_controller.rb" 

      # Models
      m.file "models/user.rb", "app/models/user.rb"
      m.file "models/notifications.rb", "app/models/notifications.rb"

      # Tests
      m.file "test/unit/user_test.rb", "test/unit/user_test.rb"
      m.file "test/functional/user_controller_test.rb", "test/functional/user_controller_test.rb"
      m.file "test/fixtures/users.yml", "test/fixtures/users.yml"

      # Views. 
      m.directory "app/views/notifications"
      m.directory "app/views/user"
      m.file "views/user/login.rhtml", "app/views/user/login.rhtml"
      m.file "views/user/signup.rhtml", "app/views/user/signup.rhtml"
      m.file "views/user/change_password.rhtml", "app/views/user/change_password.rhtml"
      m.file "views/user/forgot_password.rhtml", "app/views/user/forgot_password.rhtml"
      m.file "views/user/hidden.rhtml", "app/views/user/hidden.rhtml"
      m.file "views/user/hidden.rhtml", "app/views/user/welcome.rhtml"

      m.file "views/notifications/forgot_password.rhtml", "app/views/notifications/forgot_password.rhtml"

      
      m.migration_template "migrate/create_users.rb", "db/migrate"

      m.readme "INSTALL"
    end
  end
  
  def file_name
    "create_users"
  end

end
