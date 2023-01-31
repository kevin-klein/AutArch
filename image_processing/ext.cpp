#include <cmath>
#include <cstdint>
#include <opencv2/opencv.hpp>
#include <ruby.h>
// #include <tesseract/baseapi.h>

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

  x1 = max(0, x1);
  y1 = max(0, y1);
  x2 = max(0, x2);
  y2 = max(0, y2);

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

Mat extractContour(const Mat &image, vector<Point> contour) {
  Rect newImageSize = boundingRect(contour);
  vector<vector<Point>> contourParam = {contour};
  Mat mask = Mat::zeros(image.rows, image.cols, CV_8UC1);
  fillPoly(mask, contourParam, Scalar(255));

  Mat result;

  bitwise_and(image, mask, result);
  // imwrite("inverted.jpg", invertedImage);

  Mat croppedImage = result(newImageSize);

  return croppedImage;
}

double average(std::vector<uint32_t> &vi) {
  double sum = 0;

  for (int p : vi) {
    sum = sum + p;
  }

  return (sum / vi.size());
}

vector<vector<Point>> findGraves(Mat image, vector<vector<Point>> contours) {
  vector<vector<Point>> graves;
  int imageSize = image.rows * image.cols;

  static int index = 0;
  for (vector<Point> contour : contours) {
    // cout << "Contour: " << index << endl;

    double area = contourArea(contour);
    if (area / imageSize > 0.01) {
      Mat part = extractContour(image, contour);
      // part = Scalar(255) - part;
      // threshold(part, part, 0, 40, THRESH_BINARY);

      // vector<vector<Point>> partContour;
      // vector<Vec4i> hierarchy;
      // findContours(part, partContour, hierarchy, RETR_EXTERNAL,
      //              CHAIN_APPROX_SIMPLE);

      vector<Point> poly;
      approxPolyDP(Mat(contour), poly, 3, true);
      // // Mat output = part.clone();
      // Mat output = Mat::zeros(part.rows, part.cols, part.type());
      //
      // vector<uint32_t> angles(partContour.size());

      // for (size_t i = 2; i < poly.size(); i++) {
      //   auto p1 = contour[i - 2];
      //   auto p2 = contour[i - 1];
      //   auto p3 = contour[i];
      //
      //   double x1 = p1.x - p2.x;
      //   double y1 = p1.y - p2.y;
      //   Vector2i vector1(static_cast<int>(x1), static_cast<int>(y1));
      //
      //   double x2 = p2.x - p3.x;
      //   double y2 = p2.y - p3.y;
      //   Vector2i vector2(static_cast<int>(x2), static_cast<int>(y2));
      //
      //   uint32_t vectorAngle = angle(vector1, vector2);
      //   angles.push_back(vectorAngle);
      //   // cout << "x1: " << x1 << ", y1: " << y1 << ", x2: " << x2
      //   //      << ", y2: " << y2 << endl;
      //   // std::cout << vectorAngle << endl;
      // }

      // int zero = countNonZero(part);
      //
      //
      // vector<vector<Point>> contourInput = {poly};
      // drawContours(output, contourInput, -1, Scalar(255, 0, 0), 3);

      // double relation = arcLength(poly, true) / area;

      // if (relation > 0.1 && relation < 0.6) {
      imwrite("pdfs/contours/contour_" + std::to_string(index) + ".jpg", part);
      // }
    }
    index++;
  }

  return graves;
}

extern "C" VALUE analyzePage(VALUE self, VALUE image_value) {
  Mat base_image = convertRubyStringToMat(image_value);

  Mat image_mat;
  cvtColor(base_image, image_mat, COLOR_BGR2GRAY);
  image_mat = Scalar(255) - image_mat;
  Mat grayScale;
  threshold(image_mat, grayScale, 40, 255, THRESH_BINARY);

  // int morphSize = 1;
  // Mat element = getStructuringElement(
  //     MORPH_RECT, Size(2 * morphSize + 1, 2 * morphSize + 1),
  //     Point(morphSize, morphSize));
  // morphologyEx(image_mat, image_mat, MORPH_CLOSE, element, Point(-1, -1), 2);
  // morphologyEx(image_mat, image_mat, MORPH_OPEN, element, Point(-1, -1), 2);

  // int dilation_size = 1;
  // Mat element = getStructuringElement(
  //     MORPH_ELLIPSE, Size(2 * dilation_size + 1, 2 * dilation_size + 1),
  //     Point(dilation_size, dilation_size));
  // dilate(image_mat, image_mat, element);

  vector<vector<Point>> contours;
  vector<Vec4i> hierarchy;
  findContours(grayScale, contours, hierarchy, RETR_EXTERNAL,
               CHAIN_APPROX_SIMPLE);

  // drawContours(base_image, contours, -1, Scalar(255, 0, 0), 2);

  vector<vector<Point>> graves = findGraves(image_mat, contours);

  // imwrite("page.jpg", base_image);

  return LONG2FIX(contours.size());
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
  rb_hash_aset(result, ID2SYM(rb_intern("width")), LONG2FIX(rect.width));
  rb_hash_aset(result, ID2SYM(rb_intern("height")), LONG2FIX(rect.height));

  return result;
}

