module GravesHelper
  def area_sort
    (params[:sort] == "area:desc") ? "area:asc" : "area:desc"
  end

  def perimeter_sort
    (params[:sort] == "perimeter:desc") ? "perimeter:asc" : "perimeter:desc"
  end

  def width_sort
    (params[:sort] == "width:desc") ? "width:asc" : "width:desc"
  end

  def length_sort
    (params[:sort] == "length:desc") ? "length:asc" : "length:desc"
  end

  def id_sort
    (params[:sort] == "id:desc") ? "id:asc" : "id:desc"
  end

  def site_sort
    (params[:sort] == "site:desc") ? "site:asc" : "site:desc"
  end

  def depth_sort
    (params[:sort] == "depth:desc") ? "depth:asc" : "depth:desc"
  end

  def publication_sort
    (params[:sort] == "publication:desc") ? "publication:asc" : "publication:desc"
  end
end
