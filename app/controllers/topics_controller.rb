class TopicsController < ApplicationController
  before_filter :users_only, :except => :show
  
  def show
    @topic = Topic.find(params[:id], :include => [:posts])
    @forum = @topic.forum
    @topic.increment! :view_count
  end

  def new
    @forum = Forum.find(params[:forum_id])
    @post = Post.new
  end
  
  def create
    @topic = Topic.create(:forum_id => params[:forum_id], :title => params[:post][:title])
    @post = Post.new(params[:post])
    if @topic.new_record?
      flash[:error] = @topic.errors.full_messages.join("<br/>")
      render :action => 'new'
      return
    else
      @post.topic = @topic
      @post.user = current_user
      @post.save
    end
    redirect_to topic_path(@topic) << "##{@post.id}"
  end
end
