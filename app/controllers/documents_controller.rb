# frozen_string_literal: true

class DocumentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def index
    @documents = Document.all
  end

  def show
    @document = Document.find(params[:id])
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new(document_params)
    @document.name = params[:document][:file].original_filename
    @document.file_type = params[:document][:file].content_type
    @document.status = :processing
    @document.is_active = true

    if @document.save
      ProcessDocumentJob.perform_later(@document.id)
      redirect_to documents_path, notice: "Document uploaded and processing"
    else
      render :new
    end
  end

  def edit
    @document = Document.find(params[:id])
  end

  def update
    @document = Document.find(params[:id])
    if @document.update(document_params)
      redirect_to @document, notice: "Document was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @document = Document.find(params[:id])
    @document.destroy
    redirect_to documents_path, notice: "Document was successfully deleted."
  end

  private

  def document_params
    params.require(:document).permit(:title, :content, :file)
  end
end
