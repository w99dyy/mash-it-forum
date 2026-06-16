class PostsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_topic, only: %i[ index new create show edit update destroy pin unpin lock unlock]
  before_action :set_post, only: %i[ show edit update destroy pin unpin lock unlock]
  before_action :require_admin, only: %i[ pin unpin lock unlock ]

  # GET /posts or /posts.json
  def index
    @posts = if params[:tag].present?
    Post.by_tag(params[:tag]).pinned_first
    else
    @topic.posts
    end.includes(:taggings, :tags, :user, :comments).page(params[:page]).per(10).pinned_first
  end

  # GET /posts/1 or /posts/1.json
  def show
    all_comments = @post.comments.includes(:user, :rich_text_body, :parent, :replies).pinned_first.to_a
    @comments = all_comments.select { |c| c.parent_id.nil? }
    @replies = all_comments.group_by(&:parent_id)
    @comment = Comment.new

    # when user click on notification and view post it mark as read
    if params[:notification_id].present?
      notification = current_user.notifications.find_by(id: params[:notification_id])
      notification&.mark_as_read!
    end
  end

  # GET /posts/new
  def new
    @post = @topic.posts.build
    @available_tags = ActsAsTaggableOn::Tag.all.order(:name)
  end

  # GET /posts/1/edit
  def edit
    @available_tags = ActsAsTaggableOn::Tag.all.order(:name)
  end

  # POST /posts or /posts.json
  def create
    @post = @topic.posts.build(post_params.merge(user: current_user))
    @available_tags = ActsAsTaggableOn::Tag.all.order(:name)

    respond_to do |format|
      if @post.save
        format.html { redirect_to [ @topic, @post ], notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: [ @topic, @post ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to [ @topic, @post ], notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: [ @topic, @post ] }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    if current_user.admin? || @post.user == current_user
      @post.destroy!

      respond_to do |format|
        format.html { redirect_to topic_posts_path(@topic), notice: "Post was successfully destroyed.", status: :see_other }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Not authorized!" }
        format.json { render json: { error: "Not authorized" }, status: :forbidden }
      end
    end
  end

  def upvote
    @topic = Topic.find_by!(slug: params[:topic_slug])
    @post = Post.find_by!(slug: params[:slug])

    if current_user.votes.count >= 1 && !current_user.voted_for?(@post)
      redirect_back fallback_location: topic_posts_path(@topic), alert: "You can only vote one post"
      return
    end
    
    if @post.user == current_user
      redirect_back fallback_location: topic_posts_path(@topic), alert: "You can't vote your own post"
      return
    end

    if current_user.voted_for?(@post)
      @post.unvote_by current_user
      message = "Vote removed"
    else
      @post.upvote_by current_user
      message = "Voted succesfuly!"
    end

    redirect_back fallback_location: topic_posts_path(@topic), notice: message 
  end

  def tagged
  @posts = Post.tagged_with(params[:tag]).includes(:taggings, :tags, :user).order(created_at: :desc)
  end

  def pin
      @post.pin!
      redirect_back fallback_location: [ @topic, @post ], notice: "Post pinned!"
  end

  def unpin
      @post.unpin!
      redirect_back fallback_location: [ @topic, @post ], notice: "Post unpinned!"
  end

  def lock
      @post = Post.friendly.find(params[:id])
      @post.update(locked: true)
      redirect_to @post, notice: "Post has been locked!"
  end

  def unlock
      @post = Post.friendly.find(params[:id])
      @post.update(locked: false)
      redirect_to @post, notice: "Post has been unlocked!"
  end

  private

  def set_topic
    @topic = Topic.friendly.find(params[:topic_slug])
  end

  def set_post
    @post = @topic.posts.friendly.find(params[:slug])
  end

  def post_params
    params.require(:post).permit(:title, :body, tag_list: [])
  end

  def update_avatar_from_wallet
    mashit_data = params[:mashit_data]
    wallet_address = params[:wallet_address]

    if current_user.update(
      mashit_avatar_data: mashit_data,
      mashit_avatar_url: mashit_data["image_url"],
      wallet_address: wallet_address
    )
      render json: { success: true, avatar_url: current_user.mashit_avatar_url }
    else
      render json: { error: "Failed to update avatar" }, status: :unprocessable_entity
    end
  end

  def require_admin
        unless current_user&.admin?
            redirect_to root_path, alert: "You're not authorized!"
        end
    end
end
