#include <cmath>
#include <cstdint>
#include <opencv2/opencv.hpp>
#include <ruby.h>

using namespace cv;
using namespace std;

double radiansToDegree(double radians) { return radians * (180 / 3.14159); }

Mat cropToFigure(VALUE figure, const Mat &image_mat) {
  long y1 = FIX2LONG(rb_funcall(figure, rb_intern("y1"), 0));
  long y2 = FIX2LONG(rb_funcall(figure, rb_intern("y2"), 0));
  long x1 = FIX2LONG(rb_funcall(figure, rb_intern("x1"), 0));
  long x2 = FIX2LONG(rb_funcall(figure, rb_intern("x2"), 0));

  x1 = max(0L, x1);
  y1 = max(0L, y1);
  x2 = max(0L, x2);
  y2 = max(0L, y2);

  try {
    Rect crop(x1, y1, x2 - x1, y2 - y1);
    return image_mat(crop);
  }
  catch( cv::Exception& e )
  {
      const char* err_msg = e.what();
      std::cout << "exception caught: " << err_msg << std::endl;
      return Mat();
  }
}

Mat convertRubyStringToMat(VALUE image_value) {
  char *image_char = StringValuePtr(image_value);
  long image_char_length = RSTRING_LEN(image_value);

  std::string image(image_char, image_char_length);

  std::vector<uchar> image_data(image.begin(), image.end());

  Mat undecoded_image_mat(image_data, true);
  Mat image_mat = imdecode(undecoded_image_mat, cv::IMREAD_COLOR);
  return image_mat;
}

VALUE convertMatToRubyString(const Mat &mat) {
  std::vector<uchar> buf;
  if(mat.empty()) {
    return rb_str_new("", 0);
  }

  cv::imencode(".jpg", mat, buf);

  std::string image_string(buf.begin(), buf.end());

  return rb_str_new(image_string.c_str(), image_string.size());
}

template<typename T>
VALUE convert_to_ruby(T) {
  return Qnil;
}

template<>
VALUE convert_to_ruby<double>(double d) {
  return rb_float_new(d);
}

template<>
VALUE convert_to_ruby<Point>(Point point) {
  VALUE point_array = rb_ary_new2(2);
  rb_ary_push(point_array, LONG2FIX(point.x));
  rb_ary_push(point_array, LONG2FIX(point.y));
  return point_array;
}

template<>
VALUE convert_to_ruby<Rect>(Rect rect) {
  VALUE result = rb_hash_new();

  rb_hash_aset(result, ID2SYM(rb_intern("x")), LONG2FIX(rect.x));
  rb_hash_aset(result, ID2SYM(rb_intern("y")), LONG2FIX(rect.y));

  rb_hash_aset(result, ID2SYM(rb_intern("width")), LONG2FIX(rect.width));
  rb_hash_aset(result, ID2SYM(rb_intern("height")), LONG2FIX(rect.height));
  return result;
}

template<>
VALUE convert_to_ruby<RotatedRect>(RotatedRect rect) {
  VALUE result = rb_hash_new();

  rb_hash_aset(result, ID2SYM(rb_intern("x")), rb_float_new(rect.center.x));
  rb_hash_aset(result, ID2SYM(rb_intern("y")), rb_float_new(rect.center.y));

  rb_hash_aset(result, ID2SYM(rb_intern("width")), rb_float_new(min(rect.size.width, rect.size.height)));
  rb_hash_aset(result, ID2SYM(rb_intern("height")), rb_float_new(max(rect.size.width, rect.size.height)));
  rb_hash_aset(result, ID2SYM(rb_intern("angle")), rb_float_new(rect.angle));
  return result;
}

template<>
VALUE convert_to_ruby(string str) {
  return rb_str_new(str.c_str(), str.length());
}

template<typename T>
VALUE convert_to_ruby(vector<T> vec) {
  VALUE result = rb_ary_new2(vec.size());

  for(const T &item : vec) {
    VALUE rb_item = convert_to_ruby(item);
    rb_ary_push(result, rb_item);
  }

  return result;
}

