class Pca
  attr_reader :explained_variance_ratio
  def initialize opts = {}
    @pca = PCA.new(n_components: 2)
  end

  def fit(x)
    @pca.fit(x)
    @explained_variance_ratio = @pca.explained_variance_ratio_
  end

  def transform(x)
    @pca.transform(x)
  end
end
