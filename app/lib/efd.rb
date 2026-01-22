module Efd
  extend self
  # Calculate EFA coefficients for a given contour
  # contour: array of [x, y] points representing the closed shape
  # n_harmonics: number of harmonics to compute
  # normalize: boolean to enable/disable normalization (default: false)
  def elliptic_fourier_descriptors(contour, n_harmonics, normalize: false)
    coefficients = []
    n_points = contour.length

    (1..n_harmonics).each do |n|
      a_n, b_n, c_n, d_n = calculate_harmonic(contour, n, n_points)
      coefficients << {n: n, a: a_n, b: b_n, c: c_n, d: d_n}
    end

    descriptors(coefficients, normalize)
  end

  # Calculate coefficients for a single harmonic
  def calculate_harmonic(contour, n, n_points)
    x = contour.map { |p| p[0] }
    y = contour.map { |p| p[1] }

    # Calculate Fourier coefficients
    a_n = (0...n_points).sum { |k| (x[k] * Math.cos(2 * Math::PI * n * k / n_points) + y[k] * Math.sin(2 * Math::PI * n * k / n_points)) } / n_points
    b_n = (0...n_points).sum { |k| (x[k] * Math.sin(2 * Math::PI * n * k / n_points) - y[k] * Math.cos(2 * Math::PI * n * k / n_points)) } / n_points
    c_n = (0...n_points).sum { |k| (x[k] * Math.cos(2 * Math::PI * n * k / n_points) - y[k] * Math.sin(2 * Math::PI * n * k / n_points)) } / n_points
    d_n = (0...n_points).sum { |k| (x[k] * Math.sin(2 * Math::PI * n * k / n_points) + y[k] * Math.cos(2 * Math::PI * n * k / n_points)) } / n_points

    [a_n, b_n, c_n, d_n]
  end

  # Reconstruct the contour from coefficients
  # n_harmonics: number of harmonics to use in reconstruction
  def reconstruct(n_harmonics)
    n_points = 100  # Number of points in reconstructed contour
    x = Array.new(n_points, 0.0)
    y = Array.new(n_points, 0.0)

    (0...n_points).each do |k|
      (0...n_harmonics).each do |i|
        n = i + 1
        coeff = @coefficients[i]
        x[k] += coeff[:a] * Math.cos(2 * Math::PI * n * k / n_points) - coeff[:b] * Math.sin(2 * Math::PI * n * k / n_points)
        y[k] += coeff[:c] * Math.cos(2 * Math::PI * n * k / n_points) - coeff[:d] * Math.sin(2 * Math::PI * n * k / n_points)
      end
    end

    # Center the reconstructed shape
    x_mean = x.sum / n_points
    y_mean = y.sum / n_points
    x.map { |xi| xi - x_mean }
    y.map { |yi| yi - y_mean }
  end

  # Calculate the normalized elliptical Fourier descriptors
  # normalize: boolean to enable/disable normalization
  def descriptors(coefficients, normalize)
    if normalize
      coefficients.map do |coeff|
        {
          n: coeff[:n],
          a: coeff[:a] / (coeff[:a]**2 + coeff[:b]**2 + coeff[:c]**2 + coeff[:d]**2),
          b: coeff[:b] / (coeff[:a]**2 + coeff[:b]**2 + coeff[:c]**2 + coeff[:d]**2),
          c: coeff[:c] / (coeff[:a]**2 + coeff[:b]**2 + coeff[:c]**2 + coeff[:d]**2),
          d: coeff[:d] / (coeff[:a]**2 + coeff[:b]**2 + coeff[:c]**2 + coeff[:d]**2)
        }
      end
    else
      coefficients
    end
  end
end
