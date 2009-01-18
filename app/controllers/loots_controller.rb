class LootsController < ApplicationController
  before_filter :admin_required, :except => [:index, :show]

  # GET /loots
  # GET /loots.xml
  def index
    @loots = Loot.find(:all, :include => [:toon, :item, :raid], :order => 'toons.name')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @loots }
    end
  end

  # GET /loots/1
  # GET /loots/1.xml
  def show
    @loot = Loot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @loot }
    end
  end

  # GET /loots/new
  # GET /loots/new.xml
  def new
    @loot = Loot.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @loot }
    end
  end

  # GET /loots/1/edit
  def edit
    @loot = Loot.find(params[:id])
  end

  # POST /loots
  # POST /loots.xml
  def create
    @loot = Loot.new(params[:loot])

    respond_to do |format|
      if @loot.save
        flash[:notice] = 'Loot was successfully created.'
        format.html { redirect_to(@loot) }
        format.xml  { render :xml => @loot, :status => :created, :location => @loot }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @loot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /loots/1
  # PUT /loots/1.xml
  def update
    @loot = Loot.find(params[:id])

    respond_to do |format|
      if @loot.update_attributes(params[:loot])
        flash[:notice] = 'Loot was successfully updated.'
        format.html { redirect_to loots_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @loot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /loots/1
  # DELETE /loots/1.xml
  def destroy
    @loot = Loot.find(params[:id])
    @loot.destroy

    respond_to do |format|
      format.html { redirect_to(loots_url) }
      format.xml  { head :ok }
    end
  end
end
