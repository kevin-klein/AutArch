class PageImagesController < ApplicationController
  # GET /page_images or /page_images.json
  def index
    @page_images = PageImage.all
  end

  # GET /page_images/1 or /page_images/1.json
  def show
    image = Image.find(params[:id])
    send_file image.file_path
  end

  # GET /page_images/new
  def new
    @page_image = PageImage.new
  end

  # GET /page_images/1/edit
  def edit
  end

  # POST /page_images or /page_images.json
  def create
    @page_image = PageImage.new(page_image_params)

    respond_to do |format|
      if @page_image.save
        format.html { redirect_to page_image_url(@page_image), notice: "Page image was successfully created." }
        format.json { render :show, status: :created, location: @page_image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @page_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /page_images/1 or /page_images/1.json
  def update
    respond_to do |format|
      if @page_image.update(page_image_params)
        format.html { redirect_to page_image_url(@page_image), notice: "Page image was successfully updated." }
        format.json { render :show, status: :ok, location: @page_image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @page_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /page_images/1 or /page_images/1.json
  def destroy
    @page_image.destroy

    respond_to do |format|
      format.html { redirect_to page_images_url, notice: "Page image was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
end
