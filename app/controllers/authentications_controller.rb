class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by(provider: omniauth['provider'], uid: omniauth['uid'])
    if authentication
      session[:id] = authentication.user_id
      redirect_to user_path(authentication.user_id)
    elsif current_user
      current_user.authentications.create!(provider: omniauth['provider'], uid: omniauth['uid'])
      current_user.update_attributes(omniauth['provider'] => omniauth['info']['nickname'])
      flash[:notice] = "Successfully added #{omniauth['provider']} authentication"
      redirect_to user_path(current_user.id)
    else
      user = User.new(first_name: omniauth['info']['name'], omniauth['provider'] => omniauth['info']['nickname'], remote_avatar_url: (omniauth['info']['image'].to_s.gsub(/_normal/, '')))
      user.authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
      user.save(validate: false)
      session[:id] = user.id
      redirect_to user_path(user.id)
    end
  end

  def destroy
    @authentications = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = 'Successfully destroyed authentication'
    redirect_to users_path
  end
end
