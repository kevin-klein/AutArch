#include <cmath>
#include <cstdint>
#include <opencv2/opencv.hpp>
#include <ruby.h>

using namespace cv;
using namespace std;

RNG rng(12345);

class Vector2i {

public:
  Vector2i(uint32_t x, uint32_t y) : x(x), y(y) {}

  uint32_t x;
  uint32_t y;
};

double radiansToDegree(double radians) { return radians * (180 / 3.14159); }

uint32_t angle(const Vector2i &v1, const Vector2i &v2) {
  double dot = v1.x * v2.x + v1.y * v2.y;
  double det = v1.x * v2.y - v1.y * v2.x;
  double radians = atan2(det, dot);
  return static_cast<uint32_t>(radiansToDegree(radians));
}

vector<Point> findLargestContour(const vector<vector<Point>> &contours) {
  vector<double> lengths;
  std::transform(
      contours.begin(), contours.end(), std::back_inserter(lengths),
      [](vector<Point> contour) { return arcLength(contour, true); });

  int minIdx;
  double minVal;
  double maxVal;
  int maxIndex;
  minMaxLoc(SparseMat(Mat(lengths)), &minVal, &maxVal, &minIdx, &maxIndex);
  return contours[maxIndex];
}

Mat cropToFigure(VALUE figure, const Mat &image_mat) {
  long y1 = FIX2LONG(rb_funcall(figure, rb_intern("y1"), 0));
  long y2 = FIX2LONG(rb_funcall(figure, rb_intern("y2"), 0));
  long x1 = FIX2LONG(rb_funcall(figure, rb_intern("x1"), 0));
  long x2 = FIX2LONG(rb_funcall(figure, rb_intern("x2"), 0));

  x1 = max(0L, x1);
  y1 = max(0L, y1);
  x2 = max(0L, x2);
  y2 = max(0L, y2);

  Rect crop(x1, y1, x2 - x1, y2 - y1);
  return image_mat(crop);
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
  cv::imencode(".jpg", mat, buf);

  std::string image_string(buf.begin(), buf.end());

  return rb_str_new(image_string.c_str(), image_string.size());
}

extern "C" VALUE getCrossSectionStats(VALUE self, VALUE figure, VALUE image_value) {
  Mat image_mat = convertRubyStringToMat(image_value);
  Mat arrow_image = cropToFigure(figure, image_mat);

  cvtColor(arrow_image, arrow_image, COLOR_BGR2GRAY);
  arrow_image = Scalar(255) - arrow_image;

  threshold(arrow_image, arrow_image, 40, 255, THRESH_BINARY);

  vector<vector<Point>> contours;
  vector<Vec4i> hierarchy;
  findContours(arrow_image, contours, hierarchy, RETR_EXTERNAL,
               CHAIN_APPROX_SIMPLE);

  if (contours.size() == 0) {
    std::cout << "contour is empty" << endl;
    return Qnil;
  }

  auto contour = findLargestContour(contours);

  Rect rect = boundingRect(contour);
  VALUE result = rb_hash_new();
  rb_hash_aset(result, ID2SYM(rb_intern("width")), LONG2FIX(max(rect.height, rect.width)));
  rb_hash_aset(result, ID2SYM(rb_intern("height")), LONG2FIX(min(rect.height, rect.width)));

  return result;
}

extern "C" VALUE getGraveStats(VALUE self, VALUE figure, VALUE image_value) {
  Mat image_mat = convertRubyStringToMat(image_value);
  Mat figure_image = cropToFigure(figure, image_mat);
  Mat graveImage = figure_image;

  cvtColor(figure_image, figure_image, COLOR_BGR2GRAY);
  figure_image = Scalar(255) - figure_image;

  threshold(figure_image, figure_image, 40, 255, THRESH_BINARY);

  vector<vector<Point>> contours;
  vector<Vec4i> hierarchy;
  findContours(figure_image, contours, hierarchy, RETR_EXTERNAL,
               CHAIN_APPROX_SIMPLE);

  if (contours.size() == 0) {
    std::cout << "contour is empty" << endl;
    return Qnil;
  }

  auto contour = findLargestContour(contours);
  double arc = arcLength(contour, true);
  double area = contourArea(contour);

  RotatedRect boundingRectangle = minAreaRect(contour);
  Size2f size = boundingRectangle.size;

  cv::Point2f vertices2f[4];
  boundingRectangle.points(vertices2f);

  for (int i = 0; i < 4; i++)
    line(graveImage, vertices2f[i], vertices2f[(i+1)%4], Scalar(0, 0, 255), 2);

  VALUE result = rb_hash_new();
  rb_hash_aset(result, ID2SYM(rb_intern("area")), rb_float_new(area));
  rb_hash_aset(result, ID2SYM(rb_intern("perimeter")), rb_float_new(arc));

  rb_hash_aset(result, ID2SYM(rb_intern("width")), rb_float_new(min(size.width, size.height)));
  rb_hash_aset(result, ID2SYM(rb_intern("length")), rb_float_new(max(size.width, size.height)));
  rb_hash_aset(result, ID2SYM(rb_intern("angle")), rb_float_new(boundingRectangle.angle));

  return result;
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

template<typename T>
VALUE convert_to_ruby(vector<T> vec) {
  VALUE result = rb_ary_new2(vec.size());

  for(const T &item : vec) {
    VALUE rb_item = convert_to_ruby(item);
    rb_ary_push(result, rb_item);
  }

  return result;
}

extern "C" VALUE rb_findContours(VALUE self, VALUE rb_mat, VALUE rb_retrieve_type) {
  Mat mat = convertRubyStringToMat(rb_mat);

  cvtColor(mat, mat, COLOR_BGR2GRAY);
  mat = Scalar(255) - mat;

  threshold(mat, mat, 40, 255, THRESH_BINARY);

  vector<vector<Point>> contours;
  vector<Vec4i> hierarchy;
  string retrieve_type = StringValueCStr(rb_retrieve_type);
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
  auto contour = rbContourToCV(rb_contour);

  return convert_to_ruby(arcLength(contour, true));
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

extern "C" VALUE rb_imwrite(VALUE self, VALUE filename, VALUE rb_mat) {
  Mat mat = convertRubyStringToMat(rb_mat);
  imwrite(StringValueCStr(filename), mat);

  return Qnil;
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
  rb_define_module_function(ImageProcessing, "getGraveStats", getGraveStats, 2);
  rb_define_module_function(ImageProcessing, "getCrossSectionStats", getCrossSectionStats, 2);
  rb_define_module_function(ImageProcessing, "extractFigure", rb_extractFigure, 2);
  rb_define_module_function(ImageProcessing, "findContours", rb_findContours, 2);
  rb_define_module_function(ImageProcessing, "minAreaRect", rb_minAreaRect, 1);
  rb_define_module_function(ImageProcessing, "arcLength", rb_arcLength, 1);
  rb_define_module_function(ImageProcessing, "contourArea", rb_contourArea, 1);
  rb_define_module_function(ImageProcessing, "imwrite", rb_imwrite, 2);
  rb_define_module_function(ImageProcessing, "rotateNoCutoff", rb_rotateNoCutoff, 2);
}
