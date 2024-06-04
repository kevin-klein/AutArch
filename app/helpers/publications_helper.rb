module PublicationsHelper
  def sortable_by(name)
    (params[:sort] == "#{name}:desc") ? "#{name}:asc" : "#{name}:desc"
  end
end
