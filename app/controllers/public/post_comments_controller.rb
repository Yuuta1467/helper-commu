class Public::PostCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def edit
    @post = Post.find(params[:post_id])
    @post_comment = PostComment.find(params[:id])

  end

  def create
    @post = Post.find(params[:post_id])
    @comment = current_user.post_comments.new(post_comment_params)
    # 自然言語API機能
    @comment.score = Language.get_data(post_comment_params[:comment])
    @comment.post_id = @post.id
    @comment.save
    #redirect_back(fallback_location: root_path)
      #非同期通信のためコメントアウト　redirect_to post_path(@post)
  end

  def update
    @post = Post.find(params[:post_id])
    @post_comment = PostComment.find(params[:id])
    # 自然言語API機能
    @post_comment.score = Language.get_data(post_comment_params[:comment])
    if @post_comment.update(post_comment_params)
      redirect_to @post, notice: "変更を保存しました。"
    else
      render "edit"
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post_comment = @post.post_comments.find(params[:id])
    @post_comment.destroy
    redirect_back(fallback_location: root_path)
    #非同期通信一時
  end

  private

  def post_comment_params
    params.require(:post_comment).permit(:comment, :post_id)
  end

  def ensure_correct_user
     @post_comment = PostComment.find(params[:id])
    unless @post_comment.user == current_user
     redirect_to posts_path
    end
  end

end
