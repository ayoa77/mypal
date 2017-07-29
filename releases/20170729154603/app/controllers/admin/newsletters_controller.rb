require 'gun_mailer'

class Admin::NewslettersController < AdminController

  def index
    @newsletters = Newsletter.all.order(:id)
  end

  def show
    @newsletter = Newsletter.find_by(id: params[:id])
    render template: "gun_mailer/newsletter", layout: "email", locals: {name_to: current_user.name, newsletter: @newsletter, unsubscribe_token: EmailSetting.getToken(current_user.email, :newsletters), settings: @settings}
  end

  def new
    @newsletter = Newsletter.new
  end

  def edit
    @newsletter = Newsletter.find_by(id: params[:id], sent: false)
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)
    if @newsletter.save
      flash[:notice] = "New newsletter #{@newsletter.subject} created"
      redirect_to admin_newsletters_path
    else
      flash[:alert] = "Creating newsletter failed"
      render :new
    end
  end

  def update
    @newsletter = Newsletter.find_by(id: params[:id], sent: false)
    if @newsletter.update_attributes(newsletter_params)
      flash[:notice] = "Newsletter #{@newsletter.subject} updated"
      redirect_to admin_newsletters_path
    else
      flash[:alert] = "Updating newsletter failed"
      render :edit
    end
  end

  def send_me
    @newsletter = Newsletter.find_by!(id: params[:id], sent: false)
    GunMailer.send_newsletter current_user, @newsletter
    flash[:notice] = "Newsletter #{@newsletter.subject} send to yourself"
    redirect_to admin_newsletters_path
  end

  def send_admin
    @newsletter = Newsletter.find_by!(id: params[:id], sent: false)
    users = User.where(admin: true)
    users.each do |u|
      GunMailer.send_newsletter u, @newsletter
    end
    flash[:notice] = "Newsletter #{@newsletter.subject} send to #{users.count} admins"
    redirect_to admin_newsletters_path
  end

  def send_everybody
    @newsletter = Newsletter.find_by!(id: params[:id], sent: false)
    @newsletter.update_attributes(sent: true)
    users = User.where(enabled: true)
    users.each do |u|
      GunMailer.send_newsletter u, @newsletter
    end
    flash[:notice] = "Newsletter #{@newsletter.subject} send to #{users.count} users"
    redirect_to admin_newsletters_path
  end

  private

  def newsletter_params
    params.require(:newsletter).permit(:subject, :intro, :content)
  end

end