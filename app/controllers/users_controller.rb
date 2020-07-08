class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show

  def index
    @users = User.all
    @users = User.paginate(page: params[:page])
    #@users = query
    # パラメータとして名前か性別を受け取っている場合は絞って検索する
    if params[:name].present?
    @users = @users.get_by_name params[:name]
    end
  end
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    # データを閲覧する画面を表示するためのAction
    @user = User.find(params[:id]) 
  end

  def new
    @user = User.new
    
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user.destroy
    @user = User.find(params[:id])
    flash[:success] = "#{@user.name}のデータを削除しました。"
    @user.destroy
    redirect_to users_path
  end

  def edit_basic_info
    
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  private
  
    def admin_user
    redirect_to root_path unless current_user.admin?
    end 

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end

    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end
    
    #def search
      #if params[:name].present?
       # @users = User.where('name LINK ?', "%#{params[:name]}%")
     # else
        #@users = User.none
     # end 
   # end
    
   def query
      if params[:user].present? && params[:user][:name]
       User.were('LOWR(name) LIKE ?', "%#{params[:user][:name]}%")
      else
        User.all
      end
   end
end