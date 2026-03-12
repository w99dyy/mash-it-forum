class PostsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_topic, only: %i[ index new create show edit update destroy ]
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    if params[:tag].present?
        @posts = Post.by_tag(params[:tag])
    else
      @posts = @topic.posts.order(created_at: :desc)
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
    @post = @topic.posts.find(params[:id])
    @comments = @post.comments.order(created_at: :desc)
    @comment = Comment.new  # ← Not associated with @post yet
  end

  # GET /posts/new
  def new
    @post = @topic.posts.build
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = @topic.posts.build(post_params.merge(user: current_user))

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
        format.json { redner json: {error: "Not authorized"}, status: :forbidden }
      end 
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end
    def set_post
      @post = @topic.posts.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :body ])
      params.require(:post).permit(:title, :body, :tag_list)
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
end
