class PostsController < ApplicationController
  before_filter :users_only
  
  def new
    @topic = Topic.find(params[:topic_id], :include => [:forum])
    @post = Post.new(:topic_id => params[:topic_id], :title => "re: #{@topic.title}")
    @forum = @topic.forum
  end
  
  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])
    @post.user = current_user

    respond_to do |format|
      if @post.save
        flash[:notice] = 'post was successfully created.'
        format.html { redirect_to topic_path(@post.topic).concat("##{@post[:id]}") }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @post = Post.find(params[:id], :include => [{:topic => :forum}])
    @topic = @post.topic
    @forum = @topic.forum
  end
  
  def update
    @post = Post.find(params[:id])
    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'post was successfully updated.'
        format.html { redirect_to topic_path(@post.topic).concat("##{@post[:id]}") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    redirect_to topic_path(params[:topic_id]).concat("##{params[:id]}")
  end
end
