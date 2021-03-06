class LootsController < ApplicationController
  before_filter :admin_only, :except => [:index, :show]

  # GET /loots
  # GET /loots.xml
  def index
    @search = Loot.new_search(params[:search])
    # @search.conditions.raid.start_at_after = 2.months.ago unless params[:search]
    # @search.conditions.toon.id = params[:toon_id] if params[:toon_id]
    @search.order_by ||= {:raid => :start_at}
    @search.order_as ||= 'DESC'
    # TODO I don't remember why I was ordering by inventory_type, maybe this should be removed
    # @search.order_with_ordering = "raids.start_at desc, items.inventory_type asc"
    @search.include = [:item, {:toon => :job}, {:raid => :zone}]
    @search.distinct = "raid_id"
    if params[:show_last_per_toon]
      @loots = @search.all
    else
      @loots = @search.all
    end
    class <<@loots
      def hash
        self.toon.hash
      end
      alias eql? ==
    end
    @loots = @loots.uniq
    @loots_count = @search.count
    # @raids = Raid.all(:conditions => {:id => @loots.map{|loot| loot.raid.id}.uniq})
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
    @raids = Raid.all(:order => 'start_at desc', :limit => 15, :include => :zone)
      
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
    item = Item.find_by_id(params[:item_id])
    unless item
      item = Item.new
      item[:id] = params[:item_id]
      item.update_from_armory!
    end
    toon = Toon.find_by_name(params[:toon_name]) || Toon.new(:name => params[:toon_name]).update_from_armory!
    @loot.update_attributes({:toon_id => toon[:id], :item_id => item[:id]})
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
  
  def toggle_status
    @loot = Loot.find(params[:id], :include => [:item, {:toon => :job}, {:raid => :zone}])
    @loot.status = @loot.status=="primary" ? "secondary" : "primary"
    @loot.save
    respond_to do |format|
      format.xml { head :ok }
      format.html { render :partial => 'loot', :layout => false, :object => @loot }
    end
  end
end
