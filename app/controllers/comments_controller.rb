class CommentsController < ApplicationController
  before_action :set_topic
  before_action :set_post
  before_action :set_comment, only: [ :edit, :update, :destroy ]
  before_action :authenticate_user!

  def create
    @comment = @post.comments.new(comment_params.merge(user: current_user))

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to topic_post_url(@topic, @post), notice: "Comment was successfully created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("comment_form",
        partial: "comments/form",
        locals: { comment: @comment, topic: @topic, post: @post }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.turbo_stream
        format.html { redirect_to topic_post_url(@topic, @post), notice: "Comment was successfully created." }
      else
        format.turbo_stream
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy
  end

  private

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
