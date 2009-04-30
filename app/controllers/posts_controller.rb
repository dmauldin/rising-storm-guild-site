class PostsController < ApplicationController
  before_filter :users_only
  
  def new
    @post = Post.new
  end
  
  # POST /posts
  # POST /posts.xml
  def create
    @post = post.new(params[:post])

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
    @post = Post.find(params[:id])
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
end
