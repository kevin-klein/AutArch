# app/controllers/teams/team_publications_controller.rb
class Teams::TeamPublicationsController < AuthorizedController
  before_action :set_team
  load_and_authorize_resource :team

  def new
    @publication_assignment = PublicationTeam.new
    @publications = Publication.accessible_by(current_ability).where(user: current_user).where.not(id: @team.publication_ids).select(:id, :public, :user_id, :title, :author, :year)
  end

  def create
    @publication_assignment = PublicationTeam.new(team_publication_params)
    @publication_assignment.team = @team
    if @publication_assignment.save
      redirect_to @team, notice: "Publication was added to the team."
    else
      @publications = Publication.accessible_by(current_ability).where(user: current_user).where.not(id: @team.publication_ids).select(:id, :public, :user_id, :title, :author, :year)
      render :new
    end
  end

  def destroy
    @assignment = @team.publication_teams.find(params[:id])
    @assignment.destroy
    redirect_to @team, notice: "Publication was removed from the team."
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end

  def team_publication_params
    params.require(:publication_team).permit(:publication_id)
  end
end