Size getKernel(VALUE rb_kernel) {
  long width = FIX2LONG(RARRAY_AREF(rb_kernel, 0));
  long height = FIX2LONG(RARRAY_AREF(rb_kernel, 1));
  return Size(width, height);
}

extern "C" VALUE rb_gauss(VALUE self, VALUE rb_mat, VALUE rb_kernel) {
  Mat mat = convertRubyStringToMat(rb_mat);

  Mat result;
  Size kernel = getKernel(rb_kernel);
  GaussianBlur(mat, result, kernel, 0);

  return convertMatToRubyString(result);
}

// extern "C" rb_rotatedRectStats(VALUE self, VALUE rb_center_x, VALUE rb_center_y, VALUE rb_width, VALUE rb_height, VALUE angle) {
//   long center_x = FIX2LONG(rb_center_x);
//   long center_y = FIX2LONG(rb_center_y);
//   long width = FIX2LONG(rb_width);
//   long height = FIX2LONG(rb_height);
//   long angle = FIX2LONG(rb_angle);

//   RotatedRect rRect = RotatedRect(Point2f(center_x, center_y), Size2f(width, height), angle);


// }

extern "C" VALUE rb_dilate(VALUE self, VALUE rb_mat, VALUE rb_kernel) {
  Mat mat = convertRubyStringToMat(rb_mat);
  Mat result;
  Size kernel = getKernel(rb_kernel);
  dilate(mat, result, getStructuringElement(MORPH_RECT, kernel));

  return convertMatToRubyString(result);
}

extern "C" VALUE rb_erode(VALUE self, VALUE rb_mat, VALUE rb_kernel) {
  Mat mat = convertRubyStringToMat(rb_mat);
  Mat result;
  Size kernel = getKernel(rb_kernel);
  erode(mat, result, getStructuringElement(MORPH_RECT, kernel));

  return convertMatToRubyString(result);
}

