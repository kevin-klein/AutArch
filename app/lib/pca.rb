class Pca
  attr_reader :explained_variance_ratio
  def initialize(scale_data: false, components: 2, whiten: true)
    @pca = Rumale::Decomposition::PCA.new(n_components: components)
    @scale_data = scale_data
    # @scale_data = false
  end



  def fit(x)
    if @scale_data
      create_sd(x)
      x = scale(x)
    end

    @pca.fit(x)
    # raise



    # evaluator = Rumale::EvaluationMeasure::ExplainedVarianceScore.new
    # evaluator.score(@pca.trans)
  end

  def transform(x)
    x = scale(x) if @scale_data
    @pca.transform(x)
  end

  def create_sd(data)
    @scaler = Rumale::Preprocessing::StandardScaler.new
    @scaler.fit(data)
  end

  def scale(data)
    @scaler.transform(data)
  end
end
