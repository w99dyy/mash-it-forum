class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_topic
  before_action :set_post
  before_action :check_topic_lock, only: %i[ create ]
  before_action :set_comment, only: [ :edit, :update, :destroy, :pin, :unpin ]

  def create
    if @post.locked?
      redirect_back fallback_location: [@topic, @post], alert: "This post is locked. You can't comment."
      return
    end

    @comment = @post.comments.new(comment_params.merge(user: current_user))

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to topic_post_url(@topic, @post), notice: "Comment was successfully created." }
      else
        format.turbo_stream
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

  def pin
    @comment.pin!
    redirect_back fallback_location: [ @topic, @post, @comment ], notice: "Comment pinned!"
    end

  def unpin
    @comment.unpin!
    redirect_back fallback_location: [ @topic, @post, @comment ], notice: "Comment unpinned!"
  end

  private

  def set_topic
    @topic = Topic.friendly.find(params[:topic_slug])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_post
    @post = Post.friendly.find(params[:post_slug])
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id, :quoted_comment_id)
  end

  def check_topic_lock
    if @topic.locked?
      redirect_back fallback_location: [ @topic, @post ], alert: "This topic is locked, you can't comment to this post"
    end
  end
end