extern "C" VALUE rb_findContours(VALUE self, VALUE rb_mat, VALUE rb_retrieve_type) {
  Mat mat = convertRubyStringToMat(rb_mat);

  cvtColor(mat, mat, COLOR_BGR2GRAY);
  mat = Scalar(255) - mat;

  threshold(mat, mat, 40, 255, THRESH_BINARY);

  vector<vector<Point>> contours;
  vector<Vec4i> hierarchy;
  string retrieve_type = StringValueCStr(rb_retrieve_type);

  int morph_size = 2;
  Mat element = getStructuringElement(
        MORPH_RECT, Size(2 * morph_size + 1,
                         2 * morph_size + 1),
        Point(morph_size, morph_size));

  dilate(mat, mat, element, Point(-1, -1), 1);
  erode(mat, mat, element, Point(-1, -1), 1);

  if(retrieve_type == "external") {
    findContours(mat, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
  }
  else {
    findContours(mat, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
  }

  return convert_to_ruby(contours);
}

vector<Point> rbContourToCV(VALUE rb_contour) {
  vector<Point> contour;

  long point_count = RARRAY_LEN(rb_contour);
  for(long index = 0; index < point_count; index++) {
    VALUE rb_point = RARRAY_AREF(rb_contour, index);
    long x = FIX2LONG(RARRAY_AREF(rb_point, 0));
    long y = FIX2LONG(RARRAY_AREF(rb_point, 1));
    Point point(x, y);
    contour.push_back(point);
  }
  return contour;
}

extern "C" VALUE rb_arcLength(VALUE self, VALUE rb_contour) {
  try {
    auto contour = rbContourToCV(rb_contour);

    return convert_to_ruby(arcLength(contour, true));
  }
  catch( cv::Exception& e ) {
    return convert_to_ruby(-1);
  }
}

extern "C" VALUE rb_contourArea(VALUE self, VALUE rb_contour) {
  auto contour = rbContourToCV(rb_contour);

  return convert_to_ruby(contourArea(contour));
}

extern "C" VALUE rb_minAreaRect(VALUE self, VALUE rb_contour) {
  auto contour = rbContourToCV(rb_contour);

  RotatedRect rect = minAreaRect(contour);

  return convert_to_ruby(rect);
}

extern "C" VALUE rb_extractFigure(VALUE self, VALUE figure, VALUE rb_mat) {
  Mat mat = convertRubyStringToMat(rb_mat);
  Mat figure_mat = cropToFigure(figure, mat);

  return convertMatToRubyString(figure_mat);
}

extern "C" VALUE rb_imencode(VALUE self, VALUE rb_mat) {
  Mat mat = convertRubyStringToMat(rb_mat);

  std::vector<int> params;
  params.resize(9, 0);
  params[0] = cv::IMWRITE_JPEG_QUALITY;
  params[1] = 80;
  params[2] = cv::IMWRITE_JPEG_PROGRESSIVE;
  params[3] = 0;
  params[4] = cv::IMWRITE_JPEG_OPTIMIZE;
  params[5] = 0;
  params[6] = cv::IMWRITE_JPEG_RST_INTERVAL;
  params[7] = 0;

  std::vector<uchar> buffer;

  cv::imencode(".jpg", mat, buffer, params);

  std::string string_buffer(buffer.begin(), buffer.end());

  return convert_to_ruby(string_buffer);
}

extern "C" VALUE rb_imwrite(VALUE self, VALUE filename, VALUE rb_mat) {
  Mat mat = convertRubyStringToMat(rb_mat);
  imwrite(StringValueCStr(filename), mat);

  return Qnil;
}

extern "C" VALUE rb_boundingRect(VALUE self, VALUE rb_contour) {
  try {
    auto contour = rbContourToCV(rb_contour);
    return convert_to_ruby(boundingRect(contour));
  }
  catch( cv::Exception& e ) {
    return convert_to_ruby(-1);
  }
}

extern "C" VALUE rb_rotateNoCutoff(VALUE self, VALUE rb_mat, VALUE rb_angle) {
    Mat src = convertRubyStringToMat(rb_mat);
    double angle = RFLOAT_VALUE(rb_angle);
    Mat dst;
    // https://stackoverflow.com/questions/22041699/rotate-an-image-without-cropping-in-opencv-in-c
    // get rotation matrix for rotating the image around its center in pixel coordinates
    double width = src.size().width;
    double height = src.size().height;
    Point2d center = Point2d (width / 2, height / 2);
    Mat r = getRotationMatrix2D(center, angle, 1.0);      //Mat object for storing after rotation
    warpAffine(src, dst, r, Size(src.cols, src.rows), INTER_LINEAR, BORDER_CONSTANT, Scalar(255, 255, 255));  ///applie an affine transforation to image.


    return convertMatToRubyString(dst);
}

extern "C" void Init_ext() {
  VALUE ImageProcessing = rb_define_module("ImageProcessing");
  rb_define_module_function(ImageProcessing, "extractFigure", rb_extractFigure, 2);
  rb_define_module_function(ImageProcessing, "findContours", rb_findContours, 2);
  rb_define_module_function(ImageProcessing, "minAreaRect", rb_minAreaRect, 1);
  rb_define_module_function(ImageProcessing, "arcLength", rb_arcLength, 1);
  rb_define_module_function(ImageProcessing, "boundingRect", rb_boundingRect, 1);
  rb_define_module_function(ImageProcessing, "contourArea", rb_contourArea, 1);
  rb_define_module_function(ImageProcessing, "imwrite", rb_imwrite, 2);
  rb_define_module_function(ImageProcessing, "imencode", rb_imencode, 1);
  rb_define_module_function(ImageProcessing, "rotateNoCutoff", rb_rotateNoCutoff, 2);
  rb_define_module_function(ImageProcessing, "gauss", rb_gauss, 2);
  rb_define_module_function(ImageProcessing, "erode", rb_erode, 2);
  rb_define_module_function(ImageProcessing, "dilate", rb_dilate, 2);
}
