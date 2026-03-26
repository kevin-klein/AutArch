class AnalysisWizard < ApplicationRecord
  belongs_to :page, optional: true

  enum :step, {
    upload: 0,
    contour: 1,
    similarity: 2
  }

  serialize :contours, coder: JSON
  serialize :state, coder: JSON

  has_many :ceramic_figures, class_name: "Ceramic", foreign_key: "wizard_id", dependent: :destroy

  after_update :update_figures_state, if: :saved_change_to_id?

  # Step transition
  def advance_step
    update_column(:step, step.next)
  end

  # Add a ceramic figure to the wizard
  def add_ceramic(figure_id:, bovw_features:)
    create_figure!(figure_id: figure_id, bovw_features: bovw_features)
  end

  # Store result for figure
  def store_result(figure)
    # BOVW features are already extracted and passed via add_ceramic
    # Just create the object similarity record
    create_object_similarity(figure.id, figure.features || [])
  end

  # Get all figures in this wizard
  def figures
    Ceramic.where(id: contours)
  end

  private

  def create_figure!(attributes)
    ceramic = Ceramic.create!(wizard_id: id, **attributes.except(:bovw_features))
    update(contours: contours | [ceramic.id])
    ceramic
  end

  def create_object_similarity(figure_id, bovw_features)
    return if bovw_features.blank?

    # Remove existing similarity for this figure (re-calculate)
    ObjectSimilarity.where(first_id: figure_id).delete_all

    ObjectSimilarity.create!(
      first_id: figure_id,
      second_id: figure_id,
      similarity: 1.0,
      bovw_features: bovw_features
    )
  end

  def update_figures_state
    # Update wizard_id on all figures in contours
    Ceramic.where(id: contours).update_all(wizard_id: id)
  end
end
