class TopicsController < ApplicationController
    before_action :authenticate_user!, except: [ :index, :show ]

    def index
        if params[:tag].present?
            @topics = Topic.tagged_with(params[:tag])
        else
            @topics = Topic.all.order(created_at: :desc)
        end
    end

    def show
        @topic = Topic.find(params[:id])
        @post = Post.new
        @post = @topic.posts.order(created_at: :desc)
    end

    def new
        @topic = Topic.new
    end

    def create
        @topic = Topic.new(topic_params)
        @topic.user = current_user
        respond_to do |format|
            if @topic.save
                format.html { redirect_to @topic, notice: "Topic created!" }
                format.json { render :show, status: :created, location: @topic }
            else
                format.html { render :new, status: :unprocessable_entity }
                format.json { render json: @topic.errors, status: :unprocessable_entity }
            end
        end
    end

    def edit
        @topic = Topic.find(params[:id])
    end

    def update
        @topic = Topic.find(params[:id])

        if @topic.update(topic_params)
            redirect_to @topic, notice: "Topic updated!"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @topic = Topic.find(params[:id])
        @topic.destroy
        redirect_to topics_path, notice: "Topic deleted!"
    end

    private

    def topic_params
        params.require(:topic).permit(:title, :body, :tag_list)
    end
end
