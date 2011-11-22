class Admin::UsersController < ApplicationController

  # TODO should only be available to admins

  def index
    @users = User.order(:email)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated successfully."
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def new
    @user = User.new
  end

  def create 
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "New user created."
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "User deleted."
    redirect_to :action => 'index'
  end

end
