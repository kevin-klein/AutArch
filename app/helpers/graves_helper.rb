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
end
