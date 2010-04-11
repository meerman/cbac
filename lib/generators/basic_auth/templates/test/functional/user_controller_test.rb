require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase

  self.use_instantiated_fixtures  = true

  fixtures :users

  def setup
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
  end

  def test_auth_bob
    #check we can login
    post :login, :user=> { :login => "bob", :password => "test" }
    assert(@response.has_session_object?(:user))
    assert_equal @bob, session[:user]
    assert_response :redirect
    assert_redirected_to :action=>'welcome'
  end

  def test_signup
    #check we can signup and then login
    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com" }
    assert_response :redirect
    assert_not_nil session[:user]
    assert(@response.has_session_object?(:user))
    assert_redirected_to :action=>'welcome'
  end

  def test_bad_signup
    #check we can't signup without all required fields
    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "wrong" , :email => "newbob@mcbob.com"}
    assert_response :success
    assert(find_record_in_template("user").errors.invalid?("password"))
    assert_template "user/signup"
    assert_nil session[:user]

    post :signup, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "newpassword" , :email => "newbob@mcbob.com"}
    assert_response :success
    assert(find_record_in_template("user").errors.invalid?(:login))
    assert_template "user/signup"
    assert_nil session[:user]

    post :signup, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "wrong" , :email => "newbob@mcbob.com"}
    assert_response :success
    assert(find_record_in_template("user").errors.invalid?("login"))
    assert(find_record_in_template("user").errors.invalid?("password"))
    assert_template "user/signup"
    assert_nil session[:user]
  end

  def test_invalid_login
    #can't login with incorrect password
    post :login, :user=> { :login => "bob", :password => "not_correct" }
    assert_response :success
    assert(! @response.has_session_object?(:user))
    assert flash[:warning]
    assert_template "user/login"
  end

  def test_login_logoff
    #login
    post :login, :user=>{ :login => "bob", :password => "test"}
    assert_response :redirect
    assert(@response.has_session_object?(:user))
    #then logoff
    get :logout
    assert_response :redirect
    assert(! @response.has_session_object?(:user))
    assert_redirected_to :action=>'login'
  end

  def test_forgot_password
    #we can login
    post :login, :user=>{ :login => "bob", :password => "test"}
    assert_response :redirect
    assert(@response.has_session_object?(:user))
    #logout
    get :logout
    assert_response :redirect
    assert(! @response.has_session_object?(:user))
    #enter an email that doesn't exist
    post :forgot_password, :user => {:email=>"notauser@doesntexist.com"}
    assert_response :success
    assert(! @response.has_session_object?(:user))
    assert_template "user/forgot_password"
    assert flash[:warning]
    #enter bobs email
    post :forgot_password, :user => {:email=>"exbob@mcbob.com"}   
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action=>'login'
  end

  def test_login_required
    #can't access welcome if not logged in
    get :welcome
    assert flash[:warning]
    assert_response :redirect
    assert_redirected_to :action=>'login'
    #login
    post :login, :user=>{ :login => "bob", :password => "test"}
    assert_response :redirect
    assert(@response.has_session_object?(:user))
    #can access it now
    get :welcome
    assert_response :success
    assert flash.empty?
    assert_template "user/welcome"
  end

  def test_change_password
    #can login
    post :login, :user=>{ :login => "bob", :password => "test"}
    assert_response :redirect
    assert(@response.has_session_object?(:user))
    #try to change password
    #passwords dont match
    post :change_password, :user=>{ :password => "newpass", :password_confirmation => "newpassdoesntmatch"}
    assert_response :success
    assert(find_record_in_template("user").errors.invalid?("password"))
    #empty password
    post :change_password, :user=>{ :password => "", :password_confirmation => ""}
    assert_response :success
    assert(find_record_in_template("user").errors.invalid?("password"))
    #success - password changed
    post :change_password, :user=>{ :password => "newpass", :password_confirmation => "newpass"}
    assert_response :success
    assert flash[:message]
    assert_template "user/change_password"
    #logout
    get :logout
    assert_response :redirect
    assert(! @response.has_session_object?(:user))
    #old password no longer works
    post :login, :user=> { :login => "bob", :password => "test" }
    assert_response :success
    assert(! @response.has_session_object?(:user))
    assert flash[:warning]
    assert_template "user/login"
    #new password works
    post :login, :user=>{ :login => "bob", :password => "newpass"}
    assert_response :redirect
    assert(@response.has_session_object?(:user))
  end

  def test_return_to
    #cant access hidden without being logged in
    get :hidden
    assert flash[:warning]
    assert_response :redirect
    assert_redirected_to :action=>'login'
    assert(@response.has_session_object?(:return_to))
    #login
    post :login, :user=>{ :login => "bob", :password => "test"}
    assert_response :redirect
    #redirected to hidden instead of default welcome
    assert_redirected_to 'user/hidden'
    assert(! @response.has_session_object?(:return_to))
    assert(@response.has_session_object?(:user))
    assert flash[:message]
    #logout and login again
    get :logout
    assert(! @response.has_session_object?(:user))
    post :login, :user=>{ :login => "bob", :password => "test"}
    assert_response :redirect
    #this time we were redirected to welcome
    assert_redirected_to :action=>'welcome'
  end
  
end
