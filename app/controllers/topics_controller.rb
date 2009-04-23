class TopicsController < ApplicationController
  def show
    @topic = Topic.find(params[:id], :include => [:posts])
    @forum = @topic.forum
  end

  def new
    @forum = Forum.find(params[:forum_id])
    @post = Post.new
  end
  
  def create
    @topic = Topic.create(:forum_id => params[:forum_id], :title => params[:post][:title])
    @post = @topic.posts.create(params[:post], :user_id => current_user)
  end
end