extern "C" VALUE getGraveStats(VALUE self, VALUE figure, VALUE image_value) {
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
  double arc = arcLength(contour, true);
  double area = contourArea(contour);

  RotatedRect boundingRectangle = minAreaRect(contour);
  Size2f size = boundingRectangle.size;

  VALUE result = rb_hash_new();
  rb_hash_aset(result, ID2SYM(rb_intern("area")), DBL2NUM(area));
  rb_hash_aset(result, ID2SYM(rb_intern("arc")), DBL2NUM(arc));
  rb_hash_aset(result, ID2SYM(rb_intern("width")), DBL2NUM(size.width));
  rb_hash_aset(result, ID2SYM(rb_intern("height")), DBL2NUM(size.height));

  return result;
}

void findArrowTip(vector<Point> points, vector<Point> convexHull) {
  uint32_t length = points.size();
}

double getLength(const Point &p1, const Point &p2) {
  return pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 0.5);
}

vector<Point> getMaxDistanceArrowPoint(const vector<Point> &contour) {
  double maxDistance = 0;
  vector<Point> maxPoints;

  for (Point p1 : contour) {
    for (Point p2 : contour) {
      double distance = getLength(p1, p2);

      if (distance > maxDistance) {
        maxDistance = distance;
        maxPoints = {p1, p2};
      }
    }
  }

  return maxPoints;
}

extern "C" VALUE getAngle(VALUE self, VALUE figure, VALUE image_value) {
  Mat image_mat = convertRubyStringToMat(image_value);
  Mat arrow_image = cropToFigure(figure, image_mat);

  cvtColor(arrow_image, arrow_image, COLOR_BGR2GRAY);
  arrow_image = Scalar(255) - arrow_image;

  threshold(arrow_image, arrow_image, 40, 255, THRESH_BINARY);

  vector<vector<Point>> contours;
  vector<Vec4i> hierarchy;
  findContours(arrow_image, contours, hierarchy, RETR_TREE,
               CHAIN_APPROX_SIMPLE);

  if (hierarchy.size() > 0) {
    auto thresholdDistance = 1000;

    vector<Point> hull;
    std::vector<Vec4i> defects;

    for (size_t i = 0; i < contours.size(); i++) {
      convexHull(contours[i], hull, false);

      convexityDefects(contours[i], hull, defects);
      cout << defects.size() << endl;

      for (Vec4i defect : defects) {
        int distance = defect[3];

        if (distance > thresholdDistance) {
          // vector<Point> points = getMaxDistanceArrowPoint(contour[i]);
          // double angle =
        }
      }
    }
  }

  // if (contours.size() == 0) {
  //   std::cout << "contour is empty" << endl;
  //   return Qnil;
  // }
  //
  // auto contour = findBestArrowContour(contours);
  //
  // Moments ms = moments(contour);
  //
  // Point2f center(ms.m10 / (ms.m00 + 1e-5), ms.m01 / (ms.m00 + 1e-5));
  //
  // std::vector<float> line;
  //
  // fitLine(contour, line, DIST_L2, 0, 0.01, 0.01);
  //
  // Mat yAxis({1, 2}, {0.0f, 1.0f});
  // Mat centerLine({1, 2}, {line[0], line[1]});
  //
  // double dotProduct = yAxis.dot(centerLine);
  //
  // double angleToY = acos(dotProduct);
  //
  // RotatedRect box = minAreaRect(contour);
  // vector<Point2f> boxPts(4);
  // box.points(boxPts.data());
  //
  // Point2f bottomLeft = boxPts[0];
  // Point2f topLeft = boxPts[1];
  // Point2f topRight = boxPts[2];
  // Point2f bottomRight = boxPts[3];
  //
  // Point2f topCenter = (topLeft + topRight) / 2;
  // Point2f leftCenter = (bottomLeft + topLeft) / 2;
  // Point2f bottomCenter = (bottomLeft + bottomRight) / 2;
  // Point2f rightCenter = (bottomRight + topRight) / 2;
  //
  // double topCenterDistance = norm(center - topCenter);
  // double leftCenterDistance = norm(center - leftCenter);
  // double rightCenterDistance = norm(center - rightCenter);
  // double bottomCenterDistance = norm(center - bottomCenter);
  //
  // int angle = static_cast<int>(angleToY * (180.0 / 3.141592653589793238463));
  // angle = LONG2FIX(angle);
  //
  // if (angle >= 270 && leftCenterDistance > rightCenterDistance) {
  //   angle = (angle + 180) % 360;
  // } else if (angle >= 180 && angle <= 270 &&
  //            bottomCenterDistance > topCenterDistance) {
  //   angle = (angle + 180) % 360;
  // } else if (angle >= 90 && angle <= 180 &&
  //            rightCenterDistance > leftCenterDistance) {
  //   angle = (angle + 180) % 360;
  // } else if (topCenterDistance > bottomCenterDistance) {
  //   angle = (angle + 180) % 360;
  // }

  // return angle;
  return 0;
}

// tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
//
// VALUE initTesseract(VALUE self) {
//   if (api->Init(NULL, "eng")) {
//     fprintf(stderr, "Could not initialize tesseract.\n");
//     exit(1);
//   }
//
//   return Qnil;
// }

template<typename T>
VALUE convert_to_ruby(T) {
  // static_assert(false, NAMEOF_TYPE(T));
  return Qnil;
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

template<typename T>
VALUE convert_to_ruby(vector<T> vec) {
  VALUE result = rb_ary_new2(vec.size());

  for(const T &item : vec) {
    VALUE rb_item = convert_to_ruby(item);
    rb_ary_push(result, rb_item);
  }

  return result;
}

extern "C" VALUE rb_findContours(VALUE self, VALUE rb_mat) {
  Mat mat = convertRubyStringToMat(rb_mat);

  cvtColor(mat, mat, COLOR_BGR2GRAY);
  mat = Scalar(255) - mat;

  threshold(mat, mat, 40, 255, THRESH_BINARY);

  vector<vector<Point>> contours;
  vector<Vec4i> hierarchy;
  findContours(mat, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);

  return convert_to_ruby(contours);
}

extern "C" VALUE rb_minAreaRect(VALUE self, VALUE rb_contour) {
  vector<Point> contour;

  long point_count = RARRAY_LEN(rb_contour);
  for(long index = 0; index < point_count; index++) {
    VALUE rb_point = RARRAY_AREF(rb_contour, index);
    long x = FIX2LONG(RARRAY_AREF(rb_point, 0));
    long y = FIX2LONG(RARRAY_AREF(rb_point, 1));
    Point point(x, y);
    contour.push_back(point);
  }


  RotatedRect rect = minAreaRect(contour);
  // return LONG2FIX(rect.boundingRect().width);

  return convert_to_ruby(rect.boundingRect());
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

extern "C" void Init_ext() {
  VALUE ImageProcessing = rb_define_module("ImageProcessing");
  rb_define_module_function(ImageProcessing, "getAngle", getAngle, 2);
  rb_define_module_function(ImageProcessing, "getGraveStats", getGraveStats, 2);
  rb_define_module_function(ImageProcessing, "getCrossSectionStats", getCrossSectionStats, 2);
  rb_define_module_function(ImageProcessing, "analyzePage", analyzePage, 1);
  rb_define_module_function(ImageProcessing, "extractFigure", rb_extractFigure, 2);
  rb_define_module_function(ImageProcessing, "findContours", rb_findContours, 1);
  rb_define_module_function(ImageProcessing, "minAreaRect", rb_minAreaRect, 1);
  rb_define_module_function(ImageProcessing, "imwrite", rb_imwrite, 2);

  // VALUE TesseractAPI = rb_define_module("Tesseract");
  // rb_define_module_function(TesseractAPI, "init", initTesseract, 0);
}
