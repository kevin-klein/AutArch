module Efd
  # based on: https://github.com/hbldh/pyefd/blob/master/pyefd.py
  # based on: https://www.palass.org/sites/default/files/media/palaeomath_101/article_25/article_25.pdf
  # contour: numo array
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.elliptic_fourier_descriptors(contour, order: 10, normalize: false, return_transformation: false)
    contour = Numo::DFloat[*contour] unless contour.is_a?(Numo::DFloat)
    dxy = contour.diff(axis: 0)
    dt = Numo::DFloat::Math.sqrt(contour**2).sum(axis: 1)
    large_t = dt.cumsum[0]

    phi = (2 * Math::PI * (Numo::DFloat[0.0, large_t])) / large_t
    orders = Numo::DFloat.new(order).seq(1)
    consts = (2 * orders * orders * Math::PI * Math::PI) * (1 / large_t)
    phi *= orders.reshape(order, 1)

    d_cos_phi = Numo::DFloat::Math.cos(phi[true, 1..-1]) - Numo::DFloat::Math.cos(phi[true, 0..-2])
    d_sin_phi = Numo::DFloat::Math.sin(phi[true, 1..-1]) - Numo::DFloat::Math.sin(phi[true, 0..-2])

    dt = dt[0]

    a = consts * ((dxy[true, 0] / dt) * d_cos_phi).sum(axis: 1)
    b = consts * ((dxy[true, 0] / dt) * d_sin_phi).sum(axis: 1)
    c = consts * ((dxy[true, 1] / dt) * d_cos_phi).sum(axis: 1)
    d = consts * ((dxy[true, 1] / dt) * d_sin_phi).sum(axis: 1)

    coeffs = a.reshape(order, 1).concatenate(b.reshape(order, 1), c.reshape(order, 1), d.reshape(order, 1), axis: 1)
    coeffs = normalize_efd(coeffs, return_transformation: return_transformation) if normalize
    coeffs
  end

  def self.normalize_efd(coeffs, size_invariant: false, return_transformation: false)
    theta_1 = 0.5 * Math.atan2(
      2 * ((coeffs[0, 0] * coeffs[0, 1]) + (coeffs[0, 2] * coeffs[0, 3])),
      (coeffs[0, 0]**2) - (coeffs[0, 1]**2) + (coeffs[0, 2]**2) - (coeffs[0, 3]**2)
    )

    (0..coeffs[coeffs.shape[0]]).each do |n|
      coeffs[n, true] =
        Numo::DFloat[
          [coeffs[n, 0], coeffs[n, 1]],
          [coeffs[n, 2], coeffs[n, 3]]
        ]
          .dot(
            Numo::DFloat[
              [Math.cos((n + 1) * theta_1), -Math.sin((n + 1) * theta_1)],
              [Math.sin(n + (1 * theta_1)), Math.cos((n + 1) * theta_1)]]
          ).flatten
    end

    psi_1 = Math.atan2(coeffs[0, 2], coeffs[0, 0])
    psi_rotation_matrix = Numo::DFloat[
      [Math.cos(psi_1), Math.sin(psi_1)],
      [-Math.sin(psi_1), Math.cos(psi_1)]
    ]

    (0..coeffs[coeffs.shape[0]]).each do |n|
      coeffs[n, true] = psi_rotation_matrix.dot(Numo::DFloat[
        [coeffs[n, 0], coeffs[n, 1]],
        [coeffs[n, 2], coeffs[n, 3]]
      ]).flatten
    end

    size = coeffs[0, 0]
    coeffs /= size.abs if size_invariant

    if return_transformation
      {
        coeffs: coeffs,
        size: size,
        psi_1: psi_1,
        theta_1: theta_1
      }
    else
      coeffs
    end
  end
end
