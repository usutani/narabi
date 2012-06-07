
class DiagramsController < ApplicationController
  # GET /diagrams
  # GET /diagrams.json
  def index
    #TODO
    @diagrams = [Diagram.current(request)]
    #@diagrams = Diagram.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @diagrams }
    end
  end

  # GET /diagrams/1
  # GET /diagrams/1.json
  def show
    @diagram = Diagram.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @diagram }
    end
  end

  # GET /diagrams/new
  # GET /diagrams/new.json
  def new
    @diagram = Diagram.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @diagram }
    end
  end

  # GET /diagrams/1/edit
  def edit
    @diagram = Diagram.find(params[:id])
  end

  # POST /diagrams
  # POST /diagrams.json
  def create
    @diagram = Diagram.new(params[:diagram])

    respond_to do |format|
      if @diagram.save
        format.html { redirect_to @diagram, notice: 'Diagram was successfully created.' }
        format.json { render json: @diagram, status: :created, location: @diagram }
      else
        format.html { render action: "new" }
        format.json { render json: @diagram.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /diagrams/1
  # PUT /diagrams/1.json
  def update
    @diagram = Diagram.find(params[:id])

    respond_to do |format|
      if @diagram.update_attributes(params[:diagram])
        format.html { redirect_to @diagram, notice: 'Diagram was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @diagram.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diagrams/1
  # DELETE /diagrams/1.json
  def destroy
    @diagram = Diagram.find(params[:id])
    @diagram.destroy

    respond_to do |format|
      format.html { redirect_to diagrams_url }
      format.json { head :no_content }
    end
  end
end
