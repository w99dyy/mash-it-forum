class TopicsController < ApplicationController
    before_action :authenticate_user!, except: [ :index, :show ]
    before_action :set_topic, only: %i[ show edit update destroy pin unpin lock unlock ]
    before_action :require_admin, only: %i[ pin unpin lock unlock ]

    def index
        @topics = if params[:tag].present?
        Topic.by_tag(params[:tag]).pinned_first
        else
       @topics = Topic.includes(:posts, :taggings, :tags).page(params[:page]).per(10).pinned_first
        end
    end

    def show
        @post = Post.new
        @posts = @topic.posts.order(created_at: :desc)
    end

    def new
        @topic = Topic.new
        @available_tags = ActsAsTaggableOn::Tag.all.order(:name)
    end

    def create
        @topic = Topic.new(topic_params)
        @topic.user = current_user
        @available_tags = ActsAsTaggableOn::Tag.all.order(:name)
        respond_to do |format|
            if @topic.save
                format.html { redirect_to topic_posts_path(@topic), notice: "Topic created!" }
                format.json { render :show, status: :created, location: @topic }
            else
                format.html { render :new, status: :unprocessable_entity }
                format.json { render json: @topic.errors, status: :unprocessable_entity }
            end
        end
    end

    def edit
        @topic = Topic.friendly.find(params[:id])
    end

    def update
        @topic = Topic.friendly.find(params[:id])

        if @topic.update(topic_params)
            redirect_to @topic, notice: "Topic updated!"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @topic = Topic.friendly.find(params[:id])
        @topic.destroy
        redirect_to topics_path, notice: "Topic deleted!"
    end

    def pin
        @topic.pin!
        redirect_back fallback_location: @topic, notice: "Topic pinned!"
    end

     def unpin
        @topic.unpin!
        redirect_back fallback_location: @topic, notice: "Topic unpinned!"
    end

    def lock
        @topic = Topic.friendly.find(params[:id])
        @topic.update(locked: true)
        redirect_to @topic, notice: "Topic has been locked!"
    end

    def unlock
        @topic = Topic.friendly.find(params[:id])
        @topic.update(locked: false)
        redirect_to @topic, notice: "Topic has been unlocked!"
    end

    private

    def topic_params
        params.require(:topic).permit(:title, :body, :tag_list)
    end

    def require_admin
        unless current_user&.admin?
            redirect_to root_path, alert: "You're not authorized!"
        end
    end

    def set_topic
        @topic = Topic.friendly.find(params[:id])
    end
end
