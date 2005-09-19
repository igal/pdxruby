class MembersController < ApplicationController
  
  before_filter :authenticate, :except => [ :login, :new, :create ]
  before_filter :member_is_this_member!, :only => [ :edit, :update ]
  before_filter :member_exists!, :only => [ :show ]
  
  def index
    redirect_to :action => 'login'
  end

  def show
    @member = Member.find(params[:id])
    @participations = @member.participants
  end

  def list
    @members = Member.find :all, :order => "name"
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(params[:member])
    if !check_passwords_match
      flash[:notice] = 'Passwords do not match'
      render :action => 'new'
      return
    end
    if @member.save
      flash[:notice] = 'Member was successfully created.'
      session[:member] = @member
      redirect_to :action => 'show', :id => @member.id
    else
      render :action => 'new'
    end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
    if !check_passwords_match
      flash[:notice] = 'Passwords do not match'
      render :action => 'edit'
      return
    end
    if @member.update_attributes(params[:member])
      flash[:notice] = 'Member was successfully updated.'
      redirect_to :action => 'show', :id => @member
    else
      render :action => 'edit'
    end
  end
  
  def login
    if request.get?
      if session[:member]
        redirect_to :action => 'show', :id => session[:member]
      end
    elsif request.post?
      email = params[:member][:email]
      password = params[:member][:password]
      member = Member.find_by_email(email)
      if member.nil?
        flash[:notice] = "That member doesn't exist."
      else
        if password != member.password
          flash[:notice] = "Wrong password."
        else
          session[:member] = member
          redirect_to :action => 'show', :id => member
        end
      end
    end
  end
  
  def logout
    reset_session
    flash[:notice] = "You are logged out."
    redirect_to :action => 'login'
  end
  
  private
  
  def check_passwords_match
    if params[:member][:password] != params[:verify_password]
      return false
    end
    return true
  end

  def member_exists!
    requested_member = member_exists? params[:id]
    if requested_member.nil?
      flash[:notice] = "That Member Doesn't Exist. Try Again."
      redirect_to :action => 'list'
    end
  end
  
  def member_is_this_member!
    if !member_is_this_member? params[:id]
      flash[:notice] = "No Peeking."
      redirect_to :action => 'list'
    end
  end

end
